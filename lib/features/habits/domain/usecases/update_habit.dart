import 'package:things_to_win/features/habits/domain/entities/habit.dart';
import 'package:things_to_win/features/habits/domain/repositories/habits_repository.dart';

class UpdateHabit {
  const UpdateHabit(this._repository);

  final HabitsRepository _repository;

  Future<void> call(Habit habit) {
    return _repository.updateHabit(habit);
  }
}
