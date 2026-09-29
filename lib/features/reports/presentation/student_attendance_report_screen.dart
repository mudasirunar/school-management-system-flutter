import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/status_chip.dart';
import '../../students/domain/student.dart';
import '../domain/student_attendance_report.dart';
import '../providers/report_providers.dart';
import 'widgets/attendance_percentage_ring.dart';

class StudentAttendanceReportScreen extends ConsumerStatefulWidget {
  const StudentAttendanceReportScreen({
    super.key,
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.className,
    this.initialMonth,
  });

  factory StudentAttendanceReportScreen.fromStudent({
    Key? key,
    required Student student,
    DateTime? initialMonth,
  }) {
    return StudentAttendanceReportScreen(
      key: key,
      studentId: student.id!,
      studentName: student.name,
      rollNumber: student.rollNumber,
      className: student.className,
      initialMonth: initialMonth,
    );
  }

  final int studentId;
  final String studentName;
  final String rollNumber;
  final String className;
  final DateTime? initialMonth;

  @override
  ConsumerState<StudentAttendanceReportScreen> createState() =>
      _StudentAttendanceReportScreenState();
}

class _StudentAttendanceReportScreenState
    extends ConsumerState<StudentAttendanceReportScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _selectedMonth = widget.initialMonth ?? DateTime(now.year, now.month);
  }

  bool get _canGoNext {
    final DateTime now = DateTime.now();
    return _selectedMonth.year < now.year ||
        (_selectedMonth.year == now.year && _selectedMonth.month < now.month);
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    if (!_canGoNext) return;
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  Future<void> _pickMonth() async {
    final DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year, now.month),
      helpText: 'Select Month',
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month);
      });
    }
  }

  static String _getInitials(String name) {
    final List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppSemanticColors colors = context.semanticColors;

    final StudentReportQuery query = StudentReportQuery(
      studentId: widget.studentId,
      year: _selectedMonth.year,
      month: _selectedMonth.month,
    );

    final AsyncValue<StudentMonthAttendanceReport> reportAsync =
        ref.watch(studentMonthlyReportProvider(query));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Report'),
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: <Widget>[
            // 1. Student Identity Header
            Responsive.constrained(
              child: AppCard(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        _getInitials(widget.studentName),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            widget.studentName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  widget.className,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                              Text(
                                'Roll No: ${widget.rollNumber}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // 2. Month Selector Navigation Bar
            Responsive.constrained(
              child: AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded),
                      tooltip: 'Previous Month',
                      onPressed: _previousMonth,
                    ),
                    InkWell(
                      onTap: _pickMonth,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.calendar_month_rounded,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              AppDateUtils.formatMonthYear(_selectedMonth),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_drop_down_rounded,
                              size: 20,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded),
                      tooltip: 'Next Month',
                      onPressed: _canGoNext ? _nextMonth : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // 3. Report Data Section
            reportAsync.when(
              loading: () => Responsive.constrained(
                child: const Column(
                  children: <Widget>[
                    SkeletonBox(height: 180, width: double.infinity, borderRadius: 12),
                    SizedBox(height: AppSpacing.md),
                    SkeletonList(itemCount: 6),
                  ],
                ),
              ),
              error: (Object err, _) => Responsive.constrained(
                child: ErrorState(
                  message: 'Failed to load report for this month.',
                  onRetry: () => ref.invalidate(studentMonthlyReportProvider(query)),
                ),
              ),
              data: (StudentMonthAttendanceReport report) {
                if (report.dayRecords.isEmpty) {
                  return Responsive.constrained(
                    child: EmptyState(
                      icon: Icons.event_busy_rounded,
                      title: 'No Days Evaluated',
                      message:
                          'No calendar days to display for ${AppDateUtils.formatMonthYear(_selectedMonth)}.',
                    ),
                  );
                }

                return Responsive.constrained(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // Summary Ring + Stat Badges
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                AttendancePercentageRing(
                                  percentage: report.attendancePercentage,
                                  size: 110,
                                  strokeWidth: 9,
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: _buildMetricTile(
                                              label: 'Present',
                                              value: '${report.presentCount}',
                                              color: colors.success,
                                              bgColor: colors.successContainer,
                                              icon: Icons.check_circle_outline_rounded,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.xs),
                                          Expanded(
                                            child: _buildMetricTile(
                                              label: 'Leave',
                                              value: '${report.leaveCount}',
                                              color: colors.warning,
                                              bgColor: colors.warningContainer,
                                              icon: Icons.event_busy_outlined,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: AppSpacing.xs),
                                      Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: _buildMetricTile(
                                              label: 'Absent',
                                              value: '${report.absentCount}',
                                              color: theme.colorScheme.error,
                                              bgColor: theme.colorScheme.errorContainer,
                                              icon: Icons.cancel_outlined,
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.xs),
                                          Expanded(
                                            child: _buildMetricTile(
                                              label: 'Pending',
                                              value: '${report.unmarkedCount}',
                                              color: theme.colorScheme.onSurfaceVariant,
                                              bgColor: theme.colorScheme.surfaceContainerHighest,
                                              icon: Icons.help_outline_rounded,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            // Informational banner about Leave calculation
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: colors.warningContainer.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: colors.warning.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: 15,
                                    color: colors.warning,
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Text(
                                      'Leave days are excused and not counted against the attendance %.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: colors.warning,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Section Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Day-by-Day Log',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${report.dayRecords.length} days',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),

                      // Day-by-Day List
                      ...report.dayRecords.map((StudentDayAttendanceRecord item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                          child: _buildDayRow(context, item),
                        );
                      }),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile({
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayRow(BuildContext context, StudentDayAttendanceRecord item) {
    final ThemeData theme = Theme.of(context);
    final String dateStr = AppDateUtils.formatShortForDisplay(item.date);
    final String dayOfWeek = _getDayOfWeek(item.date);

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${item.date.day}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    dateStr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    dayOfWeek,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatusChip.fromString(item.status?.value),
        ],
      ),
    );
  }

  static String _getDayOfWeek(DateTime date) {
    const List<String> days = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }
}
