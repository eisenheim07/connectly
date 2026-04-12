import 'package:flutter/material.dart';
import 'app_colors.dart';

/// The Hyper-Focused Lens Typography System
/// Editorial Authority with Inter font family
class AppTypography {
  AppTypography._();

  // Default font family and weights
  static const String fontFamily = 'Inter';
  static const String _defaultFontFamily = 'Inter';
  static const FontWeight _defaultFontWeight = FontWeight.w400;

  // Display text styles (largest)
  static TextStyle displayLarge({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 48.0,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color ?? AppColors.onSurface,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? -0.25,
      height: height ?? 1.12,
    );
  }

  static TextStyle displayMedium({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 36.0,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color ?? AppColors.onSurface,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0,
      height: height ?? 1.16,
    );
  }

  static TextStyle displayMediumBlack({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 36.0,
      fontWeight: fontWeight ?? FontWeight.w900,
      color: color ?? AppColors.onSurface,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0,
      height: height ?? 1.1,
    );
  }

  static TextStyle displayMediumSecondary({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 36.0,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color ?? AppColors.secondary,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0,
      height: height ?? 1.16,
    );
  }

  // Headline text styles
  static TextStyle headlineSmall({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 22.0,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color ?? AppColors.onSurface,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0,
      height: height ?? 1.33,
    );
  }

  static TextStyle headlineSmallBold({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 22.0,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color ?? AppColors.onSurface,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0,
      height: height ?? 1.33,
    );
  }

  static TextStyle headlineSmallSecondary({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 22.0,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color ?? AppColors.secondary,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0,
      height: height ?? 1.33,
    );
  }

  // Title text styles
  static TextStyle titleLarge({Color? color, FontWeight? fontWeight, String? fontFamily, double? fontSize, double? letterSpacing, double? height}) {
    return TextStyle(
      fontSize: fontSize ?? 18.0,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color ?? AppColors.onSurface,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0,
      height: height ?? 1.44,
    );
  }

  static TextStyle titleLargeBold({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 18.0,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color ?? AppColors.onSurface,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0,
      height: height ?? 1.44,
    );
  }

  static TextStyle titleMedium({Color? color, FontWeight? fontWeight, String? fontFamily, double? fontSize, double? letterSpacing, double? height}) {
    return TextStyle(
      fontSize: fontSize ?? 16.0,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color ?? AppColors.onSurface,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.15,
      height: height ?? 1.5,
    );
  }

  static TextStyle titleMediumBold({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 16.0,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color ?? AppColors.onSurface,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.15,
      height: height ?? 1.5,
    );
  }

  static TextStyle titleSmall({Color? color, FontWeight? fontWeight, String? fontFamily, double? fontSize, double? letterSpacing, double? height}) {
    return TextStyle(
      fontSize: fontSize ?? 14.0,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color ?? AppColors.onSurface,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.1,
      height: height ?? 1.43,
    );
  }

  static TextStyle titleSmallBold({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 14.0,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color ?? AppColors.onSurface,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.1,
      height: height ?? 1.43,
    );
  }

  // Body text styles (most common)
  static TextStyle bodyLarge({Color? color, FontWeight? fontWeight, String? fontFamily, double? fontSize, double? letterSpacing, double? height}) {
    return TextStyle(
      fontSize: fontSize ?? 16.0,
      fontWeight: fontWeight ?? _defaultFontWeight,
      color: color ?? AppColors.onSurface,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.5,
      height: height ?? 1.5,
    );
  }

  static TextStyle bodyMedium({Color? color, FontWeight? fontWeight, String? fontFamily, double? fontSize, double? letterSpacing, double? height}) {
    return TextStyle(
      fontSize: fontSize ?? 14.0,
      fontWeight: fontWeight ?? _defaultFontWeight,
      color: color ?? AppColors.onSurface,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.25,
      height: height ?? 1.43,
    );
  }

  static TextStyle bodyMediumSemiBold({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 14.0,
      fontWeight: fontWeight ?? FontWeight.w600,
      color: color ?? AppColors.onSurface,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.25,
      height: height ?? 1.43,
    );
  }

  static TextStyle bodyMediumSecondary({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 14.0,
      fontWeight: fontWeight ?? _defaultFontWeight,
      color: color ?? AppColors.onSurfaceVariant,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.25,
      height: height ?? 1.43,
    );
  }

  static TextStyle bodyMediumMedium({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 14.0,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color ?? AppColors.onSurface,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.25,
      height: height ?? 1.43,
    );
  }

