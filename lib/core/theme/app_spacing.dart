import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();

  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double sm = 12.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Screen Padding
  static const double screenPaddingPhone = 16.0;
  static const double screenPaddingTablet = 24.0;

  // Radii
  static const double radiusChip = 8.0;
  static const double radiusButton = 10.0;
  static const double radiusInput = 10.0;
  static const double radiusCard = 12.0;
  static const double radiusDialog = 16.0;
  static const double radiusBottomSheet = 20.0;

  // Borders
  static final BorderRadius borderRadiusChip = BorderRadius.circular(radiusChip);
  static final BorderRadius borderRadiusButton = BorderRadius.circular(radiusButton);
  static final BorderRadius borderRadiusInput = BorderRadius.circular(radiusInput);
  static final BorderRadius borderRadiusCard = BorderRadius.circular(radiusCard);
  static final BorderRadius borderRadiusDialog = BorderRadius.circular(radiusDialog);
  static const BorderRadius borderRadiusBottomSheet = BorderRadius.vertical(
    top: Radius.circular(radiusBottomSheet),
  );
  static const RoundedRectangleBorder shapeBottomSheet = RoundedRectangleBorder(
    borderRadius: borderRadiusBottomSheet,
  );
}
