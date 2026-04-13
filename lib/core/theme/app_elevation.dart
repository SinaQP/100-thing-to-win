import 'package:flutter/material.dart';

class AppElevation {
  const AppElevation._();

  static const double flat = 0;
  static const double subtle = 8;
  static const double raised = 18;

  static List<BoxShadow> soft(
    Color shadowColor, {
    double opacity = 0.08,
    double blur = 28,
    Offset offset = const Offset(0, 16),
  }) {
    return [
      BoxShadow(
        color: shadowColor.withValues(alpha: opacity),
        blurRadius: blur,
        offset: offset,
      ),
      BoxShadow(
        color: shadowColor.withValues(alpha: opacity * 0.45),
        blurRadius: blur * 0.55,
        offset: Offset(0, offset.dy * 0.5),
      ),
    ];
  }
}
