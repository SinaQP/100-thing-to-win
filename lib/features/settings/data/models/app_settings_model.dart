import 'package:flutter/material.dart';
import 'package:things_to_win/features/settings/domain/entities/app_settings.dart';

class AppSettingsModel {
  const AppSettingsModel({
    required this.themeMode,
    required this.dailyReminderEnabled,
    required this.showArchivedHabits,
    required this.hasCompletedOnboarding,
  });

  final String themeMode;
  final bool dailyReminderEnabled;
  final bool showArchivedHabits;
  final bool hasCompletedOnboarding;

  AppSettings toEntity() {
    return AppSettings(
      themeMode: _themeModeFromString(themeMode),
      dailyReminderEnabled: dailyReminderEnabled,
      showArchivedHabits: showArchivedHabits,
      hasCompletedOnboarding: hasCompletedOnboarding,
    );
  }

  factory AppSettingsModel.fromEntity(AppSettings settings) {
    return AppSettingsModel(
      themeMode: _themeModeToString(settings.themeMode),
      dailyReminderEnabled: settings.dailyReminderEnabled,
      showArchivedHabits: settings.showArchivedHabits,
      hasCompletedOnboarding: settings.hasCompletedOnboarding,
    );
  }

  static ThemeMode _themeModeFromString(String raw) {
    return switch (raw) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static String _themeModeToString(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }
}
