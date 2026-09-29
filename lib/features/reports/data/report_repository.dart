import 'package:sqflite/sqflite.dart';
import '../../../core/constants/db_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../../attendance/domain/attendance_status.dart';
import '../../students/domain/student.dart';
import '../domain/daily_report_data.dart';
import '../domain/monthly_report_data.dart';
import '../domain/student_attendance_report.dart';

class ReportRepository {
  final Database _db;

  ReportRepository(this._db);

  /// Fetches daily summary and student attendance records for a specific date and optional class.
  Future<DailyClassSummary> getDailySummary({
    required String date,
    String? className,
  }) async {
    final List<dynamic> whereArgs = <dynamic>[date];
    String whereClause = 'a.${DbConstants.columnAttendanceDate} = ?';

    if (className != null && className.isNotEmpty && className != 'All Classes') {
      whereClause += ' AND s.${DbConstants.columnStudentClassName} = ?';
      whereArgs.add(className);
    }

    final String query = '''
      SELECT a.${DbConstants.columnAttendanceStudentId},
             a.${DbConstants.columnAttendanceDate},
             a.${DbConstants.columnAttendanceStatus},
             s.${DbConstants.columnStudentName},
             s.${DbConstants.columnStudentRollNumber},
             s.${DbConstants.columnStudentClassName}
      FROM ${DbConstants.tableAttendance} a
      JOIN ${DbConstants.tableStudents} s ON a.${DbConstants.columnAttendanceStudentId} = s.${DbConstants.columnId}
      WHERE $whereClause
      ORDER BY s.${DbConstants.columnStudentRollNumber} ASC, s.${DbConstants.columnStudentName} ASC
    ''';

    final List<Map<String, dynamic>> rows = await _db.rawQuery(query, whereArgs);

    int presentCount = 0;
    int absentCount = 0;
    int leaveCount = 0;
    final List<DailyStudentAttendanceItem> studentItems = <DailyStudentAttendanceItem>[];

    for (final Map<String, dynamic> row in rows) {
      final String statusStr = row[DbConstants.columnAttendanceStatus] as String;
      final AttendanceStatus status =
          AttendanceStatus.fromValue(statusStr) ?? AttendanceStatus.absent;

      if (status == AttendanceStatus.present) {
        presentCount++;
      } else if (status == AttendanceStatus.leave) {
        leaveCount++;
      } else {
        absentCount++;
      }

      studentItems.add(
        DailyStudentAttendanceItem(
          studentId: row[DbConstants.columnAttendanceStudentId] as int,
          studentName: (row[DbConstants.columnStudentName] as String?) ?? '',
          rollNumber: (row[DbConstants.columnStudentRollNumber] as String?) ?? '',
          className: (row[DbConstants.columnStudentClassName] as String?) ?? '',
          status: status,
        ),
      );
    }

    final int total = studentItems.length;
    final int effectiveDays = presentCount + absentCount;
    final double percentage = effectiveDays > 0
        ? (presentCount / effectiveDays) * 100.0
        : (leaveCount > 0 ? 100.0 : 0.0);

    final Map<String, List<DailyStudentAttendanceItem>> classGrouped =
        <String, List<DailyStudentAttendanceItem>>{};
    for (final DailyStudentAttendanceItem item in studentItems) {
      classGrouped
          .putIfAbsent(item.className, () => <DailyStudentAttendanceItem>[])
          .add(item);
    }

    final List<ClassDailySummaryItem> classSummaries = <ClassDailySummaryItem>[];
    for (final MapEntry<String, List<DailyStudentAttendanceItem>> entry in classGrouped.entries) {
      final int cTotal = entry.value.length;
      final int cPresent =
          entry.value.where((DailyStudentAttendanceItem s) => s.status == AttendanceStatus.present).length;
      final int cLeave =
          entry.value.where((DailyStudentAttendanceItem s) => s.status == AttendanceStatus.leave).length;
      final int cAbsent =
          entry.value.where((DailyStudentAttendanceItem s) => s.status == AttendanceStatus.absent).length;
      final int cEffective = cPresent + cAbsent;
      final double cPct = cEffective > 0
          ? (cPresent / cEffective) * 100.0
          : (cLeave > 0 ? 100.0 : 0.0);
      classSummaries.add(
        ClassDailySummaryItem(
          className: entry.key,
          totalStudents: cTotal,
          presentCount: cPresent,
          absentCount: cAbsent,
          leaveCount: cLeave,
          attendancePercentage: cPct,
        ),
      );
    }
    classSummaries.sort((ClassDailySummaryItem a, ClassDailySummaryItem b) => a.className.compareTo(b.className));

    return DailyClassSummary(
      date: date,
      className: className,
      totalStudents: total,
      presentCount: presentCount,
      absentCount: absentCount,
      leaveCount: leaveCount,
      attendancePercentage: percentage,
      students: studentItems,
      classSummaries: classSummaries,
    );
  }

