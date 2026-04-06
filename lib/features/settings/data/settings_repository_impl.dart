import 'package:flutter/material.dart';
import 'package:things_to_win/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:things_to_win/features/settings/domain/entities/app_settings.dart';
import 'package:things_to_win/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._localDataSource);

  final SettingsLocalDataSource _localDataSource;

  @override
  Future<AppSettings> getSettings() {
    return _localDataSource.getSettings();
  }

  @override
  Future<void> saveSettings(AppSettings settings) {
    return _localDataSource.saveSettings(settings);
  }

  @override
  Future<ThemeMode> getThemeMode() {
    return _localDataSource.getThemeMode();
  }

  @override
  Future<void> importBackup() async {
    // Will be wired in Phase 2 using document picker and file IO.
  }

  @override
  Future<void> exportBackup() async {
    // Will be wired in Phase 2 using local db dump + JSON packaging.
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) {
    return _localDataSource.setThemeMode(mode);
  }
}
