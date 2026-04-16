import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:things_to_win/core/utils/date_utils.dart';
import 'package:things_to_win/features/habits/domain/entities/habit.dart';
import 'package:things_to_win/features/habits/domain/entities/habit_stats.dart';
import 'package:things_to_win/features/habits/presentation/providers/habits_providers.dart';

enum InsightsRange {
  last7Days,
  last30Days,
  allTime,
}

final selectedInsightsRangeProvider = StateProvider<InsightsRange>(
  (ref) => InsightsRange.last7Days,
);

final insightsOverviewProvider = FutureProvider<InsightsOverview>((ref) async {
  final range = ref.watch(selectedInsightsRangeProvider);
  final habits = await ref.watch(habitsListProvider.future);
  if (habits.isEmpty) {
    return InsightsOverview.empty(range: range);
  }

  final repository = await ref.watch(habitsRepositoryProvider.future);
  final completionMap = await ref.watch(todayHabitCompletionsProvider.future);
  final today = toDateOnly(DateTime.now());
  final globalStart = resolveInsightsRangeStart(
    range: range,
    habits: habits,
    now: today,
  );

  final perHabit = await Future.wait(
    habits.map((habit) async {
      final created = toDateOnly(habit.createdAt);
      final effectiveStart =
          created.isAfter(globalStart) ? created : globalStart;
      final stats = await repository.getHabitStats(
        habit: habit,
        from: effectiveStart,
        to: today,
      );

      return HabitInsight(
        habit: habit,
        stats: stats,
        rangeStart: effectiveStart,
        completedToday: completionMap[habit.id] ?? false,
      );
    }).toList(growable: false),
  );

  return buildInsightsOverview(
    range: range,
    insights: perHabit,
  );
});

DateTime resolveInsightsRangeStart({
  required InsightsRange range,
  required List<Habit> habits,
  required DateTime now,
}) {
  final today = toDateOnly(now);
  switch (range) {
    case InsightsRange.last7Days:
      return today.subtract(const Duration(days: 6));
    case InsightsRange.last30Days:
      return today.subtract(const Duration(days: 29));
    case InsightsRange.allTime:
      if (habits.isEmpty) {
        return today;
      }
      final earliest = habits
          .map((habit) => toDateOnly(habit.createdAt))
          .reduce((a, b) => a.isBefore(b) ? a : b);
      return earliest;
  }
}

InsightsOverview buildInsightsOverview({
  required InsightsRange range,
  required List<HabitInsight> insights,
}) {
  if (insights.isEmpty) {
    return InsightsOverview.empty(range: range);
  }

  final sortedByCompletion = [...insights]..sort((a, b) {
      final completionCompare =
          b.stats.completionRate.compareTo(a.stats.completionRate);
      if (completionCompare != 0) {
        return completionCompare;
      }
      return b.stats.currentStreak.compareTo(a.stats.currentStreak);
    });

  final topCurrentStreak = insights
      .reduce((a, b) => b.stats.currentStreak > a.stats.currentStreak ? b : a);
  final topBestStreak = insights
      .reduce((a, b) => b.stats.bestStreak > a.stats.bestStreak ? b : a);

  final completedTodayCount = insights.where((i) => i.completedToday).length;
  final totalHabits = insights.length;
  final todayProgress =
      totalHabits == 0 ? 0.0 : completedTodayCount / totalHabits;

  final completedDaysSum = insights.fold<int>(
    0,
    (sum, insight) => sum + insight.stats.completedDays,
  );
  final trackedDaysSum = insights.fold<int>(
    0,
    (sum, insight) => sum + insight.stats.totalDays,
  );
  final overallCompletionRate =
      trackedDaysSum == 0 ? 0.0 : (completedDaysSum / trackedDaysSum) * 100;

  return InsightsOverview(
    range: range,
    habitInsights: List.unmodifiable(insights),
    ranking: List.unmodifiable(sortedByCompletion),
    totalHabits: totalHabits,
    completedTodayCount: completedTodayCount,
    todayProgress: todayProgress,
    overallCompletionRate: overallCompletionRate,
    completedDaysSum: completedDaysSum,
    trackedDaysSum: trackedDaysSum,
    topCurrentStreak: topCurrentStreak,
    topBestStreak: topBestStreak,
    activeStreakHabits: insights.where((i) => i.stats.currentStreak > 0).length,
    hasAnyCompletion: insights.any((i) => i.stats.completedDays > 0),
  );
}

class InsightsOverview extends Equatable {
  const InsightsOverview({
    required this.range,
    required this.habitInsights,
    required this.ranking,
    required this.totalHabits,
    required this.completedTodayCount,
    required this.todayProgress,
    required this.overallCompletionRate,
    required this.completedDaysSum,
    required this.trackedDaysSum,
    required this.topCurrentStreak,
    required this.topBestStreak,
    required this.activeStreakHabits,
    required this.hasAnyCompletion,
  });

  factory InsightsOverview.empty({required InsightsRange range}) {
    return InsightsOverview(
      range: range,
      habitInsights: const [],
      ranking: const [],
      totalHabits: 0,
      completedTodayCount: 0,
      todayProgress: 0.0,
      overallCompletionRate: 0.0,
      completedDaysSum: 0,
      trackedDaysSum: 0,
      topCurrentStreak: null,
      topBestStreak: null,
      activeStreakHabits: 0,
      hasAnyCompletion: false,
    );
  }

  final InsightsRange range;
  final List<HabitInsight> habitInsights;
  final List<HabitInsight> ranking;
  final int totalHabits;
  final int completedTodayCount;
  final double todayProgress;
  final double overallCompletionRate;
  final int completedDaysSum;
  final int trackedDaysSum;
  final HabitInsight? topCurrentStreak;
  final HabitInsight? topBestStreak;
  final int activeStreakHabits;
  final bool hasAnyCompletion;

  @override
  List<Object?> get props => [
        range,
        habitInsights,
        ranking,
        totalHabits,
        completedTodayCount,
        todayProgress,
        overallCompletionRate,
        completedDaysSum,
        trackedDaysSum,
        topCurrentStreak,
        topBestStreak,
        activeStreakHabits,
        hasAnyCompletion,
      ];
}

class HabitInsight extends Equatable {
  const HabitInsight({
    required this.habit,
    required this.stats,
    required this.rangeStart,
    required this.completedToday,
  });

  final Habit habit;
  final HabitStats stats;
  final DateTime rangeStart;
  final bool completedToday;

  @override
  List<Object?> get props => [habit, stats, rangeStart, completedToday];
}