  /// Fetches monthly summary and per-student attendance rates for a specific month/year and optional class.
  Future<MonthlyClassSummary> getMonthlySummary({
    required int year,
    required int month,
    String? className,
  }) async {
    final String monthPrefix =
        '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-%';
    final bool isSpecificClass =
        className != null && className.isNotEmpty && className != 'All Classes';

    // 1. Get unique working dates recorded for this class/school in this month
    final String workingDaysSql = isSpecificClass
        ? '''
          SELECT COUNT(DISTINCT a.${DbConstants.columnAttendanceDate}) AS count
          FROM ${DbConstants.tableAttendance} a
          JOIN ${DbConstants.tableStudents} s ON a.${DbConstants.columnAttendanceStudentId} = s.${DbConstants.columnId}
          WHERE s.${DbConstants.columnStudentClassName} = ? AND a.${DbConstants.columnAttendanceDate} LIKE ?
          '''
        : '''
          SELECT COUNT(DISTINCT a.${DbConstants.columnAttendanceDate}) AS count
          FROM ${DbConstants.tableAttendance} a
          WHERE a.${DbConstants.columnAttendanceDate} LIKE ?
          ''';
    final List<dynamic> workingDaysArgs =
        isSpecificClass ? <dynamic>[className, monthPrefix] : <dynamic>[monthPrefix];

    final List<Map<String, dynamic>> workingDaysResult =
        await _db.rawQuery(workingDaysSql, workingDaysArgs);
    final int totalWorkingDays = Sqflite.firstIntValue(workingDaysResult) ?? 0;

    // 2. Fetch all active students currently enrolled
    final List<Map<String, dynamic>> studentRows = await _db.query(
      DbConstants.tableStudents,
      columns: <String>[
        DbConstants.columnId,
        DbConstants.columnStudentName,
        DbConstants.columnStudentRollNumber,
        DbConstants.columnStudentClassName,
      ],
      where: isSpecificClass ? '${DbConstants.columnStudentClassName} = ?' : null,
      whereArgs: isSpecificClass ? <dynamic>[className] : null,
      orderBy: isSpecificClass
          ? '${DbConstants.columnStudentRollNumber} ASC, ${DbConstants.columnStudentName} ASC'
          : '${DbConstants.columnStudentClassName} ASC, ${DbConstants.columnStudentRollNumber} ASC, ${DbConstants.columnStudentName} ASC',
    );

    // 3. Aggregate per-student counts for this month
    final String aggSql = isSpecificClass
        ? '''
          SELECT a.${DbConstants.columnAttendanceStudentId},
                 COUNT(CASE WHEN a.${DbConstants.columnAttendanceStatus} = '${DbConstants.statusPresent}' THEN 1 END) AS present_count,
                 COUNT(CASE WHEN a.${DbConstants.columnAttendanceStatus} = '${DbConstants.statusAbsent}' THEN 1 END) AS absent_count,
                 COUNT(CASE WHEN a.${DbConstants.columnAttendanceStatus} = '${DbConstants.statusLeave}' THEN 1 END) AS leave_count,
                 COUNT(*) AS total_count
          FROM ${DbConstants.tableAttendance} a
          JOIN ${DbConstants.tableStudents} s ON a.${DbConstants.columnAttendanceStudentId} = s.${DbConstants.columnId}
          WHERE s.${DbConstants.columnStudentClassName} = ? AND a.${DbConstants.columnAttendanceDate} LIKE ?
          GROUP BY a.${DbConstants.columnAttendanceStudentId}
          '''
        : '''
          SELECT a.${DbConstants.columnAttendanceStudentId},
                 COUNT(CASE WHEN a.${DbConstants.columnAttendanceStatus} = '${DbConstants.statusPresent}' THEN 1 END) AS present_count,
                 COUNT(CASE WHEN a.${DbConstants.columnAttendanceStatus} = '${DbConstants.statusAbsent}' THEN 1 END) AS absent_count,
                 COUNT(CASE WHEN a.${DbConstants.columnAttendanceStatus} = '${DbConstants.statusLeave}' THEN 1 END) AS leave_count,
                 COUNT(*) AS total_count
          FROM ${DbConstants.tableAttendance} a
          WHERE a.${DbConstants.columnAttendanceDate} LIKE ?
          GROUP BY a.${DbConstants.columnAttendanceStudentId}
          ''';
    final List<dynamic> aggArgs =
        isSpecificClass ? <dynamic>[className, monthPrefix] : <dynamic>[monthPrefix];

    final List<Map<String, dynamic>> aggRows = await _db.rawQuery(aggSql, aggArgs);

    // Map aggregated results by student_id
    final Map<int, Map<String, dynamic>> aggMap = <int, Map<String, dynamic>>{};
    for (final Map<String, dynamic> row in aggRows) {
      final int studentId = row[DbConstants.columnAttendanceStudentId] as int;
      aggMap[studentId] = row;
    }

    int totalPresentAcrossClass = 0;
    int totalAbsentAcrossClass = 0;
    int totalLeaveAcrossClass = 0;
    final List<MonthlyStudentAttendanceItem> studentSummaries = <MonthlyStudentAttendanceItem>[];

    for (final Map<String, dynamic> sRow in studentRows) {
      final int sId = sRow[DbConstants.columnId] as int;
      final String sName = (sRow[DbConstants.columnStudentName] as String?) ?? '';
      final String sRoll = (sRow[DbConstants.columnStudentRollNumber] as String?) ?? '';
      final String sClass = (sRow[DbConstants.columnStudentClassName] as String?) ?? '';

      final Map<String, dynamic>? agg = aggMap[sId];
      final int presentDays = (agg?['present_count'] as int?) ?? 0;
      final int absentDays = (agg?['absent_count'] as int?) ?? 0;
      final int leaveDays = (agg?['leave_count'] as int?) ?? 0;
      final int recordedDays = (agg?['total_count'] as int?) ?? 0;

      totalPresentAcrossClass += presentDays;
      totalAbsentAcrossClass += absentDays;
      totalLeaveAcrossClass += leaveDays;

      final int effectiveDays = presentDays + absentDays;
      final double studentPct = effectiveDays > 0
          ? (presentDays / effectiveDays) * 100.0
          : (leaveDays > 0 ? 100.0 : 0.0);

      studentSummaries.add(
        MonthlyStudentAttendanceItem(
          studentId: sId,
          studentName: sName,
          rollNumber: sRoll,
          className: sClass,
          daysPresent: presentDays,
          daysAbsent: absentDays,
          daysLeave: leaveDays,
          totalRecordedDays: recordedDays,
          attendancePercentage: studentPct,
        ),
      );
    }

    final int totalEffective = totalPresentAcrossClass + totalAbsentAcrossClass;
    final double avgClassRate = totalEffective > 0
        ? (totalPresentAcrossClass / totalEffective) * 100.0
        : (totalLeaveAcrossClass > 0 ? 100.0 : 0.0);

    final List<ClassMonthlySummaryItem> classSummaries = <ClassMonthlySummaryItem>[];
    if (!isSpecificClass) {
      final Map<String, List<MonthlyStudentAttendanceItem>> byClass =
          <String, List<MonthlyStudentAttendanceItem>>{};
      for (final MonthlyStudentAttendanceItem s in studentSummaries) {
        byClass.putIfAbsent(s.className, () => <MonthlyStudentAttendanceItem>[]).add(s);
      }

      for (final MapEntry<String, List<MonthlyStudentAttendanceItem>> entry in byClass.entries) {
        final String cName = entry.key;
        final List<MonthlyStudentAttendanceItem> cStudents = entry.value;
        int cPresent = 0;
        int cAbsent = 0;
        int cLeave = 0;
        int maxDays = 0;
        for (final MonthlyStudentAttendanceItem s in cStudents) {
          cPresent += s.daysPresent;
          cAbsent += s.daysAbsent;
          cLeave += s.daysLeave;
          if (s.totalRecordedDays > maxDays) maxDays = s.totalRecordedDays;
        }
        final int cEffective = cPresent + cAbsent;
        final double cRate = cEffective > 0
            ? (cPresent / cEffective) * 100.0
            : (cLeave > 0 ? 100.0 : 0.0);
        classSummaries.add(
          ClassMonthlySummaryItem(
            className: cName,
            totalWorkingDays: maxDays,
            totalStudents: cStudents.length,
            averageAttendanceRate: cRate,
          ),
        );
      }
      classSummaries.sort((ClassMonthlySummaryItem a, ClassMonthlySummaryItem b) => a.className.compareTo(b.className));
    }

    return MonthlyClassSummary(
      year: year,
      month: month,
      className: className,
      totalWorkingDays: totalWorkingDays,
      totalStudents: studentRows.length,
      averageAttendanceRate: avgClassRate,
      studentSummaries: studentSummaries,
      classSummaries: classSummaries,
    );
  }

