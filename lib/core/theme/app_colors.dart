import 'package:flutter/material.dart';

@immutable
class AppThemeColors extends ThemeExtension<AppThemeColors> {
  const AppThemeColors({
    required this.isDark,
    required this.background,
    required this.backgroundSubtle,
    required this.backgroundGlow,
    required this.surface,
    required this.surfaceElevated,
    required this.card,
    required this.cardMuted,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.accent,
    required this.accentSoft,
    required this.accentStrong,
    required this.onAccent,
    required this.success,
    required this.warning,
    required this.error,
    required this.border,
    required this.divider,
    required this.progressTrack,
    required this.shadow,
  });

  final bool isDark;
  final Color background;
  final Color backgroundSubtle;
  final Color backgroundGlow;
  final Color surface;
  final Color surfaceElevated;
  final Color card;
  final Color cardMuted;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color accent;
  final Color accentSoft;
  final Color accentStrong;
  final Color onAccent;
  final Color success;
  final Color warning;
  final Color error;
  final Color border;
  final Color divider;
  final Color progressTrack;
  final Color shadow;

  LinearGradient get pageGradient => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [background, backgroundSubtle],
      );

  LinearGradient get accentGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [accent, accentStrong],
      );

  @override
  AppThemeColors copyWith({
    bool? isDark,
    Color? background,
    Color? backgroundSubtle,
    Color? backgroundGlow,
    Color? surface,
    Color? surfaceElevated,
    Color? card,
    Color? cardMuted,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    Color? accent,
    Color? accentSoft,
    Color? accentStrong,
    Color? onAccent,
    Color? success,
    Color? warning,
    Color? error,
    Color? border,
    Color? divider,
    Color? progressTrack,
    Color? shadow,
  }) {
    return AppThemeColors(
      isDark: isDark ?? this.isDark,
      background: background ?? this.background,
      backgroundSubtle: backgroundSubtle ?? this.backgroundSubtle,
      backgroundGlow: backgroundGlow ?? this.backgroundGlow,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      card: card ?? this.card,
      cardMuted: cardMuted ?? this.cardMuted,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      accentStrong: accentStrong ?? this.accentStrong,
      onAccent: onAccent ?? this.onAccent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      border: border ?? this.border,
      divider: divider ?? this.divider,
      progressTrack: progressTrack ?? this.progressTrack,
      shadow: shadow ?? this.shadow,
    );
  }

  @override
  AppThemeColors lerp(ThemeExtension<AppThemeColors>? other, double t) {
    if (other is! AppThemeColors) {
      return this;
    }

    return AppThemeColors(
      isDark: t < 0.5 ? isDark : other.isDark,
      background: Color.lerp(background, other.background, t)!,
      backgroundSubtle:
          Color.lerp(backgroundSubtle, other.backgroundSubtle, t)!,
      backgroundGlow: Color.lerp(backgroundGlow, other.backgroundGlow, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      card: Color.lerp(card, other.card, t)!,
      cardMuted: Color.lerp(cardMuted, other.cardMuted, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentStrong: Color.lerp(accentStrong, other.accentStrong, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      progressTrack: Color.lerp(progressTrack, other.progressTrack, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
    );
  }
}

class AppColors {
  const AppColors._();

  static const seed = Color(0xFF2FB36E);

  static const light = AppThemeColors(
    isDark: false,
    background: Color(0xFFF6F2EA),
    backgroundSubtle: Color(0xFFFDFBF7),
    backgroundGlow: Color(0xFFE9D7BC),
    surface: Color(0xFFFDF9F3),
    surfaceElevated: Color(0xFFFFFFFF),
    card: Color(0xFFFFFFFF),
    cardMuted: Color(0xFFF5EFE4),
    textPrimary: Color(0xFF1F241F),
    textSecondary: Color(0xFF586157),
    textMuted: Color(0xFF7A837A),
    accent: Color(0xFF2FB36E),
    accentSoft: Color(0xFFD9F5E5),
    accentStrong: Color(0xFF1D8D56),
    onAccent: Color(0xFFFFFFFF),
    success: Color(0xFF2F9D60),
    warning: Color(0xFFE8A349),
    error: Color(0xFFC25656),
    border: Color(0xFFE8DED0),
    divider: Color(0xFFF0E7DA),
    progressTrack: Color(0xFFE7EEE8),
    shadow: Color(0xFF151916),
  );

  static const dark = AppThemeColors(
    isDark: true,
    background: Color(0xFF101714),
    backgroundSubtle: Color(0xFF141D18),
    backgroundGlow: Color(0xFF2A4F3A),
    surface: Color(0xFF17211C),
    surfaceElevated: Color(0xFF1C2822),
    card: Color(0xFF1B261F),
    cardMuted: Color(0xFF223129),
    textPrimary: Color(0xFFF4F1E8),
    textSecondary: Color(0xFFB8C4BA),
    textMuted: Color(0xFF8A978D),
    accent: Color(0xFF54D58C),
    accentSoft: Color(0xFF183824),
    accentStrong: Color(0xFF7BE6A8),
    onAccent: Color(0xFF0E1712),
    success: Color(0xFF61D694),
    warning: Color(0xFFF3B86E),
    error: Color(0xFFFF8C8C),
    border: Color(0xFF2B3A31),
    divider: Color(0xFF233027),
    progressTrack: Color(0xFF253229),
    shadow: Color(0xFF000000),
  );
}

extension AppThemeDataX on ThemeData {
  AppThemeColors get appColors => extension<AppThemeColors>()!;
}

extension AppThemeContextX on BuildContext {
  AppThemeColors get appColors => Theme.of(this).appColors;
}
