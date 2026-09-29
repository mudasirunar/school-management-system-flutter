import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_extension.dart';

class AttendanceSummaryStrip extends StatelessWidget {
  const AttendanceSummaryStrip({
    super.key,
    required this.presentCount,
    required this.absentCount,
    this.leaveCount = 0,
    required this.unmarkedCount,
    required this.totalStudents,
    required this.isSavedRecord,
  });

  final int presentCount;
  final int absentCount;
  final int leaveCount;
  final int unmarkedCount;
  final int totalStudents;
  final bool isSavedRecord;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppSemanticColors colors = context.semanticColors;

    final int effectiveTotal = presentCount + absentCount;
    final int markedTotal = presentCount + absentCount + leaveCount;
    final double percentage = effectiveTotal > 0
        ? (presentCount / effectiveTotal) * 100
        : (leaveCount > 0 ? 100.0 : 0.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppSpacing.borderRadiusCard,
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header Row: Summary Title & Saved Record Badge / Percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Class Summary',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (isSavedRecord)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Saved record',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                )
              else if (markedTotal > 0)
                Text(
                  '${percentage.toStringAsFixed(1)}% Present',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colors.success,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          // Status Counts Wrap (wraps cleanly without overflow on any screen)
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xxs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              _buildStatusCount(
                label: 'Present',
                count: presentCount,
                color: colors.success,
                icon: Icons.check_circle_rounded,
              ),
              _buildStatusCount(
                label: 'Leave',
                count: leaveCount,
                color: colors.warning,
                icon: Icons.event_busy_rounded,
              ),
              _buildStatusCount(
                label: 'Absent',
                count: absentCount,
                color: theme.colorScheme.error,
                icon: Icons.cancel_rounded,
              ),
              if (unmarkedCount > 0)
                _buildStatusCount(
                  label: 'Pending',
                  count: unmarkedCount,
                  color: theme.colorScheme.onSurfaceVariant,
                  icon: Icons.help_outline_rounded,
                ),
            ],
          ),
          if (markedTotal > 0) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: markedTotal / (totalStudents > 0 ? totalStudents : 1),
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(colors.success),
                minHeight: 4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCount({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 16, color: color),
        const SizedBox(width: AppSpacing.xxs),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
