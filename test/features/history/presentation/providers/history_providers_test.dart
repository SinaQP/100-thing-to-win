import 'package:flutter_test/flutter_test.dart';
import 'package:things_to_win/features/habits/domain/entities/habit.dart';
import 'package:things_to_win/features/habits/domain/entities/habit_entry.dart';
import 'package:things_to_win/features/history/presentation/providers/history_providers.dart';

void main() {
  group('buildHistoryOverview', () {
    test('builds month summaries and recent timeline from entries', () {
      final habits = [
        Habit(
          id: 'h1',
          title: 'Workout',
          description: null,
          category: 'Fitness',
          iconKey: 'fitness',
          colorHex: 0xFF00AA77,
          createdAt: DateTime(2026, 1, 1),
          order: 0,
        ),
        Habit(
          id: 'h2',
          title: 'Read',
          description: null,
          category: 'Learning',
          iconKey: 'book',
          colorHex: 0xFF3366DD,
          createdAt: DateTime(2026, 1, 1),
          order: 1,
        ),
      ];

      final monthEntries = [
        HabitEntry(habitId: 'h1', day: DateTime(2026, 4, 5), isCompleted: true),
        HabitEntry(
            habitId: 'h2', day: DateTime(2026, 4, 5), isCompleted: false),
        HabitEntry(habitId: 'h1', day: DateTime(2026, 4, 6), isCompleted: true),
        HabitEntry(habitId: 'h2', day: DateTime(2026, 4, 6), isCompleted: true),
      ];

      final recentEntries = [
        HabitEntry(habitId: 'h1', day: DateTime(2026, 4, 6), isCompleted: true),
        HabitEntry(habitId: 'h2', day: DateTime(2026, 4, 6), isCompleted: true),
        HabitEntry(
            habitId: 'h1', day: DateTime(2026, 4, 4), isCompleted: false),
      ];

      final overview = buildHistoryOverview(
        month: DateTime(2026, 4),
        habits: habits,
        monthEntries: monthEntries,
        recentEntries: recentEntries,
      );

      expect(overview.activeHabitsCount, 2);
      expect(overview.daySummaries, hasLength(30));
      expect(overview.hasAnyCompletedInSelectedMonth, isTrue);

      final day5 = overview.daySummaryFor(DateTime(2026, 4, 5));
      expect(day5, isNotNull);
      expect(day5!.completedCount, 1);
      expect(day5.totalCount, 2);
      expect(day5.trackedCount, 2);
      expect(day5.completionRatio, closeTo(0.5, 0.0001));
      expect(day5.completedHabitNames, ['Workout']);

      final day6 = overview.daySummaryFor(DateTime(2026, 4, 6));
      expect(day6, isNotNull);
      expect(day6!.completedCount, 2);
      expect(day6.completionRatio, closeTo(1.0, 0.0001));

      expect(overview.recentTimeline, hasLength(2));
      expect(overview.recentTimeline.first.date, DateTime(2026, 4, 6));
      expect(overview.recentTimeline.first.completedCount, 2);
      expect(overview.recentTimeline[1].date, DateTime(2026, 4, 4));
      expect(overview.recentTimeline[1].trackedCount, 1);
    });

    test('returns empty overview when no active habits', () {
      final overview = buildHistoryOverview(
        month: DateTime(2026, 4),
        habits: const [],
        monthEntries: const [],
        recentEntries: const [],
      );

      expect(overview.activeHabitsCount, 0);
      expect(overview.daySummaries, isEmpty);
      expect(overview.recentTimeline, isEmpty);
      expect(overview.hasAnyCompletedInSelectedMonth, isFalse);
    });
  });
}
