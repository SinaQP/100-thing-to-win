import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:things_to_win/core/utils/date_utils.dart';
import 'package:things_to_win/features/habits/domain/entities/habit.dart';
import 'package:things_to_win/features/habits/presentation/providers/habits_providers.dart';

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final habits = await ref.watch(habitsListProvider.future);
  if (habits.isEmpty) {
    return DashboardSummary.empty();
  }

  final completionMap = await ref.watch(todayHabitCompletionsProvider.future);
  final repository = await ref.watch(habitsRepositoryProvider.future);
  final today = toDateOnly(DateTime.now());
  final weeklyStart = today.subtract(const Duration(days: 6));

  final highlights = await Future.wait(
    habits.map((habit) async {
      final createdAtDate = toDateOnly(habit.createdAt);
      final statsFrom =
          createdAtDate.isAfter(weeklyStart) ? createdAtDate : weeklyStart;

      final streakStats = await repository.getHabitStats(
        habit: habit,
        from: createdAtDate,
        to: today,
      );
      final weeklyStats = await repository.getHabitStats(
        habit: habit,
        from: statsFrom,
        to: today,
      );

      return DashboardHabitHighlight(
        habit: habit,
        completedToday: completionMap[habit.id] ?? false,
        currentStreak: streakStats.currentStreak,
        weeklyCompletionRate: weeklyStats.completionRate,
      );
    }).toList(growable: false),
  );

  return DashboardSummary.fromHabits(
    habits: habits,
    highlights: highlights,
  );
});

class DashboardSummary extends Equatable {
  const DashboardSummary({
    required this.totalHabits,
    required this.completedTodayCount,
    required this.todayProgress,
    required this.remainingTodayCount,
    required this.topStreak,
    required this.habitsWithActiveStreak,
    required this.averageWeeklyCompletionRate,
    required this.todayHabits,
  });

  factory DashboardSummary.empty() {
    return const DashboardSummary(
      totalHabits: 0,
      completedTodayCount: 0,
      todayProgress: 0,
      remainingTodayCount: 0,
      topStreak: null,
      habitsWithActiveStreak: 0,
      averageWeeklyCompletionRate: 0,
      todayHabits: [],
    );
  }

  factory DashboardSummary.fromHabits({
    required List<Habit> habits,
    required List<DashboardHabitHighlight> highlights,
  }) {
    final completedTodayCount =
        highlights.where((h) => h.completedToday).length;
    final totalHabits = habits.length;
    final todayProgress =
        totalHabits == 0 ? 0.0 : completedTodayCount / totalHabits;
    final remainingTodayCount = totalHabits - completedTodayCount;

    DashboardHabitHighlight? topStreak;
    for (final highlight in highlights) {
      if (topStreak == null ||
          highlight.currentStreak > topStreak.currentStreak ||
          (highlight.currentStreak == topStreak.currentStreak &&
              highlight.weeklyCompletionRate >
                  topStreak.weeklyCompletionRate)) {
        topStreak = highlight;
      }
    }

    final habitsWithActiveStreak =
        highlights.where((h) => h.currentStreak > 0).length;
    final averageWeeklyCompletionRate = highlights.isEmpty
        ? 0.0
        : highlights
                .map((h) => h.weeklyCompletionRate)
                .reduce((a, b) => a + b) /
            highlights.length;
    final sortedTodayHabits = [...highlights]..sort((a, b) {
        if (a.completedToday != b.completedToday) {
          return a.completedToday ? 1 : -1;
        }
        return a.habit.order.compareTo(b.habit.order);
      });

    return DashboardSummary(
      totalHabits: totalHabits,
      completedTodayCount: completedTodayCount,
      todayProgress: todayProgress,
      remainingTodayCount: remainingTodayCount,
      topStreak: topStreak,
      habitsWithActiveStreak: habitsWithActiveStreak,
      averageWeeklyCompletionRate: averageWeeklyCompletionRate,
      todayHabits: List.unmodifiable(sortedTodayHabits),
    );
  }

  final int totalHabits;
  final int completedTodayCount;
  final double todayProgress;
  final int remainingTodayCount;
  final DashboardHabitHighlight? topStreak;
  final int habitsWithActiveStreak;
  final double averageWeeklyCompletionRate;
  final List<DashboardHabitHighlight> todayHabits;

  @override
  List<Object?> get props => [
        totalHabits,
        completedTodayCount,
        todayProgress,
        remainingTodayCount,
        topStreak,
        habitsWithActiveStreak,
        averageWeeklyCompletionRate,
        todayHabits,
      ];
}

class DashboardHabitHighlight extends Equatable {
  const DashboardHabitHighlight({
    required this.habit,
    required this.completedToday,
    required this.currentStreak,
    required this.weeklyCompletionRate,
  });

  final Habit habit;
  final bool completedToday;
  final int currentStreak;
  final double weeklyCompletionRate;

  @override
  List<Object?> get props => [
        habit,
        completedToday,
        currentStreak,
        weeklyCompletionRate,
      ];
}
