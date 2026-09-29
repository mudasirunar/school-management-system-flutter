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
import '../../../../core/widgets/status_chip.dart';
import '../../../attendance/domain/attendance_status.dart';
import '../../domain/daily_report_data.dart';
import '../../providers/report_providers.dart';
import 'attendance_percentage_ring.dart';

class DailyReportView extends ConsumerWidget {
  const DailyReportView({super.key});

  Future<void> _pickDate(BuildContext context, WidgetRef ref) async {
    final DateTime currentDate = ref.read(selectedReportDateProvider);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      ref.read(selectedReportDateProvider.notifier).state = picked;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final DateTime selectedDate = ref.watch(selectedReportDateProvider);
    final String? selectedClass = ref.watch(selectedReportDailyClassProvider);
    final AsyncValue<DailyClassSummary> reportAsync = ref.watch(dailyReportProvider);

    final Color successColor = context.semanticColors.success;
    final Color errorColor = theme.colorScheme.error;

    return Column(
      children: <Widget>[
        // Controls: Date Picker & Class Filter
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
                // Date Button
                Expanded(
                  flex: 5,
                  child: InkWell(
                    onTap: () => _pickDate(context, ref),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs + 2,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.outlineVariant),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                        color: theme.colorScheme.surface,
                      ),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.calendar_today_rounded, size: 16, color: theme.colorScheme.primary),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              AppDateUtils.formatIsoForDisplay(AppDateUtils.toIsoDate(selectedDate)),
                              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, size: 20),
                        ],
                      ),
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
                            child: Text('All Classes', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                          ...AppConstants.classes.map(
                            (String cls) => DropdownMenuItem<String?>(
                              value: cls,
                              child: Text(cls),
                            ),
                          ),
                        ],
                        onChanged: (String? val) {
                          ref.read(selectedReportDailyClassProvider.notifier).state = val;
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
              message: 'Failed to generate daily report. Please retry.',
              onRetry: () => ref.invalidate(dailyReportProvider),
            ),
            data: (DailyClassSummary summary) {
              if (summary.isEmpty) {
                return const EmptyState(
                  icon: Icons.pie_chart_outline_rounded,
                  title: 'No attendance records',
                  message: 'No attendance recorded for the selected date and class filter.',
                );
              }

              return ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: <Widget>[
                  // Summary Header Card
                  Responsive.constrained(
                    child: AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              // Percentage Gauge Ring
                              AttendancePercentageRing(
                                percentage: summary.attendancePercentage,
                                size: 120,
                                strokeWidth: 10,
                              ),
                              const SizedBox(width: AppSpacing.md),
                              // Metric Totals
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
                                              Icons.groups_rounded,
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
                                                  'Total Marked',
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
                                    const SizedBox(height: AppSpacing.xs),
                                    Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.sm,
                                              vertical: AppSpacing.xs,
                                            ),
                                            decoration: BoxDecoration(
                                              color: successColor.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  'Present',
                                                  style: theme.textTheme.labelSmall?.copyWith(
                                                    color: successColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  '${summary.presentCount}',
                                                  style: theme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color: successColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Expanded(
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: AppSpacing.sm,
                                              vertical: AppSpacing.xs,
                                            ),
                                            decoration: BoxDecoration(
                                              color: errorColor.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                Text(
                                                  'Absent',
                                                  style: theme.textTheme.labelSmall?.copyWith(
                                                    color: errorColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                Text(
                                                  '${summary.absentCount}',
                                                  style: theme.textTheme.titleMedium?.copyWith(
                                                    fontWeight: FontWeight.w700,
                                                    color: errorColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
                    ...summary.classSummaries.map((ClassDailySummaryItem cItem) {
                      final double pct = cItem.attendancePercentage;
                      final Color pctColor = pct >= 75.0
                          ? context.semanticColors.success
                          : (pct >= 50.0 ? context.semanticColors.warning : theme.colorScheme.error);
                      final double progress = cItem.totalStudents > 0
                          ? (cItem.presentCount / cItem.totalStudents).clamp(0.0, 1.0)
                          : 0.0;

                      return Responsive.constrained(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: AppCard(
                            onTap: () {
                              ref.read(selectedReportDailyClassProvider.notifier).state = cItem.className;
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
                                            '${cItem.presentCount}/${cItem.totalStudents} present • ${cItem.absentCount} absent',
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
                              'Student Breakdown',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '${summary.students.length} students',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    ...summary.students.map((DailyStudentAttendanceItem item) {
                      return Responsive.constrained(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: AppCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md,
                              vertical: AppSpacing.sm,
                            ),
                            child: Row(
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
                                        '${item.className} • Roll: ${item.rollNumber}',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                StatusChip(
                                  status: item.status == AttendanceStatus.present
                                      ? AttendanceChipStatus.present
                                      : AttendanceChipStatus.absent,
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
