import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/constants/db_constants.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/error/app_exception.dart';
import '../../activity/data/activity_repository.dart';
import '../domain/teacher.dart';

class TeacherRepository {
  const TeacherRepository(this._db, this._activityRepo);

  final Database _db;
  final ActivityRepository _activityRepo;

  Future<List<Teacher>> getAll({String? query}) async {
    final String trimmedQuery = query?.trim() ?? '';

    String? whereClause;
    List<dynamic>? whereArgs;

    if (trimmedQuery.isNotEmpty) {
      final String wildcard = '%$trimmedQuery%';
      whereClause = '(${DbConstants.columnTeacherName} LIKE ? OR '
          '${DbConstants.columnTeacherEmployeeId} LIKE ? OR '
          '${DbConstants.columnTeacherSubject} LIKE ? OR '
          '${DbConstants.columnTeacherContact} LIKE ? OR '
          '${DbConstants.columnTeacherEmail} LIKE ?)';
      whereArgs = <dynamic>[
        wildcard,
        wildcard,
        wildcard,
        wildcard,
        wildcard,
      ];
    }

    String orderByClause;
    if (trimmedQuery.isNotEmpty) {
      final String safeQuery = trimmedQuery.replaceAll("'", "''");
      orderByClause = '''
        CASE
          WHEN ${DbConstants.columnTeacherName} LIKE '$safeQuery%' THEN 0
          WHEN ${DbConstants.columnTeacherName} LIKE '%$safeQuery%' THEN 1
          WHEN ${DbConstants.columnTeacherEmployeeId} LIKE '$safeQuery%' THEN 2
          ELSE 3
        END,
        ${DbConstants.columnTeacherName} COLLATE NOCASE ASC
      ''';
    } else {
      orderByClause = '${DbConstants.columnTeacherName} COLLATE NOCASE ASC';
    }

    final List<Map<String, dynamic>> maps = await _db.query(
      DbConstants.tableTeachers,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: orderByClause,
    );

    return maps.map(Teacher.fromMap).toList();
  }

  Future<Teacher?> getById(int id) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      DbConstants.tableTeachers,
      where: '${DbConstants.columnId} = ?',
      whereArgs: <dynamic>[id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Teacher.fromMap(maps.first);
  }

  Future<int> insert(Teacher teacher) async {
    try {
      return await _db.transaction<int>((Transaction txn) async {
        final int id = await txn.insert(
          DbConstants.tableTeachers,
          teacher.toMap(),
        );

        await _activityRepo.log(
          DbConstants.activityTeacherAdded,
          'Added teacher ${teacher.name}',
          executor: txn,
        );

        return id;
      });
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw const DuplicateException(
          'employee_id',
          'Employee ID already exists',
        );
      }
      throw DatabaseOperationException('Failed to add teacher: ${e.toString()}', e);
    }
  }

  Future<void> update(Teacher teacher) async {
    if (teacher.id == null) {
      throw const ValidationException('Cannot update teacher without ID');
    }

    try {
      await _db.transaction<void>((Transaction txn) async {
        final int rowsAffected = await txn.update(
          DbConstants.tableTeachers,
          teacher.toMap(),
          where: '${DbConstants.columnId} = ?',
          whereArgs: <dynamic>[teacher.id],
        );

        if (rowsAffected == 0) {
          throw NotFoundException('Teacher with ID ${teacher.id} not found');
        }

        await _activityRepo.log(
          DbConstants.activityTeacherUpdated,
          'Updated teacher ${teacher.name}',
          executor: txn,
        );
      });
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw const DuplicateException(
          'employee_id',
          'Employee ID already exists',
        );
      }
      throw DatabaseOperationException('Failed to update teacher: ${e.toString()}', e);
    }
  }

  Future<void> delete(int id, {String? teacherName}) async {
    await _db.transaction<void>((Transaction txn) async {
      final int rows = await txn.delete(
        DbConstants.tableTeachers,
        where: '${DbConstants.columnId} = ?',
        whereArgs: <dynamic>[id],
      );

      if (rows > 0) {
        final String label = teacherName != null ? 'teacher $teacherName' : 'teacher';
        await _activityRepo.log(
          DbConstants.activityTeacherDeleted,
          'Deleted $label',
          executor: txn,
        );
      }
    });
  }

  Future<int> count() async {
    final int? result = Sqflite.firstIntValue(
      await _db.rawQuery('SELECT COUNT(*) FROM ${DbConstants.tableTeachers}'),
    );
    return result ?? 0;
  }
}

final Provider<TeacherRepository> teacherRepositoryProvider =
    Provider<TeacherRepository>((Ref ref) {
  final AsyncValue<Database> dbAsync = ref.watch(databaseProvider);
  final ActivityRepository activityRepo = ref.watch(activityRepositoryProvider);
  return TeacherRepository(dbAsync.requireValue, activityRepo);
});
