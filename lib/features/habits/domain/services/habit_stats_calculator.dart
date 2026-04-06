import 'package:things_to_win/core/utils/date_utils.dart';
import 'package:things_to_win/features/habits/domain/entities/habit_entry.dart';
import 'package:things_to_win/features/habits/domain/entities/habit_stats.dart';

class HabitStatsCalculator {
  const HabitStatsCalculator();

  HabitStats calculate({
    required DateTime start,
    required DateTime end,
    required List<HabitEntry> entries,
  }) {
    final from = toDateOnly(start);
    final to = toDateOnly(end);

    if (from.isAfter(to)) {
      return const HabitStats(
        currentStreak: 0,
        bestStreak: 0,
        completionRate: 0,
        completedDays: 0,
        totalDays: 0,
      );
    }

    final completedDays = entries
        .where((entry) => entry.isCompleted)
        .map((entry) => toDayKey(entry.day))
        .toSet();

    final totalDays = to.difference(from).inDays + 1;

    var bestStreak = 0;
    var runningStreak = 0;

    for (var i = 0; i < totalDays; i++) {
      final day = from.add(Duration(days: i));
      final isCompleted = completedDays.contains(toDayKey(day));
      if (isCompleted) {
        runningStreak++;
        if (runningStreak > bestStreak) {
          bestStreak = runningStreak;
        }
      } else {
        runningStreak = 0;
      }
    }

    var currentStreak = 0;
    for (var i = 0; i < totalDays; i++) {
      final day = to.subtract(Duration(days: i));
      final isCompleted = completedDays.contains(toDayKey(day));
      if (!isCompleted) {
        break;
      }
      currentStreak++;
    }

    final completedCount = completedDays.length;
    final completionRate = totalDays == 0 ? 0.0 : (completedCount / totalDays) * 100;

    return HabitStats(
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      completionRate: completionRate,
      completedDays: completedCount,
      totalDays: totalDays,
    );
  }
}
