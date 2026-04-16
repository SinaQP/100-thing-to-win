import 'package:flutter_test/flutter_test.dart';
import 'package:things_to_win/features/habits/data/models/habit_entry_model.dart';
import 'package:things_to_win/features/habits/data/models/habit_model.dart';
import 'package:things_to_win/features/settings/data/models/backup_merge_model.dart';
import 'package:things_to_win/features/settings/domain/entities/app_backup.dart';

void main() {
  group('mergeOrReplaceSnapshot', () {
    const existing = BackupDatabaseSnapshot(
      habits: [
        HabitModel(
          id: 'h1',
          title: 'Workout',
          description: null,
          category: 'Fitness',
          iconKey: 'fitness',
          colorHex: 0xFF00AA77,
          createdAtIso: '2026-01-01T00:00:00.000Z',
          isArchived: false,
          order: 0,
        ),
      ],
      habitEntries: [
        HabitEntryModel(
          habitId: 'h1',
          dayKey: '2026-04-10',
          isCompleted: true,
          completedAtIso: null,
        ),
      ],
    );

    const incoming = BackupDatabaseSnapshot(
      habits: [
        HabitModel(
          id: 'h2',
          title: 'Read',
          description: null,
          category: 'Learning',
          iconKey: 'book',
          colorHex: 0xFF3366DD,
          createdAtIso: '2026-02-01T00:00:00.000Z',
          isArchived: false,
          order: 1,
        ),
      ],
      habitEntries: [
        HabitEntryModel(
          habitId: 'h2',
          dayKey: '2026-04-11',
          isCompleted: true,
          completedAtIso: null,
        ),
      ],
    );

    test('merge mode keeps existing and adds incoming', () {
      final result = mergeOrReplaceSnapshot(
        mode: BackupImportMode.merge,
        existing: existing,
        incoming: incoming,
      );

      expect(result.habits, hasLength(2));
      expect(result.habitEntries, hasLength(2));
    });

    test('replace mode uses incoming only', () {
      final result = mergeOrReplaceSnapshot(
        mode: BackupImportMode.replace,
        existing: existing,
        incoming: incoming,
      );

      expect(result.habits, hasLength(1));
      expect(result.habits.first.id, 'h2');
      expect(result.habitEntries, hasLength(1));
      expect(result.habitEntries.first.habitId, 'h2');
    });

    test('rejects snapshots with dangling entries', () {
      const invalidIncoming = BackupDatabaseSnapshot(
        habits: [],
        habitEntries: [
          HabitEntryModel(
            habitId: 'unknown',
            dayKey: '2026-04-11',
            isCompleted: true,
            completedAtIso: null,
          ),
        ],
      );

      expect(
        () => mergeOrReplaceSnapshot(
          mode: BackupImportMode.replace,
          existing: existing,
          incoming: invalidIncoming,
        ),
        throwsA(isA<BackupValidationException>()),
      );
    });
  });
}
