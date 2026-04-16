import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class LocalDatabase {
  LocalDatabase._({
    Future<String> Function()? dbPathProvider,
  }) : _dbPathProvider = dbPathProvider ?? _defaultDbPathProvider;

  static final instance = LocalDatabase._();
  Database? _database;
  static const _dbVersion = 4;
  final Future<String> Function() _dbPathProvider;

  factory LocalDatabase.forTesting({
    required String databasePath,
  }) {
    return LocalDatabase._(
      dbPathProvider: () async => databasePath,
    );
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    final path = await _dbPathProvider();

    _database = await openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createSchemaV3(db);
      },
      onOpen: (db) async {
        await _repairSchema(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _ensureHabitEntriesTable(db);

          final oldTable = await db.rawQuery(
            "SELECT name FROM sqlite_master WHERE type='table' AND name='habit_completions'",
          );
          if (oldTable.isNotEmpty) {
            await db.execute('''
              INSERT OR REPLACE INTO habit_entries(habit_id, day_key, is_completed, completed_at)
              SELECT habit_id, day, is_done, NULL FROM habit_completions
            ''');
            await db.execute('DROP TABLE habit_completions');
          }
        }

        if (oldVersion < 3) {
          await _ensureHabitColumn(
            db,
            'category',
            "TEXT NOT NULL DEFAULT 'General'",
          );
          await _ensureHabitColumn(
            db,
            'icon_key',
            "TEXT NOT NULL DEFAULT 'target'",
          );
        }

        if (oldVersion < 4) {
          await _repairSchema(db);
        }
      },
    );

    return _database!;
  }

  Future<void> close() async {
    final db = _database;
    if (db == null) {
      return;
    }
    await db.close();
    _database = null;
  }

  static Future<String> _defaultDbPathProvider() async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, 'things_to_win.db');
  }

  Future<void> _createSchemaV3(Database db) async {
    await db.execute('''
      CREATE TABLE habits(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL DEFAULT 'General',
        icon_key TEXT NOT NULL DEFAULT 'target',
        color_hex INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        is_archived INTEGER NOT NULL DEFAULT 0,
        sort_order INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await _ensureHabitEntriesTable(db);
  }

  Future<void> _repairSchema(Database db) async {
    await _ensureHabitEntriesTable(db);
    await _ensureHabitColumn(
      db,
      'category',
      "TEXT NOT NULL DEFAULT 'General'",
    );
    await _ensureHabitColumn(
      db,
      'icon_key',
      "TEXT NOT NULL DEFAULT 'target'",
    );
    await _ensureHabitColumn(
      db,
      'is_archived',
      'INTEGER NOT NULL DEFAULT 0',
    );
    await _ensureHabitColumn(
      db,
      'sort_order',
      'INTEGER NOT NULL DEFAULT 0',
    );
  }

  Future<void> _ensureHabitEntriesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS habit_entries(
        habit_id TEXT NOT NULL,
        day_key TEXT NOT NULL,
        is_completed INTEGER NOT NULL,
        completed_at TEXT,
        PRIMARY KEY(habit_id, day_key),
        FOREIGN KEY(habit_id) REFERENCES habits(id) ON DELETE CASCADE
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_habit_entries_habit_day ON habit_entries(habit_id, day_key)',
    );
  }

  Future<void> _ensureHabitColumn(
    Database db,
    String column,
    String sqlTypeAndConstraints,
  ) async {
    final result = await db.rawQuery('PRAGMA table_info(habits)');
    final exists = result.any((row) => row['name'] == column);
    if (exists) {
      return;
    }
    await db.execute(
      'ALTER TABLE habits ADD COLUMN $column $sqlTypeAndConstraints',
    );
  }
}
