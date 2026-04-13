import 'package:flutter_test/flutter_test.dart';
import 'package:things_to_win/features/habits/domain/entities/habit_entry.dart';
import 'package:things_to_win/features/habits/domain/services/habit_stats_calculator.dart';

void main() {
  group('HabitStatsCalculator', () {
    const calculator = HabitStatsCalculator();

    test('calculates current streak, best streak, and completion percentage',
        () {
      final entries = [
        HabitEntry(habitId: 'h1', day: DateTime(2026, 4, 1), isCompleted: true),
        HabitEntry(habitId: 'h1', day: DateTime(2026, 4, 2), isCompleted: true),
        HabitEntry(
            habitId: 'h1', day: DateTime(2026, 4, 3), isCompleted: false),
        HabitEntry(habitId: 'h1', day: DateTime(2026, 4, 4), isCompleted: true),
        HabitEntry(habitId: 'h1', day: DateTime(2026, 4, 5), isCompleted: true),
      ];

      final stats = calculator.calculate(
        start: DateTime(2026, 4, 1),
        end: DateTime(2026, 4, 5),
        entries: entries,
      );

      expect(stats.currentStreak, 2);
      expect(stats.bestStreak, 2);
      expect(stats.completedDays, 4);
      expect(stats.totalDays, 5);
      expect(stats.completionRate, closeTo(80, 0.0001));
    });

    test('treats missing days as not completed and resets current streak', () {
      final entries = [
        HabitEntry(habitId: 'h1', day: DateTime(2026, 4, 1), isCompleted: true),
        HabitEntry(habitId: 'h1', day: DateTime(2026, 4, 2), isCompleted: true),
        HabitEntry(habitId: 'h1', day: DateTime(2026, 4, 4), isCompleted: true),
      ];

      final stats = calculator.calculate(
        start: DateTime(2026, 4, 1),
        end: DateTime(2026, 4, 5),
        entries: entries,
      );

      expect(stats.currentStreak, 0);
      expect(stats.bestStreak, 2);
      expect(stats.completedDays, 3);
      expect(stats.completionRate, closeTo(60, 0.0001));
    });

    test('returns zeroed values for invalid range', () {
      final stats = calculator.calculate(
        start: DateTime(2026, 4, 6),
        end: DateTime(2026, 4, 5),
        entries: const [],
      );

      expect(stats.currentStreak, 0);
      expect(stats.bestStreak, 0);
      expect(stats.completedDays, 0);
      expect(stats.totalDays, 0);
      expect(stats.completionRate, 0);
    });
  });
}
