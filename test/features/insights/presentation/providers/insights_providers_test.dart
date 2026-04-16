import 'package:flutter_test/flutter_test.dart';
import 'package:things_to_win/features/habits/domain/entities/habit.dart';
import 'package:things_to_win/features/habits/domain/entities/habit_stats.dart';
import 'package:things_to_win/features/insights/presentation/providers/insights_providers.dart';

void main() {
  group('resolveInsightsRangeStart', () {
    final now = DateTime(2026, 4, 16);
    final habits = [
      Habit(
        id: 'h1',
        title: 'Workout',
        colorHex: 0xFF00AA77,
        createdAt: DateTime(2026, 2, 1),
      ),
      Habit(
        id: 'h2',
        title: 'Read',
        colorHex: 0xFF3366DD,
        createdAt: DateTime(2026, 1, 15),
      ),
    ];

    test('returns proper start for last 7 days', () {
      final start = resolveInsightsRangeStart(
        range: InsightsRange.last7Days,
        habits: habits,
        now: now,
      );

      expect(start, DateTime(2026, 4, 10));
    });

    test('returns proper start for last 30 days', () {
      final start = resolveInsightsRangeStart(
        range: InsightsRange.last30Days,
        habits: habits,
        now: now,
      );

      expect(start, DateTime(2026, 3, 18));
    });

    test('returns earliest habit date for all time', () {
      final start = resolveInsightsRangeStart(
        range: InsightsRange.allTime,
        habits: habits,
        now: now,
      );

      expect(start, DateTime(2026, 1, 15));
    });
  });

  group('buildInsightsOverview', () {
    final h1 = Habit(
      id: 'h1',
      title: 'Workout',
      colorHex: 0xFF00AA77,
      createdAt: DateTime(2026, 1, 1),
    );
    final h2 = Habit(
      id: 'h2',
      title: 'Read',
      colorHex: 0xFF3366DD,
      createdAt: DateTime(2026, 1, 1),
    );

    test('aggregates completion, ranking, and streak metrics', () {
      final insights = [
        HabitInsight(
          habit: h1,
          stats: const HabitStats(
            currentStreak: 4,
            bestStreak: 5,
            completionRate: 80,
            completedDays: 8,
            totalDays: 10,
          ),
          rangeStart: DateTime(2026, 4, 1),
          completedToday: true,
        ),
        HabitInsight(
          habit: h2,
          stats: const HabitStats(
            currentStreak: 1,
            bestStreak: 2,
            completionRate: 40,
            completedDays: 4,
            totalDays: 10,
          ),
          rangeStart: DateTime(2026, 4, 1),
          completedToday: false,
        ),
      ];

      final overview = buildInsightsOverview(
        range: InsightsRange.last30Days,
        insights: insights,
      );

      expect(overview.totalHabits, 2);
      expect(overview.completedTodayCount, 1);
      expect(overview.todayProgress, closeTo(0.5, 0.0001));
      expect(overview.completedDaysSum, 12);
      expect(overview.trackedDaysSum, 20);
      expect(overview.overallCompletionRate, closeTo(60, 0.0001));
      expect(overview.ranking.first.habit.id, 'h1');
      expect(overview.topCurrentStreak!.habit.id, 'h1');
      expect(overview.topBestStreak!.habit.id, 'h1');
      expect(overview.activeStreakHabits, 2);
      expect(overview.hasAnyCompletion, isTrue);
    });

    test('handles zero-completion habits without crashing', () {
      final insights = [
        HabitInsight(
          habit: h1,
          stats: const HabitStats(
            currentStreak: 0,
            bestStreak: 0,
            completionRate: 0,
            completedDays: 0,
            totalDays: 7,
          ),
          rangeStart: DateTime(2026, 4, 10),
          completedToday: false,
        ),
      ];

      final overview = buildInsightsOverview(
        range: InsightsRange.last7Days,
        insights: insights,
      );

      expect(overview.totalHabits, 1);
      expect(overview.overallCompletionRate, 0);
      expect(overview.hasAnyCompletion, isFalse);
      expect(overview.ranking.first.habit.id, 'h1');
    });
  });
}
