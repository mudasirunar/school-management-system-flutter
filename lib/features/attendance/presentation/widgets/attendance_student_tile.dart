import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../students/domain/student.dart';
import '../../domain/attendance_status.dart';

class AttendanceStudentTile extends StatelessWidget {
  const AttendanceStudentTile({
    super.key,
    required this.student,
    required this.currentStatus,
    required this.onStatusChanged,
  });

  final Student student;
  final AttendanceStatus? currentStatus;
  final ValueChanged<AttendanceStatus> onStatusChanged;

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
    final String initials = _getInitials(student.name);

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: <Widget>[
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              initials,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Name and Roll
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  student.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Roll: ${student.rollNumber}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          // Present / Absent Segmented Toggle
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // Present Button
              _StatusToggleButton(
                label: 'P',
                isSelected: currentStatus == AttendanceStatus.present,
                selectedBackground: colors.successContainer,
                selectedForeground: colors.success,
                onTap: () => onStatusChanged(AttendanceStatus.present),
              ),
              const SizedBox(width: AppSpacing.xs),
              // Absent Button
              _StatusToggleButton(
                label: 'A',
                isSelected: currentStatus == AttendanceStatus.absent,
                selectedBackground: theme.colorScheme.errorContainer,
                selectedForeground: theme.colorScheme.error,
                onTap: () => onStatusChanged(AttendanceStatus.absent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusToggleButton extends StatelessWidget {
  const _StatusToggleButton({
    required this.label,
    required this.isSelected,
    required this.selectedBackground,
    required this.selectedForeground,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color selectedBackground;
  final Color selectedForeground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? selectedBackground : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? selectedForeground : theme.colorScheme.outline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isSelected ? selectedForeground : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
