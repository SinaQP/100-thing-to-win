import 'package:things_to_win/features/habits/domain/repositories/habits_repository.dart';

class DeleteHabit {
  const DeleteHabit(this._repository);

  final HabitsRepository _repository;

  Future<void> call(String habitId) {
    return _repository.deleteHabit(habitId);
  }
}
