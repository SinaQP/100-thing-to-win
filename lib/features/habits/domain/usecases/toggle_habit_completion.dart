import 'package:things_to_win/features/habits/domain/entities/habit_entry.dart';
import 'package:things_to_win/features/habits/domain/repositories/habits_repository.dart';

class ToggleHabitCompletion {
  const ToggleHabitCompletion(this._repository);

  final HabitsRepository _repository;

  Future<void> call({
    required String habitId,
    required DateTime day,
    required bool isCompleted,
  }) {
    return _repository.setHabitCompletion(
      HabitEntry(
        habitId: habitId,
        day: DateTime(day.year, day.month, day.day),
        isCompleted: isCompleted,
      ),
    );
  }
}
