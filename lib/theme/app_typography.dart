import 'package:flutter/material.dart';
import 'app_colors.dart';

/// The Hyper-Focused Lens Typography System
/// Editorial Authority with Inter font family
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Inter';

  // Display - Large scale status and countdowns
  static const TextStyle displayLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 57.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.12,
    color: AppColors.onSurface,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 45.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.16,
    color: AppColors.onSurface,
  );

  // Headline - Participant names in call header
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
    color: AppColors.onSurface,
  );

  // Title - Section headers
  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
    color: AppColors.onSurface,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
    color: AppColors.onSurface,
  );

  // Label - Button captions and utility text
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
    color: AppColors.onSurface,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
    color: AppColors.onSurfaceVariant,
  );

  // Body - General content
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
    color: AppColors.onSurface,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    color: AppColors.onSurfaceVariant,
  );
}
