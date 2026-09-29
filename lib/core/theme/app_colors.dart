import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Light Palette
  static const Color lightPrimary = Color(0xFF2F4A9E);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightPrimaryContainer = Color(0xFFE6EBF8);
  static const Color lightOnPrimaryContainer = Color(0xFF1C2F6B);
  static const Color lightAccent = Color(0xFFF2A93B);
  static const Color lightBackground = Color(0xFFF6F7FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEEF0F6);
  static const Color lightOutline = Color(0xFFE3E6EE);
  static const Color lightTextPrimary = Color(0xFF1B2333);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightSuccess = Color(0xFF2E8B57);
  static const Color lightSuccessContainer = Color(0xFFE4F3EA);
  static const Color lightError = Color(0xFFD64545);
  static const Color lightErrorContainer = Color(0xFFFBE7E7);
  static const Color lightWarning = Color(0xFFE39B2D);
  static const Color lightWarningContainer = Color(0xFFFEF3E2);

  // Dark Palette
  static const Color darkPrimary = Color(0xFF8FA5F0);
  static const Color darkOnPrimary = Color(0xFF0F1A3D);
  static const Color darkPrimaryContainer = Color(0xFF24305C);
  static const Color darkOnPrimaryContainer = Color(0xFFDCE3FB);
  static const Color darkAccent = Color(0xFFF2B45A);
  static const Color darkBackground = Color(0xFF0F131A);
  static const Color darkSurface = Color(0xFF171C26);
  static const Color darkSurfaceVariant = Color(0xFF1F2531);
  static const Color darkOutline = Color(0xFF2A3140);
  static const Color darkTextPrimary = Color(0xFFE7EAF0);
  static const Color darkTextSecondary = Color(0xFF9AA3B2);
  static const Color darkSuccess = Color(0xFF4CC38A);
  static const Color darkSuccessContainer = Color(0xFF173326);
  static const Color darkError = Color(0xFFF07178);
  static const Color darkErrorContainer = Color(0xFF3A1D20);
  static const Color darkWarning = Color(0xFFEBAE55);
  static const Color darkWarningContainer = Color(0xFF3B2C16);

  static ColorScheme get lightColorScheme => const ColorScheme(
        brightness: Brightness.light,
        primary: lightPrimary,
        onPrimary: lightOnPrimary,
        primaryContainer: lightPrimaryContainer,
        onPrimaryContainer: lightOnPrimaryContainer,
        secondary: lightPrimary,
        onSecondary: lightOnPrimary,
        secondaryContainer: lightPrimaryContainer,
        onSecondaryContainer: lightOnPrimaryContainer,
        tertiary: lightAccent,
        onTertiary: Colors.black,
        error: lightError,
        onError: Colors.white,
        errorContainer: lightErrorContainer,
        onErrorContainer: lightError,
        surface: lightSurface,
        onSurface: lightTextPrimary,
        surfaceContainerHighest: lightSurfaceVariant,
        onSurfaceVariant: lightTextSecondary,
        outline: lightOutline,
      );

  static ColorScheme get darkColorScheme => const ColorScheme(
        brightness: Brightness.dark,
        primary: darkPrimary,
        onPrimary: darkOnPrimary,
        primaryContainer: darkPrimaryContainer,
        onPrimaryContainer: darkOnPrimaryContainer,
        secondary: darkPrimary,
        onSecondary: darkOnPrimary,
        secondaryContainer: darkPrimaryContainer,
        onSecondaryContainer: darkOnPrimaryContainer,
        tertiary: darkAccent,
        onTertiary: Colors.black,
        error: darkError,
        onError: Colors.white,
        errorContainer: darkErrorContainer,
        onErrorContainer: darkError,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        surfaceContainerHighest: darkSurfaceVariant,
        onSurfaceVariant: darkTextSecondary,
        outline: darkOutline,
      );
}
