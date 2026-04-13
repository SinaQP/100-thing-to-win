import 'package:sqflite/sqflite.dart';
import 'package:things_to_win/core/utils/date_utils.dart';
import 'package:things_to_win/features/habits/data/models/habit_entry_model.dart';
import 'package:things_to_win/features/habits/data/models/habit_model.dart';

abstract class HabitsLocalDataSource {
  Future<List<HabitModel>> getHabits({required bool includeArchived});
  Future<HabitModel?> getHabitById(String id);
  Future<void> upsertHabit(HabitModel model);
  Future<void> setHabitArchived({required String id, required bool isArchived});
  Future<void> deleteHabit(String id);
  Future<void> updateSortOrder(List<String> ids);
  Future<void> upsertEntry(HabitEntryModel model);
  Future<bool> isHabitCompleted(
      {required String habitId, required DateTime day});
  Future<List<HabitEntryModel>> getEntriesForRange({
    String? habitId,
    required DateTime from,
    required DateTime to,
  });
}

class SqfliteHabitsLocalDataSource implements HabitsLocalDataSource {
  SqfliteHabitsLocalDataSource(this._db);

  final Database _db;

  @override
  Future<List<HabitModel>> getHabits({required bool includeArchived}) async {
    final maps = await _db.query(
      'habits',
      where: includeArchived ? null : 'is_archived = 0',
      orderBy: 'sort_order ASC, created_at DESC',
    );
    return maps.map(HabitModel.fromMap).toList(growable: false);
  }

  @override
  Future<HabitModel?> getHabitById(String id) async {
    final maps =
        await _db.query('habits', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return HabitModel.fromMap(maps.first);
  }

  @override
  Future<void> upsertHabit(HabitModel model) async {
    await _db.insert('habits', model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> setHabitArchived(
      {required String id, required bool isArchived}) async {
    await _db.update(
      'habits',
      {'is_archived': isArchived ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteHabit(String id) async {
    await _db.delete('habits', where: 'id = ?', whereArgs: [id]);
    await _db.delete('habit_entries', where: 'habit_id = ?', whereArgs: [id]);
  }

  @override
  Future<void> updateSortOrder(List<String> ids) async {
    final batch = _db.batch();
    for (var i = 0; i < ids.length; i++) {
      batch.update('habits', {'sort_order': i},
          where: 'id = ?', whereArgs: [ids[i]]);
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> upsertEntry(HabitEntryModel model) async {
    await _db.insert('habit_entries', model.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<bool> isHabitCompleted(
      {required String habitId, required DateTime day}) async {
    final maps = await _db.query(
      'habit_entries',
      columns: ['is_completed'],
      where: 'habit_id = ? AND day_key = ?',
      whereArgs: [habitId, toDayKey(day)],
      limit: 1,
    );
    if (maps.isEmpty) return false;
    return (maps.first['is_completed']! as int) == 1;
  }

  @override
  Future<List<HabitEntryModel>> getEntriesForRange({
    String? habitId,
    required DateTime from,
    required DateTime to,
  }) async {
    final args = <Object?>[toDayKey(from), toDayKey(to)];
    final whereBuffer = StringBuffer('day_key >= ? AND day_key <= ?');
    if (habitId != null) {
      whereBuffer.write(' AND habit_id = ?');
      args.add(habitId);
    }

    final maps = await _db.query(
      'habit_entries',
      where: whereBuffer.toString(),
      whereArgs: args,
      orderBy: 'day_key ASC',
    );

    return maps.map(HabitEntryModel.fromMap).toList(growable: false);
  }
}
