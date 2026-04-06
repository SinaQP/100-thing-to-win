import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:things_to_win/features/settings/data/models/app_settings_model.dart';
import 'package:things_to_win/features/settings/domain/entities/app_settings.dart';

abstract class SettingsLocalDataSource {
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);
  Future<ThemeMode> getThemeMode();
  Future<void> setThemeMode(ThemeMode mode);
}

class SharedPrefsSettingsDataSource implements SettingsLocalDataSource {
  SharedPrefsSettingsDataSource(this._prefs);

  final SharedPreferences _prefs;
  static const _themeModeKey = 'theme_mode';
  static const _dailyReminderEnabledKey = 'daily_reminder_enabled';
  static const _showArchivedHabitsKey = 'show_archived_habits';
  static const _hasCompletedOnboardingKey = 'has_completed_onboarding';

  @override
  Future<AppSettings> getSettings() async {
    final model = AppSettingsModel(
      themeMode: _prefs.getString(_themeModeKey) ?? 'system',
      dailyReminderEnabled: _prefs.getBool(_dailyReminderEnabledKey) ?? false,
      showArchivedHabits: _prefs.getBool(_showArchivedHabitsKey) ?? false,
      hasCompletedOnboarding: _prefs.getBool(_hasCompletedOnboardingKey) ?? false,
    );
    return model.toEntity();
  }

  @override
  Future<void> saveSettings(AppSettings settings) async {
    final model = AppSettingsModel.fromEntity(settings);
    await _prefs.setString(_themeModeKey, model.themeMode);
    await _prefs.setBool(_dailyReminderEnabledKey, model.dailyReminderEnabled);
    await _prefs.setBool(_showArchivedHabitsKey, model.showArchivedHabits);
    await _prefs.setBool(_hasCompletedOnboardingKey, model.hasCompletedOnboarding);
  }

  @override
  Future<ThemeMode> getThemeMode() async {
    final settings = await getSettings();
    return settings.themeMode;
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    final current = await getSettings();
    await saveSettings(current.copyWith(themeMode: mode));
  }
}
