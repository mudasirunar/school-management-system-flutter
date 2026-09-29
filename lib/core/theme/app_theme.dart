import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_theme.dart';
import 'app_theme_extension.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final ColorScheme colorScheme = AppColors.lightColorScheme;
    final TextTheme textTheme = AppTextTheme.createTextTheme(
      AppColors.lightTextPrimary,
      AppColors.lightTextSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      textTheme: textTheme,
      fontFamily: AppTextTheme.fontFamily,
      extensions: const <ThemeExtension<dynamic>>[
        AppSemanticColors.light,
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusCard,
          side: const BorderSide(color: AppColors.lightOutline, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusInput,
          borderSide: const BorderSide(color: AppColors.lightOutline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusInput,
          borderSide: const BorderSide(color: AppColors.lightOutline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusInput,
          borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusInput,
          borderSide: const BorderSide(color: AppColors.lightError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusInput,
          borderSide: const BorderSide(color: AppColors.lightError, width: 2),
        ),
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.lightTextSecondary.withAlpha(180)),
        errorStyle: textTheme.bodySmall?.copyWith(color: AppColors.lightError),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightOnPrimary,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusButton),
          textStyle: textTheme.labelLarge?.copyWith(color: AppColors.lightOnPrimary),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: AppColors.lightOutline),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusButton),
          textStyle: textTheme.labelLarge?.copyWith(color: AppColors.lightPrimary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusButton),
          textStyle: textTheme.labelLarge,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusDialog),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 4,
        shape: AppSpacing.shapeBottomSheet,
        showDragHandle: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.lightPrimaryContainer,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelMedium?.copyWith(
              color: AppColors.lightPrimary,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelMedium?.copyWith(color: AppColors.lightTextSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.lightOnPrimaryContainer, size: 24);
          }
          return const IconThemeData(color: AppColors.lightTextSecondary, size: 24);
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightSurface,
        disabledColor: AppColors.lightSurfaceVariant,
        selectedColor: AppColors.lightPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusChip,
          side: const BorderSide(color: AppColors.lightOutline, width: 1),
        ),
        labelStyle: textTheme.labelMedium?.copyWith(color: AppColors.lightTextPrimary),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(color: AppColors.lightOnPrimaryContainer),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightOutline,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    final ColorScheme colorScheme = AppColors.darkColorScheme;
    final TextTheme textTheme = AppTextTheme.createTextTheme(
      AppColors.darkTextPrimary,
      AppColors.darkTextSecondary,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: textTheme,
      fontFamily: AppTextTheme.fontFamily,
      extensions: const <ThemeExtension<dynamic>>[
        AppSemanticColors.dark,
      ],
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusCard,
          side: const BorderSide(color: AppColors.darkOutline, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusInput,
          borderSide: const BorderSide(color: AppColors.darkOutline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusInput,
          borderSide: const BorderSide(color: AppColors.darkOutline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusInput,
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusInput,
          borderSide: const BorderSide(color: AppColors.darkError, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusInput,
          borderSide: const BorderSide(color: AppColors.darkError, width: 2),
        ),
        labelStyle: textTheme.bodyMedium,
        hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.darkTextSecondary.withAlpha(180)),
        errorStyle: textTheme.bodySmall?.copyWith(color: AppColors.darkError),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkOnPrimary,
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusButton),
          textStyle: textTheme.labelLarge?.copyWith(color: AppColors.darkOnPrimary),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: AppColors.darkOutline),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusButton),
          textStyle: textTheme.labelLarge?.copyWith(color: AppColors.darkPrimary),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusButton),
          textStyle: textTheme.labelLarge,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusDialog),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 4,
        shape: AppSpacing.shapeBottomSheet,
        showDragHandle: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.darkPrimaryContainer,
        elevation: 0,
        height: 64,
        labelTextStyle: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return textTheme.labelMedium?.copyWith(
              color: AppColors.darkPrimary,
              fontWeight: FontWeight.w600,
            );
          }
          return textTheme.labelMedium?.copyWith(color: AppColors.darkTextSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.darkOnPrimaryContainer, size: 24);
          }
          return const IconThemeData(color: AppColors.darkTextSecondary, size: 24);
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurface,
        disabledColor: AppColors.darkSurfaceVariant,
        selectedColor: AppColors.darkPrimaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusChip,
          side: const BorderSide(color: AppColors.darkOutline, width: 1),
        ),
        labelStyle: textTheme.labelMedium?.copyWith(color: AppColors.darkTextPrimary),
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(color: AppColors.darkOnPrimaryContainer),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xxs),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkOutline,
        thickness: 1,
        space: 1,
      ),
    );
  }
}
