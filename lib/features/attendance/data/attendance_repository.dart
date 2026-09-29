import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/constants/db_constants.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/utils/date_utils.dart';
import '../../activity/data/activity_repository.dart';
import '../domain/attendance_filter.dart';
import '../domain/attendance_record.dart';
import '../domain/attendance_status.dart';

class AttendanceRepository {
  const AttendanceRepository(this._db, this._activityRepo);

  final Database _db;
  final ActivityRepository _activityRepo;

  Future<Map<int, AttendanceStatus>> getStatusesForDateAndClass({
    required String date,
    required String className,
  }) async {
    final List<Map<String, dynamic>> maps = await _db.rawQuery('''
      SELECT a.${DbConstants.columnAttendanceStudentId}, a.${DbConstants.columnAttendanceStatus}
      FROM ${DbConstants.tableAttendance} a
      JOIN ${DbConstants.tableStudents} s ON a.${DbConstants.columnAttendanceStudentId} = s.${DbConstants.columnId}
      WHERE a.${DbConstants.columnAttendanceDate} = ? AND s.${DbConstants.columnStudentClassName} = ?
    ''', <dynamic>[date, className]);

    final Map<int, AttendanceStatus> result = <int, AttendanceStatus>{};
    for (final Map<String, dynamic> row in maps) {
      final int studentId = row[DbConstants.columnAttendanceStudentId] as int;
      final String statusString = row[DbConstants.columnAttendanceStatus] as String;
      final AttendanceStatus? status = AttendanceStatus.fromValue(statusString);
      if (status != null) {
        result[studentId] = status;
      }
    }
    return result;
  }

  Future<void> saveBatch({
    required String date,
    required String className,
    required Map<int, AttendanceStatus> statuses,
  }) async {
    final String now = DateTime.now().toIso8601String();

    await _db.transaction<void>((Transaction txn) async {
      final Batch batch = txn.batch();

      for (final MapEntry<int, AttendanceStatus> entry in statuses.entries) {
        batch.rawInsert('''
          INSERT INTO ${DbConstants.tableAttendance} (
            ${DbConstants.columnAttendanceStudentId},
            ${DbConstants.columnAttendanceDate},
            ${DbConstants.columnAttendanceStatus},
            ${DbConstants.columnUpdatedAt}
          ) VALUES (?, ?, ?, ?)
          ON CONFLICT(${DbConstants.columnAttendanceStudentId}, ${DbConstants.columnAttendanceDate})
          DO UPDATE SET
            ${DbConstants.columnAttendanceStatus} = excluded.${DbConstants.columnAttendanceStatus},
            ${DbConstants.columnUpdatedAt} = excluded.${DbConstants.columnUpdatedAt}
        ''', <dynamic>[entry.key, date, entry.value.value, now]);
      }

      await batch.commit(noResult: true);

      final String dateDisplay = AppDateUtils.formatIsoForDisplay(date);
      await _activityRepo.log(
        DbConstants.activityAttendanceSaved,
        'Saved attendance for $className on $dateDisplay',
        executor: txn,
      );
    });
  }

  Future<List<AttendanceRecord>> searchRecords(AttendanceFilter filter) async {
    final List<String> conditions = <String>[];
    final List<dynamic> whereArgs = <dynamic>[];

    final String trimmedQuery = filter.query?.trim() ?? '';
    if (trimmedQuery.isNotEmpty) {
      conditions.add(
        '(s.${DbConstants.columnStudentName} LIKE ? OR s.${DbConstants.columnStudentRollNumber} LIKE ?)',
      );
      whereArgs.addAll(<dynamic>['%$trimmedQuery%', '%$trimmedQuery%']);
    }

    if (filter.className != null && filter.className!.isNotEmpty && filter.className != 'All') {
      conditions.add('s.${DbConstants.columnStudentClassName} = ?');
      whereArgs.add(filter.className);
    }

    if (filter.date != null && filter.date!.isNotEmpty) {
      conditions.add('a.${DbConstants.columnAttendanceDate} = ?');
      whereArgs.add(filter.date);
    }

    if (filter.status != null) {
      conditions.add('a.${DbConstants.columnAttendanceStatus} = ?');
      whereArgs.add(filter.status!.value);
    }

    final String whereClause = conditions.isNotEmpty ? 'WHERE ${conditions.join(' AND ')}' : '';

    final List<Map<String, dynamic>> maps = await _db.rawQuery('''
      SELECT 
        a.${DbConstants.columnId},
        a.${DbConstants.columnAttendanceStudentId},
        a.${DbConstants.columnAttendanceDate},
        a.${DbConstants.columnAttendanceStatus},
        a.${DbConstants.columnUpdatedAt},
        s.${DbConstants.columnStudentName} AS student_name,
        s.${DbConstants.columnStudentRollNumber} AS roll_number,
        s.${DbConstants.columnStudentClassName} AS class_name
      FROM ${DbConstants.tableAttendance} a
      JOIN ${DbConstants.tableStudents} s ON a.${DbConstants.columnAttendanceStudentId} = s.${DbConstants.columnId}
      $whereClause
      ORDER BY a.${DbConstants.columnAttendanceDate} DESC, s.${DbConstants.columnStudentName} COLLATE NOCASE ASC
      LIMIT 300
    ''', whereArgs);

    return maps.map(AttendanceRecord.fromMap).toList();
  }

  Future<void> updateRecordStatus(int recordId, AttendanceStatus newStatus) async {
    final String now = DateTime.now().toIso8601String();
    await _db.update(
      DbConstants.tableAttendance,
      <String, dynamic>{
        DbConstants.columnAttendanceStatus: newStatus.value,
        DbConstants.columnUpdatedAt: now,
      },
      where: '${DbConstants.columnId} = ?',
      whereArgs: <dynamic>[recordId],
    );
  }
}

final Provider<AttendanceRepository> attendanceRepositoryProvider =
    Provider<AttendanceRepository>((Ref ref) {
  final AsyncValue<Database> dbAsync = ref.watch(databaseProvider);
  final ActivityRepository activityRepo = ref.watch(activityRepositoryProvider);
  return AttendanceRepository(dbAsync.requireValue, activityRepo);
});
