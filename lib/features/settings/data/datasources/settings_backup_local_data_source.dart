import 'package:sqflite/sqflite.dart';
import 'package:things_to_win/features/habits/data/models/habit_entry_model.dart';
import 'package:things_to_win/features/habits/data/models/habit_model.dart';
import 'package:things_to_win/features/settings/data/models/backup_merge_model.dart';

class SettingsBackupLocalDataSource {
  SettingsBackupLocalDataSource(this._db);

  final Database _db;

  Future<BackupDatabaseSnapshot> readSnapshot() async {
    final habitsMap = await _db.query(
      'habits',
      orderBy: 'sort_order ASC, created_at ASC',
    );
    final entriesMap = await _db.query(
      'habit_entries',
      orderBy: 'day_key ASC, habit_id ASC',
    );

    return BackupDatabaseSnapshot(
      habits: habitsMap.map(HabitModel.fromMap).toList(growable: false),
      habitEntries:
          entriesMap.map(HabitEntryModel.fromMap).toList(growable: false),
    );
  }

  Future<void> overwriteSnapshot(BackupDatabaseSnapshot snapshot) async {
    await _db.transaction((txn) async {
      await txn.delete('habit_entries');
      await txn.delete('habits');

      if (snapshot.habits.isNotEmpty) {
        final habitsBatch = txn.batch();
        for (final habit in snapshot.habits) {
          habitsBatch.insert(
            'habits',
            habit.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await habitsBatch.commit(noResult: true);
      }

      if (snapshot.habitEntries.isNotEmpty) {
        final entriesBatch = txn.batch();
        for (final entry in snapshot.habitEntries) {
          entriesBatch.insert(
            'habit_entries',
            entry.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
        await entriesBatch.commit(noResult: true);
      }
    });
  }
}
