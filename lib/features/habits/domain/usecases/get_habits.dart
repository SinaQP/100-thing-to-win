import 'package:things_to_win/features/habits/domain/entities/habit.dart';
import 'package:things_to_win/features/habits/domain/repositories/habits_repository.dart';

class GetHabits {
  const GetHabits(this._repository);

  final HabitsRepository _repository;

  Future<List<Habit>> call({bool includeArchived = false}) {
    return _repository.getHabits(includeArchived: includeArchived);
  }
}
