import 'package:things_to_win/features/habits/domain/entities/habit.dart';
import 'package:things_to_win/features/habits/domain/repositories/habits_repository.dart';

class CreateHabit {
  const CreateHabit(this._repository);

  final HabitsRepository _repository;

  Future<void> call(Habit habit) {
    return _repository.createHabit(habit);
  }
}