  /// Fetches an individual student's monthly attendance report with day-by-day records.
  Future<StudentMonthAttendanceReport> getStudentMonthlyReport({
    required int studentId,
    required int year,
    required int month,
  }) async {
    // 1. Fetch student info
    final List<Map<String, dynamic>> studentMaps = await _db.query(
      DbConstants.tableStudents,
      where: '${DbConstants.columnId} = ?',
      whereArgs: <dynamic>[studentId],
    );
    if (studentMaps.isEmpty) {
      throw Exception('Student with id $studentId not found');
    }
    final Student student = Student.fromMap(studentMaps.first);

    // 2. Fetch recorded attendance for this student in this month
    final String monthPrefix =
        '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-%';
    final List<Map<String, dynamic>> attRows = await _db.query(
      DbConstants.tableAttendance,
      where: '${DbConstants.columnAttendanceStudentId} = ? AND ${DbConstants.columnAttendanceDate} LIKE ?',
      whereArgs: <dynamic>[studentId, monthPrefix],
    );

    final Map<String, AttendanceStatus> attendanceByDate = <String, AttendanceStatus>{};
    for (final Map<String, dynamic> row in attRows) {
      final String dateStr = row[DbConstants.columnAttendanceDate] as String;
      final String statusStr = row[DbConstants.columnAttendanceStatus] as String;
      final AttendanceStatus? status = AttendanceStatus.fromValue(statusStr);
      if (status != null) {
        attendanceByDate[dateStr] = status;
      }
    }

    // 3. Determine how many calendar days to evaluate
    final DateTime now = DateTime.now();
    final bool isCurrentMonth = (now.year == year && now.month == month);
    final int totalDaysInMonth = DateTime(year, month + 1, 0).day;

    final int lastDayToEvaluate;
    if (isCurrentMonth) {
      lastDayToEvaluate = now.day;
    } else if (DateTime(year, month).isBefore(DateTime(now.year, now.month))) {
      lastDayToEvaluate = totalDaysInMonth;
    } else {
      lastDayToEvaluate = 0;
    }

    int presentCount = 0;
    int absentCount = 0;
    int leaveCount = 0;
    int unmarkedCount = 0;
    final List<StudentDayAttendanceRecord> dayRecords = <StudentDayAttendanceRecord>[];

    // Build records latest day first (reverse chronological)
    for (int day = lastDayToEvaluate; day >= 1; day--) {
      final DateTime date = DateTime(year, month, day);
      final String iso = AppDateUtils.toIsoDate(date);
      final AttendanceStatus? status = attendanceByDate[iso];

      if (status == AttendanceStatus.present) {
        presentCount++;
      } else if (status == AttendanceStatus.absent) {
        absentCount++;
      } else if (status == AttendanceStatus.leave) {
        leaveCount++;
      } else {
        unmarkedCount++;
      }

      dayRecords.add(StudentDayAttendanceRecord(
        date: date,
        status: status,
      ));
    }

    final int effectiveDays = presentCount + absentCount;
    final double attendancePercentage = effectiveDays > 0
        ? (presentCount / effectiveDays) * 100.0
        : (leaveCount > 0 ? 100.0 : 0.0);

    return StudentMonthAttendanceReport(
      student: student,
      year: year,
      month: month,
      presentCount: presentCount,
      absentCount: absentCount,
      leaveCount: leaveCount,
      unmarkedCount: unmarkedCount,
      totalDaysEvaluated: dayRecords.length,
      attendancePercentage: attendancePercentage,
      dayRecords: dayRecords,
    );
  }
}
