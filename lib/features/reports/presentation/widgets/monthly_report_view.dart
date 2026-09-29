import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/error_state.dart';
import '../../../../core/widgets/skeleton.dart';
import '../../domain/monthly_report_data.dart';
import '../../providers/report_providers.dart';
import 'attendance_percentage_ring.dart';

class MonthlyReportView extends ConsumerWidget {
  const MonthlyReportView({super.key});

  void _previousMonth(WidgetRef ref) {
    final DateTime current = ref.read(selectedReportMonthProvider);
    final DateTime previous = DateTime(current.year, current.month - 1);
    // Don't go before 2020
    if (previous.year >= 2020) {
      ref.read(selectedReportMonthProvider.notifier).state = previous;
    }
  }

  void _nextMonth(WidgetRef ref) {
    final DateTime current = ref.read(selectedReportMonthProvider);
    final DateTime now = DateTime.now();
    final DateTime next = DateTime(current.year, current.month + 1);

    // Don't allow future months
    if (next.year < now.year || (next.year == now.year && next.month <= now.month)) {
      ref.read(selectedReportMonthProvider.notifier).state = next;
    }
  }

  Color _resolvePercentageColor(BuildContext context, double pct) {
    if (pct >= 75.0) return context.semanticColors.success;
    if (pct >= 50.0) return context.semanticColors.warning;
    return Theme.of(context).colorScheme.error;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final DateTime selectedMonth = ref.watch(selectedReportMonthProvider);
    final String? selectedClass = ref.watch(selectedReportMonthlyClassProvider);
    final AsyncValue<MonthlyClassSummary> reportAsync = ref.watch(monthlyReportProvider);

    final DateTime now = DateTime.now();
    final bool canGoNext = selectedMonth.year < now.year ||
        (selectedMonth.year == now.year && selectedMonth.month < now.month);

    return Column(
      children: <Widget>[
        // Controls: Month Navigation & Class Dropdown
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.xs,
          ),
          child: Responsive.constrained(
            child: Row(
              children: <Widget>[
                // Month Navigation
                Expanded(
                  flex: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                      color: theme.colorScheme.surface,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded, size: 20),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          tooltip: 'Previous month',
                          onPressed: () => _previousMonth(ref),
                        ),
                        Expanded(
                          child: Text(
                            AppDateUtils.formatMonthYear(selectedMonth),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded, size: 20),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          tooltip: 'Next month',
                          onPressed: canGoNext ? () => _nextMonth(ref) : null,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Class Selector Dropdown
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outlineVariant),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                      color: theme.colorScheme.surface,
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: selectedClass,
                        isExpanded: true,
                        hint: Text(
                          'All Classes',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        icon: const Icon(Icons.arrow_drop_down),
                        items: <DropdownMenuItem<String?>>[
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text(
                              'All Classes',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          ...AppConstants.classes.map(
                            (String cls) => DropdownMenuItem<String?>(
                              value: cls,
                              child: Text(
                                cls,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                        onChanged: (String? val) {
                          ref.read(selectedReportMonthlyClassProvider.notifier).state = val;
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Report Content
        Expanded(
          child: reportAsync.when(
            loading: () => ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: const <Widget>[
                SkeletonBox(height: 180, borderRadius: AppSpacing.radiusCard),
                SizedBox(height: AppSpacing.md),
                SkeletonList(itemCount: 5),
              ],
            ),
            error: (Object err, _) => ErrorState(
              message: 'Failed to generate monthly report. Please retry.',
              onRetry: () => ref.invalidate(monthlyReportProvider),
            ),
            data: (MonthlyClassSummary summary) {
              if (summary.totalWorkingDays == 0) {
                final String classLabel = selectedClass ?? 'the school';
                return EmptyState(
                  icon: Icons.calendar_month_outlined,
                  title: 'No attendance this month',
                  message: 'No attendance records recorded for $classLabel in ${AppDateUtils.formatMonthYear(selectedMonth)}.',
                );
              }

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: <Widget>[
                  // Summary Header Card
                  Responsive.constrained(
                    child: AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          // Average Attendance Ring
                          AttendancePercentageRing(
                            percentage: summary.averageAttendanceRate,
                            size: 120,
                            strokeWidth: 10,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          // Stats
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs + 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        padding: const EdgeInsets.all(AppSpacing.xs),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.primary.withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.date_range_rounded,
                                          size: 16,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              'Working Days',
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: theme.colorScheme.onSurfaceVariant,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              '${summary.totalWorkingDays}',
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.xs + 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        padding: const EdgeInsets.all(AppSpacing.xs),
                                        decoration: BoxDecoration(
                                          color: theme.colorScheme.secondary.withValues(alpha: 0.12),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.school_rounded,
                                          size: 16,
                                          color: theme.colorScheme.secondary,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Text(
                                              'Enrolled Students',
                                              style: theme.textTheme.labelSmall?.copyWith(
                                                color: theme.colorScheme.onSurfaceVariant,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              '${summary.totalStudents}',
                                              style: theme.textTheme.titleMedium?.copyWith(
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Section Title & List (Class Breakdown if All Classes, else Student List)
                  if (selectedClass == null) ...<Widget>[
                    Responsive.constrained(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Class Performance Breakdown',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '${summary.classSummaries.length} classes',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ...summary.classSummaries.map((ClassMonthlySummaryItem cItem) {
                      final double pct = cItem.averageAttendanceRate;
                      final Color pctColor = _resolvePercentageColor(context, pct);
                      final double progress = (pct / 100.0).clamp(0.0, 1.0);

                      return Responsive.constrained(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: AppCard(
                            onTap: () {
                              ref.read(selectedReportMonthlyClassProvider.notifier).state = cItem.className;
                            },
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            cItem.className,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${cItem.totalStudents} students • ${cItem.totalWorkingDays} days recorded',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: AppSpacing.xxs + 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: pctColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
                                      ),
                                      child: Text(
                                        '${pct.toStringAsFixed(1)}%',
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: pctColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.xs),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      size: 20,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 6,
                                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                    color: pctColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ] else ...<Widget>[
                    Responsive.constrained(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Student Monthly Attendance',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '${summary.studentSummaries.length} students',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ...summary.studentSummaries.map((MonthlyStudentAttendanceItem item) {
                      final Color pctColor = _resolvePercentageColor(context, item.attendancePercentage);
                      final double progress = item.totalRecordedDays > 0
                          ? (item.daysPresent / item.totalRecordedDays).clamp(0.0, 1.0)
                          : 0.0;

                      return Responsive.constrained(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: AppCard(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            item.studentName,
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            'Roll: ${item.rollNumber} • ${item.daysPresent}/${item.totalRecordedDays} days present',
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppSpacing.sm,
                                        vertical: AppSpacing.xxs + 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: pctColor.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
                                      ),
                                      child: Text(
                                        '${item.attendancePercentage.toStringAsFixed(1)}%',
                                        style: theme.textTheme.labelMedium?.copyWith(
                                          color: pctColor,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 6,
                                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                    color: pctColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
