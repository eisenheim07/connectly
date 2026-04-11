import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// The Hyper-Focused Lens Theme
/// Editorial Utility for Professional Video Communication
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppTypography.fontFamily,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        surfaceContainerLowest: AppColors.surfaceContainerLowest,
        surfaceContainerLow: AppColors.surfaceContainerLow,
        surfaceContainer: AppColors.surfaceContainer,
        surfaceContainerHigh: AppColors.surfaceContainerHigh,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        surfaceBright: AppColors.surfaceBright,
        outline: AppColors.outlineVariant,
        outlineVariant: AppColors.outlineVariant,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.surface,

      // App Bar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.headlineSmall,
      ),

      // Text Theme
      textTheme: const TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        headlineSmall: AppTypography.headlineSmall,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
      ),

      // Card Theme - Tonal Layering (No borders)
      cardTheme: CardThemeData(
        color: AppColors.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        margin: EdgeInsets.zero,
      ),

      // Input Decoration - No borders, background shifts
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: BorderSide(
            color: AppColors.ghostBorder,
            width: 1.0,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        hintStyle: AppTypography.bodyMediumSecondary,
      ),

      // Elevated Button - Primary Actions
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.tertiaryContainer,
          foregroundColor: AppColors.onTertiaryContainer,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.0),
          ),
          minimumSize: const Size(64.0, 64.0),
          padding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 16.0,
          ),
          textStyle: AppTypography.labelMedium,
        ),
      ),

      // Text Button - Utility actions
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          textStyle: AppTypography.labelMedium,
        ),
      ),

      // Icon Button - Call controls
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.onSurface,
          minimumSize: const Size(64.0, 64.0),
        ),
      ),

      // Floating Action Button - End call button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.tertiaryContainer,
        foregroundColor: AppColors.onTertiaryContainer,
        elevation: 0,
        shape: CircleBorder(),
        sizeConstraints: BoxConstraints.tightFor(
          width: 64.0,
          height: 64.0,
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: AppColors.ghostBorder,
        thickness: 0,
        space: 8.0,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.0),
        ),
      ),

      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surfaceContainerHigh,
        modalBackgroundColor: AppColors.surfaceContainerHigh,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28.0),
          ),
        ),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.surfaceContainerHighest,
        contentTextStyle: AppTypography.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
    );
  }
}