  static TextStyle bodySmall({Color? color, FontWeight? fontWeight, String? fontFamily, double? fontSize, double? letterSpacing, double? height}) {
    return TextStyle(
      fontSize: fontSize ?? 12.0,
      fontWeight: fontWeight ?? _defaultFontWeight,
      color: color ?? AppColors.onSurfaceVariant,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.4,
      height: height ?? 1.33,
    );
  }

  static TextStyle bodySmallBold({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 12.0,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color ?? AppColors.onSurfaceVariant,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.4,
      height: height ?? 1.33,
    );
  }

  static TextStyle bodySmallSecondary({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 12.0,
      fontWeight: fontWeight ?? _defaultFontWeight,
      color: color ?? AppColors.onSurfaceVariant,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.4,
      height: height ?? 1.33,
    );
  }

  static TextStyle bodySmallHint({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 12.0,
      fontWeight: fontWeight ?? _defaultFontWeight,
      color: color ?? AppColors.onSurfaceVariantHint,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.4,
      height: height ?? 1.33,
    );
  }

  static TextStyle bodySmallDimmed({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 12.0,
      fontWeight: fontWeight ?? _defaultFontWeight,
      color: color ?? AppColors.onSurfaceVariantDimmed,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.4,
      height: height ?? 1.33,
    );
  }

  // Label text styles (smallest)
  static TextStyle labelLarge({Color? color, FontWeight? fontWeight, String? fontFamily, double? fontSize, double? letterSpacing, double? height}) {
    return TextStyle(
      fontSize: fontSize ?? 14.0,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color ?? AppColors.onSurface,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.1,
      height: height ?? 1.43,
    );
  }

  static TextStyle labelMedium({Color? color, FontWeight? fontWeight, String? fontFamily, double? fontSize, double? letterSpacing, double? height}) {
    return TextStyle(
      fontSize: fontSize ?? 12.0,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color ?? AppColors.onSurface,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.5,
      height: height ?? 1.33,
    );
  }

  static TextStyle labelMediumWhite({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 12.0,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color ?? AppColors.white,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.5,
      height: height ?? 1.33,
    );
  }

  static TextStyle labelMediumBoldSecondary({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 14.0,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color ?? AppColors.onSecondary,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.5,
      height: height ?? 1.33,
    );
  }

  static TextStyle labelMediumBoldDisabled({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 14.0,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color ?? AppColors.onSurfaceVariant,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.5,
      height: height ?? 1.33,
    );
  }

  static TextStyle labelSmall({Color? color, FontWeight? fontWeight, String? fontFamily, double? fontSize, double? letterSpacing, double? height}) {
    return TextStyle(
      fontSize: fontSize ?? 11.0,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color ?? AppColors.onSurfaceVariant,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.5,
      height: height ?? 1.45,
    );
  }

  static TextStyle labelSmallWhite({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 11.0,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color ?? AppColors.white,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.5,
      height: height ?? 1.45,
    );
  }

  static TextStyle labelSmallPrimary({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 11.0,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color ?? AppColors.onSurface,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.5,
      height: height ?? 1.45,
    );
  }

  static TextStyle labelSmallSecondary({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 11.0,
      fontWeight: fontWeight ?? FontWeight.w500,
      color: color ?? AppColors.onSurfaceVariant,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.5,
      height: height ?? 1.45,
    );
  }

  static TextStyle labelSmallBold({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 11.0,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color ?? AppColors.tertiary,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.5,
      height: height ?? 1.45,
    );
  }

  static TextStyle labelSmallBoldPrimary({
    Color? color,
    FontWeight? fontWeight,
    String? fontFamily,
    double? fontSize,
    double? letterSpacing,
    double? height,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 11.0,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color ?? AppColors.onSurface,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 0.5,
      height: height ?? 1.45,
    );
  }

  static TextStyle labelSmallTimestamp({Color? color, FontWeight? fontWeight, String? fontFamily, double? fontSize, double? letterSpacing}) {
    return TextStyle(
      fontSize: fontSize ?? 10.0,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color ?? AppColors.onSurfaceVariantDimmed,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing ?? 1.2,
    );
  }

  // Utility method to create custom text style with all defaults
  static TextStyle custom({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    String? fontFamily,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    return TextStyle(
      fontSize: fontSize ?? 14.0,
      fontWeight: fontWeight ?? _defaultFontWeight,
      color: color ?? AppColors.onSurface,
      fontFamily: fontFamily ?? _defaultFontFamily,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
    );
  }
}
