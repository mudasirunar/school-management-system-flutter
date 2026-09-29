import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme_extension.dart';

enum AttendanceChipStatus {
  present,
  absent,
  unmarked,
}

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
    this.compact = false,
  });

  final AttendanceChipStatus status;
  final bool compact;

  factory StatusChip.fromString(String? statusString, {bool compact = false}) {
    switch (statusString?.toLowerCase()) {
      case 'present':
        return StatusChip(status: AttendanceChipStatus.present, compact: compact);
      case 'absent':
        return StatusChip(status: AttendanceChipStatus.absent, compact: compact);
      default:
        return StatusChip(status: AttendanceChipStatus.unmarked, compact: compact);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppSemanticColors colors = context.semanticColors;

    final (Color background, Color foreground, IconData icon, String label) = switch (status) {
      AttendanceChipStatus.present => (
          colors.successContainer,
          colors.success,
          Icons.check_circle_outline_rounded,
          'Present'
        ),
      AttendanceChipStatus.absent => (
          Theme.of(context).colorScheme.errorContainer,
          Theme.of(context).colorScheme.error,
          Icons.cancel_outlined,
          'Absent'
        ),
      AttendanceChipStatus.unmarked => (
          colors.warningContainer,
          colors.warning,
          Icons.help_outline_rounded,
          'Not Marked'
        ),
    };

    return Semantics(
      label: 'Status: $label',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppSpacing.xs : AppSpacing.sm,
          vertical: compact ? 2 : AppSpacing.xxs,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppSpacing.borderRadiusChip,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: compact ? 12 : 14, color: foreground),
            const SizedBox(width: AppSpacing.xxs),
            Text(
              label,
              style: TextStyle(
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w600,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
