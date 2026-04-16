import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:things_to_win/core/utils/date_utils.dart';
import 'package:things_to_win/features/habits/domain/entities/habit.dart';
import 'package:things_to_win/features/habits/domain/entities/habit_entry.dart';
import 'package:things_to_win/features/habits/presentation/providers/habits_providers.dart';

final selectedHistoryMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final selectedHistoryDayProvider = StateProvider<DateTime?>((ref) => null);

final historyOverviewProvider = FutureProvider<HistoryOverview>((ref) async {
  final month = ref.watch(selectedHistoryMonthProvider);
  final habits = await ref.watch(habitsListProvider.future);
  if (habits.isEmpty) {
    return HistoryOverview.empty(month: month);
  }

  final repository = await ref.watch(habitsRepositoryProvider.future);
  final monthStart = DateTime(month.year, month.month, 1);
  final monthEnd = DateTime(month.year, month.month + 1, 0);

  final monthEntries =
      await repository.getCompletionsForRange(from: monthStart, to: monthEnd);

  final today = toDateOnly(DateTime.now());
  final recentStart = today.subtract(const Duration(days: 29));
  final recentEntries =
      await repository.getCompletionsForRange(from: recentStart, to: today);

  return buildHistoryOverview(
    month: month,
    habits: habits,
    monthEntries: monthEntries,
    recentEntries: recentEntries,
  );
});

HistoryOverview buildHistoryOverview({
  required DateTime month,
  required List<Habit> habits,
  required List<HabitEntry> monthEntries,
  required List<HabitEntry> recentEntries,
}) {
  if (habits.isEmpty) {
    return HistoryOverview.empty(month: month);
  }

  final habitsById = {for (final habit in habits) habit.id: habit};
  final monthByDay = _groupByDay(monthEntries);
  final recentByDay = _groupByDay(recentEntries);

  final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
  final daySummaries = List.generate(daysInMonth, (index) {
    final dayDate = DateTime(month.year, month.month, index + 1);
    final key = toDayKey(dayDate);
    final entries = monthByDay[key] ?? const <HabitEntry>[];
    return _buildDaySummary(
      date: dayDate,
      activeHabitsCount: habits.length,
      entries: entries,
      habitsById: habitsById,
    );
  });

  final hasAnyCompletedInSelectedMonth =
      daySummaries.any((summary) => summary.completedCount > 0);

  final recentTimeline = recentByDay.entries
      .map((entry) {
        final date = DateTime.parse(entry.key);
        return _buildDaySummary(
          date: date,
          activeHabitsCount: habits.length,
          entries: entry.value,
          habitsById: habitsById,
        );
      })
      .where(
          (summary) => summary.completedCount > 0 || summary.trackedCount > 0)
      .toList(growable: false)
    ..sort((a, b) => b.date.compareTo(a.date));

  return HistoryOverview(
    month: DateTime(month.year, month.month),
    activeHabitsCount: habits.length,
    daySummaries: daySummaries,
    recentTimeline: recentTimeline.take(14).toList(growable: false),
    hasAnyCompletedInSelectedMonth: hasAnyCompletedInSelectedMonth,
  );
}

Map<String, List<HabitEntry>> _groupByDay(List<HabitEntry> entries) {
  final grouped = <String, List<HabitEntry>>{};
  for (final entry in entries) {
    final key = toDayKey(entry.day);
    grouped.putIfAbsent(key, () => <HabitEntry>[]).add(entry);
  }
  return grouped;
}

HistoryDaySummary _buildDaySummary({
  required DateTime date,
  required int activeHabitsCount,
  required List<HabitEntry> entries,
  required Map<String, Habit> habitsById,
}) {
  final latestByHabit = <String, HabitEntry>{};
  for (final entry in entries) {
    latestByHabit[entry.habitId] = entry;
  }

  final completedHabitNames = latestByHabit.entries
      .where((entry) => entry.value.isCompleted)
      .map((entry) => habitsById[entry.key]?.title ?? 'Unknown habit')
      .toList(growable: false)
    ..sort();

  final completedCount = completedHabitNames.length;
  final trackedCount = latestByHabit.length;
  final completionRatio =
      activeHabitsCount == 0 ? 0.0 : completedCount / activeHabitsCount;

  return HistoryDaySummary(
    date: toDateOnly(date),
    completedCount: completedCount,
    totalCount: activeHabitsCount,
    trackedCount: trackedCount,
    completionRatio: completionRatio.clamp(0.0, 1.0),
    completedHabitNames: completedHabitNames,
  );
}

class HistoryOverview extends Equatable {
  const HistoryOverview({
    required this.month,
    required this.activeHabitsCount,
    required this.daySummaries,
    required this.recentTimeline,
    required this.hasAnyCompletedInSelectedMonth,
  });

  factory HistoryOverview.empty({required DateTime month}) {
    return HistoryOverview(
      month: DateTime(month.year, month.month),
      activeHabitsCount: 0,
      daySummaries: const [],
      recentTimeline: const [],
      hasAnyCompletedInSelectedMonth: false,
    );
  }

  final DateTime month;
  final int activeHabitsCount;
  final List<HistoryDaySummary> daySummaries;
  final List<HistoryDaySummary> recentTimeline;
  final bool hasAnyCompletedInSelectedMonth;

  HistoryDaySummary? daySummaryFor(DateTime day) {
    final date = toDateOnly(day);
    for (final summary in daySummaries) {
      if (summary.date == date) {
        return summary;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [
        month,
        activeHabitsCount,
        daySummaries,
        recentTimeline,
        hasAnyCompletedInSelectedMonth,
      ];
}

class HistoryDaySummary extends Equatable {
  const HistoryDaySummary({
    required this.date,
    required this.completedCount,
    required this.totalCount,
    required this.trackedCount,
    required this.completionRatio,
    required this.completedHabitNames,
  });

  final DateTime date;
  final int completedCount;
  final int totalCount;
  final int trackedCount;
  final double completionRatio;
  final List<String> completedHabitNames;

  @override
  List<Object?> get props => [
        date,
        completedCount,
        totalCount,
        trackedCount,
        completionRatio,
        completedHabitNames,
      ];
}
