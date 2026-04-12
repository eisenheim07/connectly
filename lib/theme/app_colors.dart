import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color surface = Color(0xFF131313);
  static const Color surfaceContainerLowest = Color(0xFF0E0E0E);
  static const Color surfaceContainerLow = Color(0xFF1C1B1B);
  static const Color surfaceContainer = Color(0xFF212121);
  static const Color surfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighest = Color(0xFF353534);
  static const Color surfaceBright = Color(0xFF393939);

  static const Color primary = Color(0xFF0066FF);
  static const Color secondary = Color(0xFF53E16F);
  static const Color tertiary = Color(0xFFFFB4AA);
  static const Color error = Color(0xFFFFB4AB);

  static const Color statusSuccess = Color(0xFF4CAF50);
  static const Color statusWarning = Color(0xFFFFA726);
  static const Color statusError = Color(0xFFF44336);
  static const Color statusInfo = Color(0xFFFDD835);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  static const Color onSurfaceVariantDimmed = Color(0x99C7C6C5);
  static const Color onSurfaceVariantHint = Color(0x80C7C6C5);
  static const Color onSurfaceMediumEmphasis = Color(0xCCE5E2E1);
  static const Color whiteMediumEmphasis = Color(0xE6FFFFFF);

  static const Color blue = Color(0xFF2196F3);
  static const Color red = Color(0xFFF44336);
  static const Color orange = Color(0xFFFF9800);
  static const Color yellow = Color(0xFFFFC107);
  static const Color green = Color(0xFF4CAF50);
  static const Color purple = Color(0xFF9C27B0);
  static const Color teal = Color(0xFF009688);
  static const Color amber = Color(0xFFFFC107);
  static const Color deepOrange = Color(0xFFFF5722);
  static const Color indigo = Color(0xFF3F51B5);
  static const Color grey = Color(0xFF9E9E9E);

  static const Color tertiaryContainer = Color(0xFF8B3A2F);
  static const Color onTertiaryFixedVariant = Color(0xFFD4735B);

  static const Color onSurface = Color(0xFFE5E2E1);
  static const Color onSurfaceVariant = Color(0xFFC7C6C5);
  static const Color onSecondary = Color(0xFF003919);
  static const Color onTertiary = Color(0xFF2D1512);
  static const Color onTertiaryContainer = Color(0xFFFFDAD5);
  static const Color onError = Color(0xFF690005);

  static const Color outlineVariant = Color(0xFF424656);
  
  static Color get ghostBorder => outlineVariant.withOpacity(0.2);

  static Color get glassBackground => surfaceBright.withOpacity(0.6);

  static Color get connectedPulse => secondary.withOpacity(0.4);

  static Color get ambientShadow => surfaceContainerLowest.withOpacity(0.08);
}
