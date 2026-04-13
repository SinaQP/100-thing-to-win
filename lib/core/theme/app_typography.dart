import 'package:flutter/material.dart';
import 'package:things_to_win/core/theme/app_colors.dart';

class AppTypography {
  const AppTypography._();

  static TextTheme buildTextTheme(AppThemeColors colors) {
    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 42,
        height: 1.05,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.2,
        color: colors.textPrimary,
      ),
      displayMedium: TextStyle(
        fontSize: 36,
        height: 1.08,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: colors.textPrimary,
      ),
      displaySmall: TextStyle(
        fontSize: 30,
        height: 1.12,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.6,
        color: colors.textPrimary,
      ),
      headlineLarge: TextStyle(
        fontSize: 26,
        height: 1.16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: colors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        height: 1.18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: colors.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 18,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        height: 1.25,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        height: 1.25,
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        height: 1.45,
        fontWeight: FontWeight.w500,
        color: colors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.55,
        fontWeight: FontWeight.w400,
        color: colors.textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        height: 1.45,
        fontWeight: FontWeight.w500,
        color: colors.textMuted,
      ),
      labelLarge: TextStyle(
        fontSize: 15,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: colors.textPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 13,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: colors.textSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: 11,
        height: 1.15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: colors.textMuted,
      ),
    );
  }
}
