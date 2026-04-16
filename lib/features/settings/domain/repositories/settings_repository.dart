import 'package:flutter/material.dart';
import 'package:things_to_win/features/settings/domain/entities/app_backup.dart';
import 'package:things_to_win/features/settings/domain/entities/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);

  Future<ThemeMode> getThemeMode();
  Future<void> setThemeMode(ThemeMode mode);

  Future<BackupExportResult> exportBackup();
  Future<BackupImportResult> importBackup({
    required String filePath,
    required BackupImportMode mode,
  });
}
