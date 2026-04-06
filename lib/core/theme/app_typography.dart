import 'package:flutter/material.dart';

class AppTypography {
  const AppTypography._();

  static TextTheme buildTextTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return TextTheme(
      displaySmall: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: isDark ? Colors.white : const Color(0xFF111414),
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: isDark ? Colors.white : const Color(0xFF111414),
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : const Color(0xFF111414),
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: isDark ? const Color(0xFFE3ECE7) : const Color(0xFF1B2621),
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.4,
        color: isDark ? const Color(0xFFC3CEC8) : const Color(0xFF304038),
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: isDark ? const Color(0xFFE6F2EC) : const Color(0xFF163025),
      ),
    );
  }
}
