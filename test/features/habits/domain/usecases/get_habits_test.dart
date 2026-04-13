import 'package:flutter_test/flutter_test.dart';
import 'package:things_to_win/features/habits/domain/entities/habit.dart';
import 'package:things_to_win/features/habits/domain/entities/habit_entry.dart';
import 'package:things_to_win/features/habits/domain/entities/habit_stats.dart';
import 'package:things_to_win/features/habits/domain/repositories/habits_repository.dart';
import 'package:things_to_win/features/habits/domain/usecases/get_habits.dart';

class _FakeHabitsRepository implements HabitsRepository {
  @override
  Future<void> deleteHabit(String habitId) async {}

  @override
  Future<List<HabitEntry>> getCompletionsForRange({
    String? habitId,
    required DateTime from,
    required DateTime to,
  }) async {
    return const [];
  }

  @override
  Future<List<Habit>> getHabits({bool includeArchived = false}) async {
    return [
      Habit(
        id: '1',
        title: 'Workout',
        colorHex: 0xFF37C871,
        createdAt: DateTime(2025, 1, 1),
      ),
    ];
  }

  @override
  Future<Habit?> getHabitById(String habitId) async {
    return null;
  }

  @override
  Future<void> createHabit(Habit habit) async {}

  @override
  Future<void> updateHabit(Habit habit) async {}

  @override
  Future<void> saveHabit(Habit habit) async {}

  @override
  Future<void> setHabitCompletion(HabitEntry entry) async {}

  @override
  Future<void> updateHabitOrder(List<String> orderedHabitIds) async {}

  @override
  Future<void> archiveHabit(
      {required String habitId, required bool isArchived}) async {}

  @override
  Future<bool> isHabitCompleted(
      {required String habitId, required DateTime day}) async {
    return false;
  }

  @override
  Future<HabitStats> getHabitStats(
      {required Habit habit,
      required DateTime from,
      required DateTime to}) async {
    return const HabitStats(
      currentStreak: 0,
      bestStreak: 0,
      completionRate: 0,
      completedDays: 0,
      totalDays: 0,
    );
  }
}

void main() {
  test('GetHabits returns list from repository', () async {
    final usecase = GetHabits(_FakeHabitsRepository());

    final habits = await usecase();

    expect(habits, hasLength(1));
    expect(habits.first.title, 'Workout');
  });
}
