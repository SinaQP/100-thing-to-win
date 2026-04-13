import 'package:things_to_win/features/habits/domain/entities/habit.dart';
import 'package:things_to_win/features/habits/domain/entities/habit_entry.dart';
import 'package:things_to_win/features/habits/domain/entities/habit_stats.dart';

abstract class HabitsRepository {
  Future<List<Habit>> getHabits({bool includeArchived = false});

  Future<Habit?> getHabitById(String habitId);

  Future<void> createHabit(Habit habit);

  Future<void> updateHabit(Habit habit);

  Future<void> saveHabit(
      Habit habit); // Backward-compatible create/update alias.

  Future<void> deleteHabit(String habitId);

  Future<void> archiveHabit({
    required String habitId,
    required bool isArchived,
  });

  Future<void> updateHabitOrder(List<String> orderedHabitIds);

  Future<void> setHabitCompletion(HabitEntry entry);

  Future<bool> isHabitCompleted({
    required String habitId,
    required DateTime day,
  });

  Future<List<HabitEntry>> getCompletionsForRange({
    String? habitId,
    required DateTime from,
    required DateTime to,
  });

  Future<HabitStats> getHabitStats({
    required Habit habit,
    required DateTime from,
    required DateTime to,
  });
}
