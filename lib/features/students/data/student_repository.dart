import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/constants/db_constants.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/error/app_exception.dart';
import '../../activity/data/activity_repository.dart';
import '../domain/student.dart';

class StudentRepository {
  const StudentRepository(this._db, this._activityRepo);

  final Database _db;
  final ActivityRepository _activityRepo;

  Future<List<Student>> getAll({
    String? query,
    String? className,
  }) async {
    final String trimmedQuery = query?.trim() ?? '';
    final String? filterClass = (className != null && className.isNotEmpty && className != 'All')
        ? className
        : null;

    final List<String> conditions = <String>[];
    final List<dynamic> whereArgs = <dynamic>[];

    if (trimmedQuery.isNotEmpty) {
      final String wildcard = '%$trimmedQuery%';
      conditions.add(
        '(${DbConstants.columnStudentName} LIKE ? OR '
        '${DbConstants.columnStudentRollNumber} LIKE ? OR '
        '${DbConstants.columnStudentClassName} LIKE ? OR '
        '${DbConstants.columnStudentContact} LIKE ? OR '
        '${DbConstants.columnStudentGender} LIKE ? OR '
        'CAST(${DbConstants.columnStudentAge} AS TEXT) LIKE ?)',
      );
      whereArgs.addAll(<dynamic>[
        wildcard,
        wildcard,
        wildcard,
        wildcard,
        wildcard,
        wildcard,
      ]);
    }

    if (filterClass != null) {
      conditions.add('${DbConstants.columnStudentClassName} = ?');
      whereArgs.add(filterClass);
    }

    final String? whereClause = conditions.isNotEmpty ? conditions.join(' AND ') : null;

    String orderByClause;
    if (trimmedQuery.isNotEmpty) {
      final String safeQuery = trimmedQuery.replaceAll("'", "''");
      orderByClause = '''
        CASE
          WHEN ${DbConstants.columnStudentName} LIKE '$safeQuery%' THEN 0
          WHEN ${DbConstants.columnStudentName} LIKE '%$safeQuery%' THEN 1
          WHEN ${DbConstants.columnStudentRollNumber} LIKE '$safeQuery%' THEN 2
          ELSE 3
        END,
        ${DbConstants.columnStudentName} COLLATE NOCASE ASC
      ''';
    } else {
      orderByClause = '${DbConstants.columnStudentName} COLLATE NOCASE ASC';
    }

    final List<Map<String, dynamic>> maps = await _db.query(
      DbConstants.tableStudents,
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: orderByClause,
    );

    return maps.map(Student.fromMap).toList();
  }

  Future<Student?> getById(int id) async {
    final List<Map<String, dynamic>> maps = await _db.query(
      DbConstants.tableStudents,
      where: '${DbConstants.columnId} = ?',
      whereArgs: <dynamic>[id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return Student.fromMap(maps.first);
  }

  Future<int> insert(Student student) async {
    try {
      return await _db.transaction<int>((Transaction txn) async {
        final int id = await txn.insert(
          DbConstants.tableStudents,
          student.toMap(),
        );

        await _activityRepo.log(
          DbConstants.activityStudentAdded,
          'Added student ${student.name}',
          executor: txn,
        );

        return id;
      });
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw const DuplicateException(
          'roll_number',
          'Roll number already exists',
        );
      }
      throw DatabaseOperationException('Failed to add student: ${e.toString()}', e);
    }
  }

  Future<void> update(Student student) async {
    if (student.id == null) {
      throw const ValidationException('Cannot update student without ID');
    }

    try {
      await _db.transaction<void>((Transaction txn) async {
        final int rowsAffected = await txn.update(
          DbConstants.tableStudents,
          student.toMap(),
          where: '${DbConstants.columnId} = ?',
          whereArgs: <dynamic>[student.id],
        );

        if (rowsAffected == 0) {
          throw NotFoundException('Student with ID ${student.id} not found');
        }

        await _activityRepo.log(
          DbConstants.activityStudentUpdated,
          'Updated student ${student.name}',
          executor: txn,
        );
      });
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        throw const DuplicateException(
          'roll_number',
          'Roll number already exists',
        );
      }
      throw DatabaseOperationException('Failed to update student: ${e.toString()}', e);
    }
  }

  Future<void> delete(int id, {String? studentName}) async {
    await _db.transaction<void>((Transaction txn) async {
      final int rows = await txn.delete(
        DbConstants.tableStudents,
        where: '${DbConstants.columnId} = ?',
        whereArgs: <dynamic>[id],
      );

      if (rows > 0) {
        final String label = studentName != null ? 'student $studentName' : 'student';
        await _activityRepo.log(
          DbConstants.activityStudentDeleted,
          'Deleted $label',
          executor: txn,
        );
      }
    });
  }

  Future<List<String>> getClassNamesWithStudents() async {
    final List<Map<String, dynamic>> maps = await _db.rawQuery('''
      SELECT DISTINCT ${DbConstants.columnStudentClassName}
      FROM ${DbConstants.tableStudents}
      ORDER BY ${DbConstants.columnStudentClassName} ASC
    ''');

    return maps
        .map((Map<String, dynamic> m) => m[DbConstants.columnStudentClassName] as String)
        .toList();
  }

  Future<int> count() async {
    final int? result = Sqflite.firstIntValue(
      await _db.rawQuery('SELECT COUNT(*) FROM ${DbConstants.tableStudents}'),
    );
    return result ?? 0;
  }
}

final Provider<StudentRepository> studentRepositoryProvider =
    Provider<StudentRepository>((Ref ref) {
  final AsyncValue<Database> dbAsync = ref.watch(databaseProvider);
  final ActivityRepository activityRepo = ref.watch(activityRepositoryProvider);
  return StudentRepository(dbAsync.requireValue, activityRepo);
});
