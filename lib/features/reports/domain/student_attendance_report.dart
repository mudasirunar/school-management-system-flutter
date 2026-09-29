import '../../attendance/domain/attendance_status.dart';
import '../../students/domain/student.dart';

class StudentDayAttendanceRecord {
  final DateTime date;
  final AttendanceStatus? status;

  const StudentDayAttendanceRecord({
    required this.date,
    this.status,
  });

  bool get isPresent => status == AttendanceStatus.present;
  bool get isAbsent => status == AttendanceStatus.absent;
  bool get isLeave => status == AttendanceStatus.leave;
  bool get isUnmarked => status == null;
}

class StudentMonthAttendanceReport {
  final Student student;
  final int year;
  final int month;
  final int presentCount;
  final int absentCount;
  final int leaveCount;
  final int unmarkedCount;
  final int totalDaysEvaluated;
  final double attendancePercentage;
  final List<StudentDayAttendanceRecord> dayRecords;

  const StudentMonthAttendanceReport({
    required this.student,
    required this.year,
    required this.month,
    required this.presentCount,
    required this.absentCount,
    required this.leaveCount,
    required this.unmarkedCount,
    required this.totalDaysEvaluated,
    required this.attendancePercentage,
    required this.dayRecords,
  });

  int get markedDays => presentCount + absentCount + leaveCount;
}
