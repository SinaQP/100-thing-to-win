import 'package:things_to_win/features/habits/data/datasources/habits_local_data_source.dart';
import 'package:things_to_win/features/habits/data/models/habit_entry_model.dart';
import 'package:things_to_win/features/habits/data/models/habit_model.dart';
import 'package:things_to_win/features/habits/domain/entities/habit.dart';
import 'package:things_to_win/features/habits/domain/entities/habit_entry.dart';
import 'package:things_to_win/features/habits/domain/entities/habit_stats.dart';
import 'package:things_to_win/features/habits/domain/repositories/habits_repository.dart';
import 'package:things_to_win/features/habits/domain/services/habit_stats_calculator.dart';

class HabitsRepositoryImpl implements HabitsRepository {
  HabitsRepositoryImpl(
    this._localDataSource, {
    HabitStatsCalculator? statsCalculator,
  }) : _statsCalculator = statsCalculator ?? const HabitStatsCalculator();

  final HabitsLocalDataSource _localDataSource;
  final HabitStatsCalculator _statsCalculator;

  @override
  Future<void> deleteHabit(String habitId) {
    return _localDataSource.deleteHabit(habitId);
  }

  @override
  Future<List<HabitEntry>> getCompletionsForRange({
    String? habitId,
    required DateTime from,
    required DateTime to,
  }) async {
    final entries = await _localDataSource.getEntriesForRange(
        habitId: habitId, from: from, to: to);
    return entries.map((entry) => entry.toEntity()).toList(growable: false);
  }

  @override
  Future<List<Habit>> getHabits({bool includeArchived = false}) async {
    final habits =
        await _localDataSource.getHabits(includeArchived: includeArchived);
    return habits.map((m) => m.toEntity()).toList(growable: false);
  }

  @override
  Future<Habit?> getHabitById(String habitId) async {
    final model = await _localDataSource.getHabitById(habitId);
    return model?.toEntity();
  }

  @override
  Future<void> createHabit(Habit habit) {
    return _localDataSource.upsertHabit(HabitModel.fromEntity(habit));
  }

  @override
  Future<void> updateHabit(Habit habit) {
    return _localDataSource.upsertHabit(HabitModel.fromEntity(habit));
  }

  @override
  Future<void> saveHabit(Habit habit) {
    return _localDataSource.upsertHabit(HabitModel.fromEntity(habit));
  }

  @override
  Future<void> setHabitCompletion(HabitEntry entry) async {
    final completedAt =
        entry.isCompleted ? (entry.completedAt ?? DateTime.now()) : null;
    await _localDataSource.upsertEntry(
      HabitEntryModel.fromEntity(entry.copyWith(completedAt: completedAt)),
    );
  }

  @override
  Future<bool> isHabitCompleted(
      {required String habitId, required DateTime day}) {
    return _localDataSource.isHabitCompleted(habitId: habitId, day: day);
  }

  @override
  Future<void> archiveHabit(
      {required String habitId, required bool isArchived}) {
    return _localDataSource.setHabitArchived(
        id: habitId, isArchived: isArchived);
  }

  @override
  Future<void> updateHabitOrder(List<String> orderedHabitIds) {
    return _localDataSource.updateSortOrder(orderedHabitIds);
  }

  @override
  Future<HabitStats> getHabitStats({
    required Habit habit,
    required DateTime from,
    required DateTime to,
  }) async {
    final entries = await _localDataSource.getEntriesForRange(
        habitId: habit.id, from: from, to: to);
    return _statsCalculator.calculate(
      start: from,
      end: to,
      entries: entries.map((entry) => entry.toEntity()).toList(growable: false),
    );
  }
}
