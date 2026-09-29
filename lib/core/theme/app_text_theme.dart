import 'package:flutter/material.dart';

class AppTextTheme {
  AppTextTheme._();

  static const String fontFamily = 'Inter';
  static const List<String> fontFallbacks = <String>['Roboto', 'sans-serif'];

  static TextTheme createTextTheme(Color primaryTextColor, Color secondaryTextColor) {
    return TextTheme(
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        letterSpacing: -0.3,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
        letterSpacing: -0.2,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryTextColor,
        height: 1.4,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondaryTextColor,
        height: 1.4,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryTextColor,
        height: 1.3,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryTextColor,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontFamilyFallback: fontFallbacks,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
      ),
    );
  }
}
