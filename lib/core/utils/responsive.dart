import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';

class Responsive {
  Responsive._();

  static const double phoneBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double maxContentWidth = 960.0;

  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < phoneBreakpoint;

  static bool isTablet(BuildContext context) {
    final double width = MediaQuery.sizeOf(context).width;
    return width >= phoneBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  static EdgeInsets screenPadding(BuildContext context) {
    return EdgeInsets.symmetric(
      horizontal: isPhone(context)
          ? AppSpacing.screenPaddingPhone
          : AppSpacing.screenPaddingTablet,
      vertical: AppSpacing.md,
    );
  }

  static Widget constrained({
    required Widget child,
    double maxWidth = maxContentWidth,
    AlignmentGeometry alignment = Alignment.topCenter,
  }) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
