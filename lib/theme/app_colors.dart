import 'package:flutter/material.dart';

/// The Hyper-Focused Lens Color System
/// Tonal Architecture for Editorial Utility
class AppColors {
  AppColors._();

  // Base Surface Hierarchy
  static const Color surface = Color(0xFF131313);
  static const Color surfaceContainerLowest = Color(0xFF0E0E0E);
  static const Color surfaceContainerLow = Color(0xFF1C1B1B);
  static const Color surfaceContainer = Color(0xFF212121);
  static const Color surfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighest = Color(0xFF353534);
  static const Color surfaceBright = Color(0xFF393939);

  // Status Palette
  static const Color primary = Color(0xFF0066FF); // Primary blue
  static const Color secondary = Color(0xFF53E16F); // Connected state
  static const Color tertiary = Color(0xFFFFB4AA); // Reconnecting/Warning
  static const Color error = Color(0xFFFFB4AB); // Disconnected/Failed

  // Status Container Variants
  static const Color tertiaryContainer = Color(0xFF8B3A2F);
  static const Color onTertiaryFixedVariant = Color(0xFFD4735B);

  // Text & Content
  static const Color onSurface = Color(0xFFE5E2E1);
  static const Color onSurfaceVariant = Color(0xFFC7C6C5);
  static const Color onSecondary = Color(0xFF003919);
  static const Color onTertiary = Color(0xFF2D1512);
  static const Color onTertiaryContainer = Color(0xFFFFDAD5);
  static const Color onError = Color(0xFF690005);

  // Outline & Ghost Borders
  static const Color outlineVariant = Color(0xFF424656);
  
  /// Ghost Border - 20% opacity for accessibility-required borders
  static Color get ghostBorder => outlineVariant.withOpacity(0.2);

  /// Glassmorphism - 60% opacity for floating controls
  static Color get glassBackground => surfaceBright.withOpacity(0.6);

  /// Status Pulse - 40% opacity for connected indicator outer ring
  static Color get connectedPulse => secondary.withOpacity(0.4);

  /// Ambient Shadow - 8% opacity for floating elements
  static Color get ambientShadow => surfaceContainerLowest.withOpacity(0.08);
}
