import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/constants/db_constants.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/utils/date_utils.dart';
import '../../activity/data/activity_repository.dart';
import '../../activity/domain/activity_entry.dart';
import '../domain/dashboard_data.dart';

class DashboardRepository {
  final Database _db;
  final ActivityRepository _activityRepo;

  const DashboardRepository(this._db, this._activityRepo);

  Future<DashboardData> getDashboardData() async {
    // 1. Total students count
    final List<Map<String, dynamic>> studentsResult = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DbConstants.tableStudents}',
    );
    final int totalStudents = Sqflite.firstIntValue(studentsResult) ?? 0;

    // 2. Total teachers count
    final List<Map<String, dynamic>> teachersResult = await _db.rawQuery(
      'SELECT COUNT(*) as count FROM ${DbConstants.tableTeachers}',
    );
    final int totalTeachers = Sqflite.firstIntValue(teachersResult) ?? 0;

    // 3. Today's attendance
    final String todayIso = AppDateUtils.toIsoDate(DateTime.now());
    final List<Map<String, dynamic>> attendanceRows = await _db.rawQuery(
      '''
      SELECT COUNT(*) as total,
             COUNT(CASE WHEN ${DbConstants.columnAttendanceStatus} = '${DbConstants.statusPresent}' THEN 1 END) as present,
             COUNT(CASE WHEN ${DbConstants.columnAttendanceStatus} = '${DbConstants.statusAbsent}' THEN 1 END) as absent
      FROM ${DbConstants.tableAttendance}
      WHERE ${DbConstants.columnAttendanceDate} = ?
      ''',
      <dynamic>[todayIso],
    );

    int totalMarked = 0;
    int presentCount = 0;
    int absentCount = 0;

    if (attendanceRows.isNotEmpty) {
      final Map<String, dynamic> row = attendanceRows.first;
      totalMarked = (row['total'] as int?) ?? 0;
      presentCount = (row['present'] as int?) ?? 0;
      absentCount = (row['absent'] as int?) ?? 0;
    }

    final double attendanceRate =
        totalMarked > 0 ? (presentCount / totalMarked) * 100.0 : 0.0;

    // 4. Recent activities
    final List<ActivityEntry> activities = await _activityRepo.getRecent(limit: 10);

    return DashboardData(
      totalStudents: totalStudents,
      totalTeachers: totalTeachers,
      todayDate: todayIso,
      todayTotalMarked: totalMarked,
      todayPresentCount: presentCount,
      todayAbsentCount: absentCount,
      todayAttendanceRate: attendanceRate,
      recentActivities: activities,
    );
  }
}

final Provider<DashboardRepository> dashboardRepositoryProvider =
    Provider<DashboardRepository>((Ref ref) {
  final AsyncValue<Database> dbAsync = ref.watch(databaseProvider);
  final ActivityRepository activityRepo = ref.watch(activityRepositoryProvider);
  return DashboardRepository(dbAsync.requireValue, activityRepo);
});
