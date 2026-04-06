import 'package:things_to_win/features/habits/domain/entities/habit.dart';
import 'package:things_to_win/features/habits/domain/entities/habit_stats.dart';
import 'package:things_to_win/features/habits/domain/repositories/habits_repository.dart';

class GetHabitStats {
  const GetHabitStats(this._repository);

  final HabitsRepository _repository;

  Future<HabitStats> call({
    required Habit habit,
    required DateTime from,
    required DateTime to,
  }) {
    return _repository.getHabitStats(habit: habit, from: from, to: to);
  }
}
