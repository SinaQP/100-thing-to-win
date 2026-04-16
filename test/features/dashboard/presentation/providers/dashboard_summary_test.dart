import 'package:flutter_test/flutter_test.dart';
import 'package:things_to_win/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:things_to_win/features/habits/domain/entities/habit.dart';

void main() {
  group('DashboardSummary.fromHabits', () {
    test('computes progress and streak highlights from habit data', () {
      final habits = [
        Habit(
          id: 'h1',
          title: 'Workout',
          description: null,
          category: 'Fitness',
          iconKey: 'fitness',
          colorHex: 0xFF37C871,
          createdAt: DateTime(2026, 4, 1),
          order: 0,
        ),
        Habit(
          id: 'h2',
          title: 'Read',
          description: null,
          category: 'Learning',
          iconKey: 'book',
          colorHex: 0xFF3A86FF,
          createdAt: DateTime(2026, 4, 1),
          order: 1,
        ),
      ];

      final highlights = [
        DashboardHabitHighlight(
          habit: habits[0],
          completedToday: true,
          currentStreak: 4,
          weeklyCompletionRate: 85.0,
        ),
        DashboardHabitHighlight(
          habit: habits[1],
          completedToday: false,
          currentStreak: 2,
          weeklyCompletionRate: 57.0,
        ),
      ];

      final summary = DashboardSummary.fromHabits(
        habits: habits,
        highlights: highlights,
      );

      expect(summary.totalHabits, 2);
      expect(summary.completedTodayCount, 1);
      expect(summary.remainingTodayCount, 1);
      expect(summary.todayProgress, closeTo(0.5, 0.0001));
      expect(summary.habitsWithActiveStreak, 2);
      expect(summary.averageWeeklyCompletionRate, closeTo(71.0, 0.0001));
      expect(summary.topStreak, isNotNull);
      expect(summary.topStreak!.habit.id, 'h1');
      expect(summary.topStreak!.currentStreak, 4);
      expect(summary.todayHabits, hasLength(2));
      expect(summary.todayHabits.first.habit.id, 'h2');
      expect(summary.todayHabits.first.completedToday, isFalse);
      expect(summary.todayHabits.last.habit.id, 'h1');
      expect(summary.todayHabits.last.completedToday, isTrue);
    });

    test('returns a zeroed summary when there are no habits', () {
      final summary = DashboardSummary.fromHabits(
        habits: const [],
        highlights: const [],
      );

      expect(summary.totalHabits, 0);
      expect(summary.completedTodayCount, 0);
      expect(summary.remainingTodayCount, 0);
      expect(summary.todayProgress, 0);
      expect(summary.habitsWithActiveStreak, 0);
      expect(summary.averageWeeklyCompletionRate, 0);
      expect(summary.topStreak, isNull);
      expect(summary.todayHabits, isEmpty);
    });
  });
}
