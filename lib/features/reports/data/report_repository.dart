import 'package:sqflite/sqflite.dart';
import '../../../core/constants/db_constants.dart';
import '../../attendance/domain/attendance_status.dart';
import '../domain/daily_report_data.dart';
import '../domain/monthly_report_data.dart';

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
    final List<DailyStudentAttendanceItem> studentItems = <DailyStudentAttendanceItem>[];

    for (final Map<String, dynamic> row in rows) {
      final String statusStr = row[DbConstants.columnAttendanceStatus] as String;
      final AttendanceStatus status =
          AttendanceStatus.fromValue(statusStr) ?? AttendanceStatus.absent;

      if (status == AttendanceStatus.present) {
        presentCount++;
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
    final double percentage = total > 0 ? (presentCount / total) * 100.0 : 0.0;

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
      final int cAbsent = cTotal - cPresent;
      final double cPct = cTotal > 0 ? (cPresent / cTotal) * 100.0 : 0.0;
      classSummaries.add(
        ClassDailySummaryItem(
          className: entry.key,
          totalStudents: cTotal,
          presentCount: cPresent,
          absentCount: cAbsent,
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
    int totalRecordedAcrossClass = 0;
    final List<MonthlyStudentAttendanceItem> studentSummaries = <MonthlyStudentAttendanceItem>[];

    for (final Map<String, dynamic> sRow in studentRows) {
      final int sId = sRow[DbConstants.columnId] as int;
      final String sName = (sRow[DbConstants.columnStudentName] as String?) ?? '';
      final String sRoll = (sRow[DbConstants.columnStudentRollNumber] as String?) ?? '';
      final String sClass = (sRow[DbConstants.columnStudentClassName] as String?) ?? '';

      final Map<String, dynamic>? agg = aggMap[sId];
      final int presentDays = (agg?['present_count'] as int?) ?? 0;
      final int absentDays = (agg?['absent_count'] as int?) ?? 0;
      final int recordedDays = (agg?['total_count'] as int?) ?? 0;

      totalPresentAcrossClass += presentDays;
      totalRecordedAcrossClass += recordedDays;

      final double studentPct =
          recordedDays > 0 ? (presentDays / recordedDays) * 100.0 : 0.0;

      studentSummaries.add(
        MonthlyStudentAttendanceItem(
          studentId: sId,
          studentName: sName,
          rollNumber: sRoll,
          className: sClass,
          daysPresent: presentDays,
          daysAbsent: absentDays,
          totalRecordedDays: recordedDays,
          attendancePercentage: studentPct,
        ),
      );
    }

    final double avgClassRate = totalRecordedAcrossClass > 0
        ? (totalPresentAcrossClass / totalRecordedAcrossClass) * 100.0
        : 0.0;

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
        int cRecorded = 0;
        int maxDays = 0;
        for (final MonthlyStudentAttendanceItem s in cStudents) {
          cPresent += s.daysPresent;
          cRecorded += s.totalRecordedDays;
          if (s.totalRecordedDays > maxDays) maxDays = s.totalRecordedDays;
        }
        final double cRate = cRecorded > 0 ? (cPresent / cRecorded) * 100.0 : 0.0;
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
}
