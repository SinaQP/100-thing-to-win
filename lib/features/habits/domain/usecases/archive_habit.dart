import 'package:things_to_win/features/habits/domain/repositories/habits_repository.dart';

class ArchiveHabit {
  const ArchiveHabit(this._repository);

  final HabitsRepository _repository;

  Future<void> call({required String habitId, required bool isArchived}) {
    return _repository.archiveHabit(habitId: habitId, isArchived: isArchived);
  }
}
