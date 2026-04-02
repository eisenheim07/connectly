import 'package:flutter/material.dart';

class SizeUtils {
  static late double width;
  static late double height;
  static late double textScaleFactor;

  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    width = mediaQuery.size.width;
    height = mediaQuery.size.height;
    textScaleFactor = mediaQuery.textScaleFactor;
  }

  static double getWidth(double size) {
    return (size / 375) * width;
  }

  static double getHeight(double size) {
    return (size / 812) * height;
  }

  static double getFontSize(double size) {
    return (size / 375) * width;
  }
}
