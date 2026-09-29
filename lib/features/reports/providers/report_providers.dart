import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/utils/date_utils.dart';
import '../data/report_repository.dart';
import '../domain/daily_report_data.dart';
import '../domain/monthly_report_data.dart';
import '../domain/student_attendance_report.dart';

final Provider<ReportRepository> reportRepositoryProvider = Provider<ReportRepository>((Ref ref) {
  final AsyncValue<Database> dbAsync = ref.watch(databaseProvider);
  return ReportRepository(dbAsync.requireValue);
});

/// Selected date for Daily Report
final StateProvider<DateTime> selectedReportDateProvider = StateProvider<DateTime>((Ref ref) {
  return DateTime.now();
});

/// Selected class filter for Daily Report (null means all classes)
final StateProvider<String?> selectedReportDailyClassProvider = StateProvider<String?>((Ref ref) {
  return null;
});

/// Selected Year/Month for Monthly Report
final StateProvider<DateTime> selectedReportMonthProvider = StateProvider<DateTime>((Ref ref) {
  final DateTime now = DateTime.now();
  return DateTime(now.year, now.month);
});

/// Selected class for Monthly Report (null means all classes)
final StateProvider<String?> selectedReportMonthlyClassProvider = StateProvider<String?>((Ref ref) {
  return null;
});

/// Daily report provider that automatically re-evaluates when date or class changes
final AutoDisposeFutureProvider<DailyClassSummary> dailyReportProvider =
    FutureProvider.autoDispose<DailyClassSummary>((Ref ref) async {
  final ReportRepository repo = ref.watch(reportRepositoryProvider);
  final DateTime date = ref.watch(selectedReportDateProvider);
  final String? className = ref.watch(selectedReportDailyClassProvider);

  return repo.getDailySummary(
    date: AppDateUtils.toIsoDate(date),
    className: className,
  );
});

/// Parameter query for fetching a student's monthly attendance report
class StudentReportQuery {
  final int studentId;
  final int year;
  final int month;

  const StudentReportQuery({
    required this.studentId,
    required this.year,
    required this.month,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StudentReportQuery &&
          runtimeType == other.runtimeType &&
          studentId == other.studentId &&
          year == other.year &&
          month == other.month;

  @override
  int get hashCode => Object.hash(studentId, year, month);
}

/// Monthly report provider that automatically re-evaluates when month or class changes
final AutoDisposeFutureProvider<MonthlyClassSummary> monthlyReportProvider =
    FutureProvider.autoDispose<MonthlyClassSummary>((Ref ref) async {
  final ReportRepository repo = ref.watch(reportRepositoryProvider);
  final DateTime monthDate = ref.watch(selectedReportMonthProvider);
  final String? className = ref.watch(selectedReportMonthlyClassProvider);

  return repo.getMonthlySummary(
    year: monthDate.year,
    month: monthDate.month,
    className: className,
  );
});

/// Individual student monthly report provider
final AutoDisposeFutureProviderFamily<StudentMonthAttendanceReport, StudentReportQuery>
    studentMonthlyReportProvider =
    FutureProvider.autoDispose.family<StudentMonthAttendanceReport, StudentReportQuery>(
  (Ref ref, StudentReportQuery query) async {
    final ReportRepository repo = ref.watch(reportRepositoryProvider);
    return repo.getStudentMonthlyReport(
      studentId: query.studentId,
      year: query.year,
      month: query.month,
    );
  },
);
