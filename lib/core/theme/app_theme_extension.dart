import 'package:flutter/material.dart';
import 'app_colors.dart';

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.successContainer,
    required this.warning,
    required this.warningContainer,
  });

  final Color success;
  final Color successContainer;
  final Color warning;
  final Color warningContainer;

  static const AppSemanticColors light = AppSemanticColors(
    success: AppColors.lightSuccess,
    successContainer: AppColors.lightSuccessContainer,
    warning: AppColors.lightWarning,
    warningContainer: AppColors.lightWarningContainer,
  );

  static const AppSemanticColors dark = AppSemanticColors(
    success: AppColors.darkSuccess,
    successContainer: AppColors.darkSuccessContainer,
    warning: AppColors.darkWarning,
    warningContainer: AppColors.darkWarningContainer,
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? successContainer,
    Color? warning,
    Color? warningContainer,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      warningContainer: warningContainer ?? this.warningContainer,
    );
  }

  @override
  AppSemanticColors lerp(ThemeExtension<AppSemanticColors>? other, double t) {
    if (other is! AppSemanticColors) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t) ?? success,
      successContainer: Color.lerp(successContainer, other.successContainer, t) ?? successContainer,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t) ?? warningContainer,
    );
  }
}

extension AppSemanticColorsExtension on BuildContext {
  AppSemanticColors get semanticColors {
    return Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.light;
  }
}
