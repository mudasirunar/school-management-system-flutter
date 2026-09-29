import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/db_constants.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme_extension.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/error_state.dart';
import '../../../core/widgets/skeleton.dart';
import '../../activity/domain/activity_entry.dart';
import '../../attendance/presentation/attendance_records_screen.dart';
import '../../reports/presentation/widgets/attendance_percentage_ring.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../shell/navigation_provider.dart';
import '../domain/dashboard_data.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  IconData _getActivityIcon(String type) {
    switch (type) {
      case DbConstants.activityStudentAdded:
      case DbConstants.activityStudentUpdated:
      case DbConstants.activityStudentDeleted:
        return Icons.people_outline_rounded;
      case DbConstants.activityTeacherAdded:
      case DbConstants.activityTeacherUpdated:
      case DbConstants.activityTeacherDeleted:
        return Icons.badge_outlined;
      case DbConstants.activityAttendanceSaved:
        return Icons.fact_check_outlined;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _getActivityColor(BuildContext context, String type) {
    final ThemeData theme = Theme.of(context);
    switch (type) {
      case DbConstants.activityStudentDeleted:
      case DbConstants.activityTeacherDeleted:
        return theme.colorScheme.error;
      case DbConstants.activityStudentAdded:
      case DbConstants.activityTeacherAdded:
      case DbConstants.activityAttendanceSaved:
        return context.semanticColors.success;
      default:
        return theme.colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final String todayFormatted = AppDateUtils.formatForDisplay(DateTime.now());
    final AsyncValue<DashboardData> dashboardAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            Icon(Icons.school_rounded, color: theme.colorScheme.primary, size: 24),
            const SizedBox(width: AppSpacing.xs),
            const Text(AppConstants.appName),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: dashboardAsync.when(
          loading: () => ListView(
            padding: Responsive.screenPadding(context),
            children: const <Widget>[
              SkeletonBox(height: 50, borderRadius: AppSpacing.radiusCard),
              SizedBox(height: AppSpacing.md),
              Row(
                children: <Widget>[
                  Expanded(child: SkeletonBox(height: 100, borderRadius: AppSpacing.radiusCard)),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(child: SkeletonBox(height: 100, borderRadius: AppSpacing.radiusCard)),
                ],
              ),
              SizedBox(height: AppSpacing.md),
              SkeletonBox(height: 140, borderRadius: AppSpacing.radiusCard),
              SizedBox(height: AppSpacing.md),
              SkeletonList(itemCount: 4),
            ],
          ),
          error: (Object err, _) => ErrorState(
            message: 'Failed to load dashboard data. Please try again.',
            onRetry: () => ref.invalidate(dashboardDataProvider),
          ),
          data: (DashboardData data) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: Responsive.screenPadding(context),
              child: Responsive.constrained(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // 1. Welcome Greeting Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Welcome back',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              todayFormatted,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // 2. Primary Stat Cards (Students & Teachers)
                    Row(
                      children: <Widget>[
                        // Total Students Card
                        Expanded(
                          child: AppCard(
                            onTap: () {
                              ref.read(navigationIndexProvider.notifier).state = 1;
                            },
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.all(AppSpacing.xs),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.school_rounded,
                                        color: theme.colorScheme.onPrimaryContainer,
                                        size: 20,
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: theme.colorScheme.onSurfaceVariant,
                                      size: 18,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  '${data.totalStudents}',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Total Students',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        // Total Teachers Card
                        Expanded(
                          child: AppCard(
                            onTap: () {
                              ref.read(navigationIndexProvider.notifier).state = 2;
                            },
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      padding: const EdgeInsets.all(AppSpacing.xs),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.secondaryContainer,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.badge_rounded,
                                        color: theme.colorScheme.onSecondaryContainer,
                                        size: 20,
                                      ),
                                    ),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: theme.colorScheme.onSurfaceVariant,
                                      size: 18,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  '${data.totalTeachers}',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Total Teachers',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),

                    // 3. Today's Attendance Overview Card
                    if (data.hasAttendanceToday)
                      AppCard(
                        onTap: () {
                          ref.read(navigationIndexProvider.notifier).state = 4;
                        },
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: <Widget>[
                            AttendancePercentageRing(
                              percentage: data.todayAttendanceRate,
                              size: 96,
                              strokeWidth: 8,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        "Today's Attendance",
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.chevron_right_rounded,
                                        color: theme.colorScheme.onSurfaceVariant,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${data.todayPresentCount} Present • ${data.todayAbsentCount} Absent',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${data.todayTotalMarked} students marked across classes',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      AppCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: <Widget>[
                            Container(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              decoration: BoxDecoration(
                                color: context.semanticColors.warning.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.pending_actions_rounded,
                                color: context.semanticColors.warning,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    'Attendance Not Marked',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'No attendance recorded for today yet.',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FilledButton.tonal(
                              onPressed: () {
                                ref.read(navigationIndexProvider.notifier).state = 3;
                              },
                              child: const Text('Mark Now'),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: AppSpacing.lg),

                    // 4. Quick Actions Section
                    Text(
                      'Quick Actions',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.people_outline_rounded,
                            label: 'Students',
                            onTap: () {
                              ref.read(navigationIndexProvider.notifier).state = 1;
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.badge_outlined,
                            label: 'Teachers',
                            onTap: () {
                              ref.read(navigationIndexProvider.notifier).state = 2;
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.bar_chart_rounded,
                            label: 'Reports',
                            onTap: () {
                              ref.read(navigationIndexProvider.notifier).state = 4;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.fact_check_outlined,
                            label: 'Mark Attendance',
                            onTap: () {
                              ref.read(navigationIndexProvider.notifier).state = 3;
                            },
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.history_rounded,
                            label: 'View Attendance',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
                                      const AttendanceRecordsScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // 5. Recent Activity Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Recent Activity',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (data.recentActivities.isNotEmpty)
                          Text(
                            'Last ${data.recentActivities.length} events',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),

                    if (data.recentActivities.isEmpty)
                      AppCard(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xl,
                          horizontal: AppSpacing.lg,
                        ),
                        child: Center(
                          child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.history_rounded,
                                size: 36,
                                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'No recent activity',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Actions like adding students or saving attendance will appear here.',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      AppCard(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: data.recentActivities.length,
                          separatorBuilder: (BuildContext context, int index) => const Divider(
                            height: 1,
                            indent: 52,
                            endIndent: AppSpacing.md,
                          ),
                          itemBuilder: (BuildContext context, int index) {
                            final ActivityEntry entry = data.recentActivities[index];
                            final Color iconColor = _getActivityColor(context, entry.type);
                            final IconData iconData = _getActivityIcon(entry.type);

                            return ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.xxs,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(AppSpacing.xs),
                                decoration: BoxDecoration(
                                  color: iconColor.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  iconData,
                                  color: iconColor,
                                  size: 16,
                                ),
                              ),
                              title: Text(
                                entry.message,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              trailing: Text(
                                AppDateUtils.timeAgo(entry.createdAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 11,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.xs,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(AppSpacing.xs + 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
            ),
            child: Icon(
              icon,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            maxLines: 2,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
    );
  }
}
