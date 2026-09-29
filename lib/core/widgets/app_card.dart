import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.onTap,
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color surfaceColor = color ?? theme.colorScheme.surface;
    final Color border = borderColor ?? theme.colorScheme.outline;

    final Widget content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: AppSpacing.borderRadiusCard,
        border: Border.all(color: border, width: 1),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.borderRadiusCard,
          child: content,
        ),
      );
    }

    return content;
  }
}
