import '../../attendance/domain/attendance_status.dart';

class DailyStudentAttendanceItem {
  final int studentId;
  final String studentName;
  final String rollNumber;
  final String className;
  final AttendanceStatus status;

  const DailyStudentAttendanceItem({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.className,
    required this.status,
  });
}

class ClassDailySummaryItem {
  final String className;
  final int totalStudents;
  final int presentCount;
  final int absentCount;
  final double attendancePercentage;

  const ClassDailySummaryItem({
    required this.className,
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
    required this.attendancePercentage,
  });
}

class DailyClassSummary {
  final String date;
  final String? className;
  final int totalStudents;
  final int presentCount;
  final int absentCount;
  final double attendancePercentage;
  final List<DailyStudentAttendanceItem> students;
  final List<ClassDailySummaryItem> classSummaries;

  const DailyClassSummary({
    required this.date,
    this.className,
    required this.totalStudents,
    required this.presentCount,
    required this.absentCount,
    required this.attendancePercentage,
    required this.students,
    this.classSummaries = const <ClassDailySummaryItem>[],
  });

  bool get isEmpty => totalStudents == 0;
}
