import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:things_to_win/core/database/local_database.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('LocalDatabase migration and repair', () {
    late Directory tempDir;
    late String dbPath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('things_to_win_db_test_');
      dbPath = '${tempDir.path}${Platform.pathSeparator}things_to_win_test.db';
    });

    tearDown(() async {
      try {
        await deleteDatabase(dbPath);
      } catch (_) {}
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('repairs missing habit_entries and required habit columns on open',
        () async {
      final legacyDb = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE habits(
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              description TEXT,
              color_hex INTEGER NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');
        },
      );
      await legacyDb.close();

      final localDatabase = LocalDatabase.forTesting(databasePath: dbPath);
      final db = await localDatabase.database;

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='habit_entries'",
      );
      expect(tables, isNotEmpty);

      final columns = await db.rawQuery('PRAGMA table_info(habits)');
      final columnNames = columns.map((row) => row['name']).toSet();
      expect(columnNames, contains('category'));
      expect(columnNames, contains('icon_key'));
      expect(columnNames, contains('is_archived'));
      expect(columnNames, contains('sort_order'));

      await localDatabase.close();
    });

    test('migrates legacy habit_completions rows into habit_entries', () async {
      final legacyDb = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE habits(
              id TEXT PRIMARY KEY,
              title TEXT NOT NULL,
              description TEXT,
              color_hex INTEGER NOT NULL,
              created_at TEXT NOT NULL
            )
          ''');
          await db.execute('''
            CREATE TABLE habit_completions(
              habit_id TEXT NOT NULL,
              day TEXT NOT NULL,
              is_done INTEGER NOT NULL,
              PRIMARY KEY(habit_id, day)
            )
          ''');
          await db.insert('habits', {
            'id': 'h1',
            'title': 'Workout',
            'description': null,
            'color_hex': 0xFF00AA77,
            'created_at': '2026-04-01T00:00:00.000Z',
          });
          await db.insert('habit_completions', {
            'habit_id': 'h1',
            'day': '2026-04-16',
            'is_done': 1,
          });
        },
      );
      await legacyDb.close();

      final localDatabase = LocalDatabase.forTesting(databasePath: dbPath);
      final db = await localDatabase.database;

      final migrated = await db.query(
        'habit_entries',
        where: 'habit_id = ? AND day_key = ?',
        whereArgs: ['h1', '2026-04-16'],
      );
      expect(migrated, hasLength(1));
      expect(migrated.first['is_completed'], 1);

      final legacyTable = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='habit_completions'",
      );
      expect(legacyTable, isEmpty);

      await localDatabase.close();
    });
  });
}
