import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/utils/date_utils.dart';
import '../data/report_repository.dart';
import '../domain/daily_report_data.dart';
import '../domain/monthly_report_data.dart';

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
