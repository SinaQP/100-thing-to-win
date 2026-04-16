import 'package:flutter/material.dart';
import 'package:things_to_win/core/theme/app_colors.dart';
import 'package:things_to_win/core/theme/app_elevation.dart';
import 'package:things_to_win/core/theme/app_radii.dart';
import 'package:things_to_win/core/theme/app_spacing.dart';
import 'package:things_to_win/core/theme/app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(AppColors.light);
  static ThemeData get dark => _build(AppColors.dark);

  static ThemeData _build(AppThemeColors colors) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: colors.isDark ? Brightness.dark : Brightness.light,
      surface: colors.surface,
    );

    final colorScheme = baseScheme.copyWith(
      primary: colors.accent,
      onPrimary: colors.onAccent,
      primaryContainer: colors.accentSoft,
      onPrimaryContainer: colors.textPrimary,
      secondary: colors.accentStrong,
      onSecondary: colors.onAccent,
      secondaryContainer: colors.surfaceElevated,
      onSecondaryContainer: colors.textPrimary,
      tertiary: colors.warning,
      onTertiary: colors.textPrimary,
      error: colors.error,
      surface: colors.surface,
      onSurface: colors.textPrimary,
      onSurfaceVariant: colors.textSecondary,
      outline: colors.border,
      outlineVariant: colors.divider,
      shadow: colors.shadow,
      surfaceTint: Colors.transparent,
      inverseSurface: colors.textPrimary,
      onInverseSurface: colors.background,
      inversePrimary: colors.accentSoft,
    );

    final textTheme = AppTypography.buildTextTheme(colors);
    final inputBorder = OutlineInputBorder(
      borderRadius: AppRadii.input,
      borderSide: BorderSide(color: colors.border),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colors.background,
      extensions: [colors],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: colors.textPrimary,
        elevation: AppElevation.flat,
        scrolledUnderElevation: AppElevation.flat,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: AppElevation.flat,
        color: colors.card,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surfaceElevated,
        hintStyle: textTheme.bodyMedium?.copyWith(color: colors.textMuted),
        labelStyle: textTheme.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.accent, width: 1.2),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: colors.error, width: 1.2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 56),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.md,
          ),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.button),
          elevation: AppElevation.flat,
          foregroundColor: colors.onAccent,
          backgroundColor: colors.accent,
          disabledBackgroundColor: colors.accent.withValues(alpha: 0.45),
          disabledForegroundColor: colors.onAccent.withValues(alpha: 0.72),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.button),
          side: BorderSide(color: colors.border),
          foregroundColor: colors.textPrimary,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          textStyle: textTheme.labelLarge,
          foregroundColor: colors.textPrimary,
          shape: RoundedRectangleBorder(borderRadius: AppRadii.button),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.cardMuted,
        selectedColor: colors.accentSoft,
        secondarySelectedColor: colors.accentSoft,
        disabledColor: colors.cardMuted.withValues(alpha: 0.6),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        shape: StadiumBorder(side: BorderSide(color: colors.border)),
        side: BorderSide(color: colors.border),
        labelStyle: textTheme.labelMedium!,
        secondaryLabelStyle:
            textTheme.labelMedium!.copyWith(color: colors.accentStrong),
        brightness: colors.isDark ? Brightness.dark : Brightness.light,
        checkmarkColor: colors.accent,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors.surfaceElevated,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: colors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.button),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.accent,
        linearTrackColor: colors.progressTrack,
        circularTrackColor: colors.progressTrack,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surfaceElevated
            .withValues(alpha: colors.isDark ? 0.96 : 0.94),
        indicatorColor: colors.accentSoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return (selected ? textTheme.labelMedium : textTheme.labelSmall)
              ?.copyWith(
            color: selected ? colors.textPrimary : colors.textMuted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
              color: selected ? colors.accent : colors.textMuted);
        }),
        elevation: AppElevation.flat,
        height: 74,
        surfaceTintColor: Colors.transparent,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surfaceElevated,
        elevation: AppElevation.flat,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.card),
        surfaceTintColor: Colors.transparent,
        textStyle: textTheme.bodyMedium?.copyWith(color: colors.textPrimary),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        side: BorderSide(color: colors.border),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colors.accent;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(colors.onAccent),
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        iconColor: colors.textSecondary,
      ),
      dividerTheme: DividerThemeData(
        color: colors.divider,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceElevated,
        modalBackgroundColor: colors.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.panel),
        showDragHandle: true,
      ),
    );
  }
}
