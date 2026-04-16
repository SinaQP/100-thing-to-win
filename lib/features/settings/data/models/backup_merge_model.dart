import 'package:equatable/equatable.dart';
import 'package:things_to_win/features/habits/data/models/habit_entry_model.dart';
import 'package:things_to_win/features/habits/data/models/habit_model.dart';
import 'package:things_to_win/features/settings/domain/entities/app_backup.dart';

class BackupDatabaseSnapshot extends Equatable {
  const BackupDatabaseSnapshot({
    required this.habits,
    required this.habitEntries,
  });

  final List<HabitModel> habits;
  final List<HabitEntryModel> habitEntries;

  @override
  List<Object?> get props => [habits, habitEntries];
}

BackupDatabaseSnapshot mergeOrReplaceSnapshot({
  required BackupImportMode mode,
  required BackupDatabaseSnapshot existing,
  required BackupDatabaseSnapshot incoming,
}) {
  if (mode == BackupImportMode.replace) {
    return _validatedSnapshot(incoming);
  }

  final habitsById = <String, HabitModel>{
    for (final habit in existing.habits) habit.id: habit,
    for (final habit in incoming.habits) habit.id: habit,
  };

  final entriesByKey = <String, HabitEntryModel>{
    for (final entry in existing.habitEntries)
      '${entry.habitId}:${entry.dayKey}': entry,
    for (final entry in incoming.habitEntries)
      '${entry.habitId}:${entry.dayKey}': entry,
  };

  final merged = BackupDatabaseSnapshot(
    habits: habitsById.values.toList(growable: false),
    habitEntries: entriesByKey.values.toList(growable: false),
  );
  return _validatedSnapshot(merged);
}

BackupDatabaseSnapshot _validatedSnapshot(BackupDatabaseSnapshot snapshot) {
  final habitIds = snapshot.habits.map((h) => h.id).toSet();
  final dangling = snapshot.habitEntries
      .where((entry) => !habitIds.contains(entry.habitId))
      .take(5)
      .toList(growable: false);

  if (dangling.isNotEmpty) {
    throw BackupValidationException(
      'Backup contains entries for unknown habit ids '
      '(${dangling.map((e) => e.habitId).join(', ')}).',
    );
  }
  return snapshot;
}
