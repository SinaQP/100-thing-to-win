import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:things_to_win/features/settings/data/datasources/settings_backup_local_data_source.dart';
import 'package:things_to_win/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:things_to_win/features/settings/data/models/app_backup_payload_model.dart';
import 'package:things_to_win/features/settings/data/models/backup_merge_model.dart';
import 'package:things_to_win/features/settings/domain/entities/app_backup.dart';
import 'package:things_to_win/features/settings/domain/entities/app_settings.dart';
import 'package:things_to_win/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  SettingsRepositoryImpl(this._localDataSource, this._backupDataSource);

  final SettingsLocalDataSource _localDataSource;
  final SettingsBackupLocalDataSource _backupDataSource;

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
  Future<BackupImportResult> importBackup({
    required String filePath,
    required BackupImportMode mode,
  }) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw const BackupValidationException(
          'Selected backup file was not found.');
    }

    final rawJson = await file.readAsString();
    final payload = AppBackupPayloadModel.fromJsonString(rawJson);

    final incomingSnapshot = BackupDatabaseSnapshot(
      habits: payload.habits,
      habitEntries: payload.habitEntries,
    );
    final existingSnapshot = await _backupDataSource.readSnapshot();

    final resolvedSnapshot = mergeOrReplaceSnapshot(
      mode: mode,
      existing: existingSnapshot,
      incoming: incomingSnapshot,
    );

    await _backupDataSource.overwriteSnapshot(resolvedSnapshot);

    return BackupImportResult(
      mode: mode,
      habitsCount: resolvedSnapshot.habits.length,
      habitEntriesCount: resolvedSnapshot.habitEntries.length,
    );
  }

  @override
  Future<BackupExportResult> exportBackup() async {
    final snapshot = await _backupDataSource.readSnapshot();
    final now = DateTime.now();
    final payload = AppBackupPayloadModel(
      version: backupSchemaVersion,
      exportedAt: now,
      habits: snapshot.habits,
      habitEntries: snapshot.habitEntries,
    );

    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(directory.path, 'backups'));
    await backupDir.create(recursive: true);

    final timestamp =
        '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final path = p.join(backupDir.path, 'things_to_win_backup_$timestamp.json');
    final file = File(path);
    await file.writeAsString(payload.toJsonString());

    return BackupExportResult(
      filePath: path,
      exportedAt: now,
      habitsCount: snapshot.habits.length,
      habitEntriesCount: snapshot.habitEntries.length,
    );
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) {
    return _localDataSource.setThemeMode(mode);
  }
}
