import 'package:flutter/material.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme_extension.dart';

class AttendancePercentageRing extends StatelessWidget {
  final double percentage; // 0.0 to 100.0
  final double size;
  final double strokeWidth;

  const AttendancePercentageRing({
    super.key,
    required this.percentage,
    this.size = 140,
    this.strokeWidth = 12,
  });

  Color _resolveColor(BuildContext context, double value) {
    if (value >= 75.0) {
      return context.semanticColors.success;
    } else if (value >= 50.0) {
      return context.semanticColors.warning;
    } else {
      return Theme.of(context).colorScheme.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double safePct = percentage.clamp(0.0, 100.0);
    final double progress = safePct / 100.0;
    final Color progressColor = _resolveColor(context, safePct);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          // Background track
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              color: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
          // Progress arc
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              strokeCap: StrokeCap.round,
              color: progressColor,
            ),
          ),
          // Center Text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '${safePct.toStringAsFixed(1)}%',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: size * 0.19,
                  color: progressColor,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Attendance',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
