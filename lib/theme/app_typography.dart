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
    fontSize: 48.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    height: 1.12,
    color: AppColors.onSurface,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.16,
    color: AppColors.onSurface,
  );

  // Headline - Participant names in call header
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
    color: AppColors.onSurface,
  );

  // Title - Section headers
  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.44,
    color: AppColors.onSurface,
  );

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
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    height: 1.43,
    color: AppColors.onSurface,
  );

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
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
    color: AppColors.onSurface,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
    color: AppColors.onSurface,
  );

  static const TextStyle bodyMediumSemiBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.25,
    height: 1.43,
    color: AppColors.onSurface,
  );

  static const TextStyle bodyMediumSecondary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle bodyMediumMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w500,
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

  static const TextStyle bodySmallBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    height: 1.33,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle bodySmallSecondary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle bodySmallHint = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    color: AppColors.onSurfaceVariantHint,
  );

  static const TextStyle bodySmallDimmed = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    color: AppColors.onSurfaceVariantDimmed,
  );

  // Display variants
  static const TextStyle displayMediumBlack = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36.0,
    fontWeight: FontWeight.w900,
    letterSpacing: 0,
    height: 1.1,
    color: AppColors.onSurface,
  );

  static const TextStyle displayMediumSecondary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 36.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.16,
    color: AppColors.secondary,
  );

  // Headline variants
  static const TextStyle headlineSmallBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.33,
    color: AppColors.onSurface,
  );

  static const TextStyle headlineSmallSecondary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
    color: AppColors.secondary,
  );

  // Title variants
  static const TextStyle titleLargeBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.44,
    color: AppColors.onSurface,
  );

  static const TextStyle titleMediumBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.15,
    height: 1.5,
    color: AppColors.onSurface,
  );

  static const TextStyle titleSmallBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    height: 1.43,
    color: AppColors.onSurface,
  );

  // Label variants
  static const TextStyle labelMediumWhite = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
    color: AppColors.white,
  );

  static const TextStyle labelSmallWhite = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
    color: AppColors.white,
  );

  static const TextStyle labelSmallPrimary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
    color: AppColors.onSurface,
  );

  static const TextStyle labelSmallSecondary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
    color: AppColors.onSurfaceVariant,
  );

  static const TextStyle labelSmallBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.45,
    color: AppColors.tertiary,
  );

  static const TextStyle labelSmallBoldPrimary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.45,
    color: AppColors.onSurface,
  );

  static const TextStyle labelSmallTimestamp = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.onSurfaceVariantDimmed,
  );

  // Permission button styles
  static const TextStyle labelMediumBoldSecondary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.33,
    color: AppColors.onSecondary,
  );

  static const TextStyle labelMediumBoldDisabled = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    height: 1.33,
    color: AppColors.onSurfaceVariant,
  );
}
