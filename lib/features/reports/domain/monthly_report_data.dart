class MonthlyStudentAttendanceItem {
  final int studentId;
  final String studentName;
  final String rollNumber;
  final String className;
  final int daysPresent;
  final int daysAbsent;
  final int daysLeave;
  final int totalRecordedDays;
  final double attendancePercentage;

  const MonthlyStudentAttendanceItem({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.className,
    required this.daysPresent,
    required this.daysAbsent,
    this.daysLeave = 0,
    required this.totalRecordedDays,
    required this.attendancePercentage,
  });
}

class ClassMonthlySummaryItem {
  final String className;
  final int totalWorkingDays;
  final int totalStudents;
  final double averageAttendanceRate;

  const ClassMonthlySummaryItem({
    required this.className,
    required this.totalWorkingDays,
    required this.totalStudents,
    required this.averageAttendanceRate,
  });
}

class MonthlyClassSummary {
  final int year;
  final int month;
  final String? className;
  final int totalWorkingDays;
  final int totalStudents;
  final double averageAttendanceRate;
  final List<MonthlyStudentAttendanceItem> studentSummaries;
  final List<ClassMonthlySummaryItem> classSummaries;

  const MonthlyClassSummary({
    required this.year,
    required this.month,
    this.className,
    required this.totalWorkingDays,
    required this.totalStudents,
    required this.averageAttendanceRate,
    required this.studentSummaries,
    this.classSummaries = const <ClassMonthlySummaryItem>[],
  });

  bool get isEmpty => totalWorkingDays == 0 || totalStudents == 0;
}
