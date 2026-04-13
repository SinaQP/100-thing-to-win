import 'package:flutter_test/flutter_test.dart';
import 'package:things_to_win/core/utils/date_utils.dart';
import 'package:things_to_win/features/habits/data/datasources/habits_local_data_source.dart';
import 'package:things_to_win/features/habits/data/models/habit_entry_model.dart';
import 'package:things_to_win/features/habits/data/models/habit_model.dart';
import 'package:things_to_win/features/habits/data/repositories/habits_repository_impl.dart';
import 'package:things_to_win/features/habits/domain/entities/habit.dart';
import 'package:things_to_win/features/habits/domain/entities/habit_entry.dart';

class _FakeHabitsLocalDataSource implements HabitsLocalDataSource {
  final Map<String, HabitModel> _habits = {};
  final Map<String, HabitEntryModel> _entries = {};

  @override
  Future<void> deleteHabit(String id) async {
    _habits.remove(id);
    _entries.removeWhere((key, value) => value.habitId == id);
  }

  @override
  Future<HabitModel?> getHabitById(String id) async {
    return _habits[id];
  }

  @override
  Future<List<HabitModel>> getHabits({required bool includeArchived}) async {
    final list = _habits.values
        .where((h) => includeArchived || !h.isArchived)
        .toList(growable: false)
      ..sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  @override
  Future<void> upsertHabit(HabitModel model) async {
    _habits[model.id] = model;
  }

  @override
  Future<void> setHabitArchived(
      {required String id, required bool isArchived}) async {
    final current = _habits[id];
    if (current == null) return;
    _habits[id] = HabitModel(
      id: current.id,
      title: current.title,
      description: current.description,
      category: current.category,
      iconKey: current.iconKey,
      colorHex: current.colorHex,
      createdAtIso: current.createdAtIso,
      isArchived: isArchived,
      order: current.order,
    );
  }

  @override
  Future<void> updateSortOrder(List<String> ids) async {
    for (var i = 0; i < ids.length; i++) {
      final current = _habits[ids[i]];
      if (current == null) continue;
      _habits[ids[i]] = HabitModel(
        id: current.id,
        title: current.title,
        description: current.description,
        category: current.category,
        iconKey: current.iconKey,
        colorHex: current.colorHex,
        createdAtIso: current.createdAtIso,
        isArchived: current.isArchived,
        order: i,
      );
    }
  }

  @override
  Future<void> upsertEntry(HabitEntryModel model) async {
    _entries['${model.habitId}:${model.dayKey}'] = model;
  }

  @override
  Future<bool> isHabitCompleted(
      {required String habitId, required DateTime day}) async {
    final key = '$habitId:${toDayKey(day)}';
    final entry = _entries[key];
    return entry?.isCompleted ?? false;
  }

  @override
  Future<List<HabitEntryModel>> getEntriesForRange({
    String? habitId,
    required DateTime from,
    required DateTime to,
  }) async {
    final fromKey = toDayKey(from);
    final toKey = toDayKey(to);

    final list = _entries.values.where((entry) {
      if (habitId != null && entry.habitId != habitId) return false;
      return entry.dayKey.compareTo(fromKey) >= 0 &&
          entry.dayKey.compareTo(toKey) <= 0;
    }).toList(growable: false)
      ..sort((a, b) => a.dayKey.compareTo(b.dayKey));

    return list;
  }
}

void main() {
  group('HabitsRepositoryImpl', () {
    late _FakeHabitsLocalDataSource local;
    late HabitsRepositoryImpl repository;

    setUp(() {
      local = _FakeHabitsLocalDataSource();
      repository = HabitsRepositoryImpl(local);
    });

    test('supports create, archive and delete habit CRUD flow', () async {
      final habit = Habit(
        id: 'h1',
        title: 'Workout',
        description: '30 min',
        category: 'Fitness',
        iconKey: 'fitness',
        colorHex: 0xFF37C871,
        createdAt: DateTime(2026, 4, 1),
        order: 0,
      );

      await repository.createHabit(habit);

      final created = await repository.getHabitById('h1');
      expect(created, isNotNull);
      expect(created!.title, 'Workout');

      await repository.archiveHabit(habitId: 'h1', isArchived: true);
      final activeHabits = await repository.getHabits();
      final allHabits = await repository.getHabits(includeArchived: true);

      expect(activeHabits, isEmpty);
      expect(allHabits, hasLength(1));
      expect(allHabits.first.isArchived, isTrue);

      await repository.deleteHabit('h1');
      final deleted = await repository.getHabitById('h1');
      expect(deleted, isNull);
    });

    test('daily completion persists and completion flag is queryable',
        () async {
      await repository.setHabitCompletion(
        HabitEntry(
          habitId: 'h1',
          day: DateTime(2026, 4, 6),
          isCompleted: true,
        ),
      );

      final isCompleted = await repository.isHabitCompleted(
        habitId: 'h1',
        day: DateTime(2026, 4, 6, 23, 59),
      );

      expect(isCompleted, isTrue);

      final entries = await repository.getCompletionsForRange(
        habitId: 'h1',
        from: DateTime(2026, 4, 6),
        to: DateTime(2026, 4, 6),
      );

      expect(entries, hasLength(1));
      expect(entries.first.isCompleted, isTrue);
      expect(entries.first.completedAt, isNotNull);
    });
  });
}
