import 'package:flutter/material.dart';
import 'dart:math';

class SizeUtils {
  static late double width;
  static late double height;
  static late double scaleFactor;

  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    width = mediaQuery.size.width;
    height = mediaQuery.size.height;

    scaleFactor = (width / 375).clamp(0.85, 1.15);
  }

  static double getWidth(double size) {
    return size * scaleFactor;
  }

  static double getHeight(double size) {
    return size * scaleFactor;
  }

  static double getFontSize(double size) {
    return size * scaleFactor;
  }
  
  static double getSize(double size) {
    return size * scaleFactor;
  }
  
  static EdgeInsets getPadding(EdgeInsets padding) {
    return EdgeInsets.only(
      left: padding.left * scaleFactor,
      top: padding.top * scaleFactor,
      right: padding.right * scaleFactor,
      bottom: padding.bottom * scaleFactor,
    );
  }
  
  static BorderRadius getBorderRadius(BorderRadius radius) {
    return BorderRadius.circular(radius.topLeft.x * scaleFactor);
  }
}
