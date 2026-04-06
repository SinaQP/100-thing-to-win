import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:things_to_win/core/database/local_database.dart';
import 'package:things_to_win/core/utils/date_utils.dart';
import 'package:things_to_win/features/habits/data/datasources/habits_local_data_source.dart';
import 'package:things_to_win/features/habits/data/repositories/habits_repository_impl.dart';
import 'package:things_to_win/features/habits/domain/entities/habit.dart';
import 'package:things_to_win/features/habits/domain/entities/habit_entry.dart';
import 'package:things_to_win/features/habits/domain/repositories/habits_repository.dart';
import 'package:things_to_win/features/habits/domain/usecases/create_habit.dart';
import 'package:things_to_win/features/habits/domain/usecases/delete_habit.dart';
import 'package:things_to_win/features/habits/domain/usecases/get_habits.dart';
import 'package:things_to_win/features/habits/domain/usecases/toggle_habit_completion.dart';
import 'package:things_to_win/features/habits/domain/usecases/update_habit.dart';

final localDatabaseProvider = FutureProvider<Database>((ref) async {
  return LocalDatabase.instance.database;
});

final habitsLocalDataSourceProvider = FutureProvider<HabitsLocalDataSource>((ref) async {
  final db = await ref.watch(localDatabaseProvider.future);
  return SqfliteHabitsLocalDataSource(db);
});

final habitsRepositoryProvider = FutureProvider<HabitsRepository>((ref) async {
  final dataSource = await ref.watch(habitsLocalDataSourceProvider.future);
  return HabitsRepositoryImpl(dataSource);
});

final habitsListProvider = FutureProvider<List<Habit>>((ref) async {
  final repository = await ref.watch(habitsRepositoryProvider.future);
  final usecase = GetHabits(repository);
  return usecase();
});

final habitByIdProvider = FutureProvider.family<Habit?, String>((ref, habitId) async {
  final repository = await ref.watch(habitsRepositoryProvider.future);
  return repository.getHabitById(habitId);
});

final todayHabitCompletionsProvider = FutureProvider<Map<String, bool>>((ref) async {
  final repository = await ref.watch(habitsRepositoryProvider.future);
  final today = toDateOnly(DateTime.now());
  final entries = await repository.getCompletionsForRange(from: today, to: today);
  final completionByHabitId = <String, bool>{};
  for (final entry in entries) {
    completionByHabitId[entry.habitId] = entry.isCompleted;
  }
  return completionByHabitId;
});

class HabitsActions {
  const HabitsActions(this._ref);

  final Ref _ref;

  Future<void> createHabit(Habit habit) async {
    final repository = await _ref.read(habitsRepositoryProvider.future);
    final usecase = CreateHabit(repository);
    await usecase(habit);
    _refresh();
  }

  Future<void> updateHabit(Habit habit) async {
    final repository = await _ref.read(habitsRepositoryProvider.future);
    final usecase = UpdateHabit(repository);
    await usecase(habit);
    _refresh();
  }

  Future<void> deleteHabit(String habitId) async {
    final repository = await _ref.read(habitsRepositoryProvider.future);
    final usecase = DeleteHabit(repository);
    await usecase(habitId);
    _refresh();
  }

  Future<void> toggleTodayCompletion({required String habitId, required bool isCompleted}) async {
    final repository = await _ref.read(habitsRepositoryProvider.future);
    final usecase = ToggleHabitCompletion(repository);
    await usecase(habitId: habitId, day: DateTime.now(), isCompleted: isCompleted);
    _refresh();
  }

  Future<void> archiveHabit({required String habitId, required bool archived}) async {
    final repository = await _ref.read(habitsRepositoryProvider.future);
    await repository.archiveHabit(habitId: habitId, isArchived: archived);
    _refresh();
  }

  Future<void> setCompletion(HabitEntry entry) async {
    final repository = await _ref.read(habitsRepositoryProvider.future);
    await repository.setHabitCompletion(entry);
    _refresh();
  }

  void _refresh() {
    _ref.invalidate(habitsListProvider);
    _ref.invalidate(todayHabitCompletionsProvider);
  }
}

final habitsActionsProvider = Provider<HabitsActions>((ref) {
  return HabitsActions(ref);
});
