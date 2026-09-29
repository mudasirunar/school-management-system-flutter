import '../../activity/domain/activity_entry.dart';

class DashboardData {
  final int totalStudents;
  final int totalTeachers;
  final String todayDate;
  final int todayTotalMarked;
  final int todayPresentCount;
  final int todayAbsentCount;
  final int todayLeaveCount;
  final double todayAttendanceRate;
  final List<ActivityEntry> recentActivities;

  const DashboardData({
    required this.totalStudents,
    required this.totalTeachers,
    required this.todayDate,
    required this.todayTotalMarked,
    required this.todayPresentCount,
    required this.todayAbsentCount,
    this.todayLeaveCount = 0,
    required this.todayAttendanceRate,
    required this.recentActivities,
  });

  bool get hasAttendanceToday => todayTotalMarked > 0;
}
