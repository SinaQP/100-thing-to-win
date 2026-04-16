import 'package:flutter_test/flutter_test.dart';
import 'package:things_to_win/features/habits/data/models/habit_entry_model.dart';
import 'package:things_to_win/features/habits/data/models/habit_model.dart';
import 'package:things_to_win/features/settings/data/models/app_backup_payload_model.dart';
import 'package:things_to_win/features/settings/domain/entities/app_backup.dart';

void main() {
  group('AppBackupPayloadModel', () {
    test('serializes to versioned JSON structure', () {
      final payload = AppBackupPayloadModel(
        version: backupSchemaVersion,
        exportedAt: DateTime.utc(2026, 4, 16, 10, 20, 0),
        habits: const [
          HabitModel(
            id: 'h1',
            title: 'Workout',
            description: '30 mins',
            category: 'Fitness',
            iconKey: 'fitness',
            colorHex: 0xFF00AA77,
            createdAtIso: '2026-04-01T08:00:00.000Z',
            isArchived: false,
            order: 0,
          ),
        ],
        habitEntries: const [
          HabitEntryModel(
            habitId: 'h1',
            dayKey: '2026-04-16',
            isCompleted: true,
            completedAtIso: '2026-04-16T09:00:00.000Z',
          ),
        ],
      );

      final json = payload.toJson();
      expect(json['version'], backupSchemaVersion);
      expect(json['exportedAt'], '2026-04-16T10:20:00.000Z');
      expect((json['habits'] as List), hasLength(1));
      expect((json['habitEntries'] as List), hasLength(1));
    });

    test('rejects unsupported version during parse', () {
      const raw = '''
{
  "version": 99,
  "exportedAt": "2026-04-16T10:20:00.000Z",
  "habits": [],
  "habitEntries": []
}
''';
      expect(
        () => AppBackupPayloadModel.fromJsonString(raw),
        throwsA(isA<BackupValidationException>()),
      );
    });

    test('rejects malformed payloads', () {
      const raw = '''
{
  "version": 1,
  "exportedAt": "2026-04-16T10:20:00.000Z",
  "habits": "not-array",
  "habitEntries": []
}
''';
      expect(
        () => AppBackupPayloadModel.fromJsonString(raw),
        throwsA(isA<BackupValidationException>()),
      );
    });

    test('rejects duplicate habit ids in backup payload', () {
      const raw = '''
{
  "version": 1,
  "exportedAt": "2026-04-16T10:20:00.000Z",
  "habits": [
    {
      "id": "h1",
      "title": "Workout",
      "description": null,
      "category": "Fitness",
      "iconKey": "fitness",
      "colorHex": 123,
      "createdAt": "2026-04-01T00:00:00.000Z",
      "isArchived": false,
      "sortOrder": 0
    },
    {
      "id": "h1",
      "title": "Read",
      "description": null,
      "category": "Learning",
      "iconKey": "book",
      "colorHex": 456,
      "createdAt": "2026-04-02T00:00:00.000Z",
      "isArchived": false,
      "sortOrder": 1
    }
  ],
  "habitEntries": []
}
''';
      expect(
        () => AppBackupPayloadModel.fromJsonString(raw),
        throwsA(isA<BackupValidationException>()),
      );
    });
  });
}
