import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:things_to_win/features/habits/domain/entities/habit.dart';
import 'package:things_to_win/features/habits/domain/entities/habit_entry.dart';
import 'package:things_to_win/features/habits/domain/entities/habit_stats.dart';
import 'package:things_to_win/features/habits/domain/repositories/habits_repository.dart';
import 'package:things_to_win/features/habits/domain/services/habit_stats_calculator.dart';
import 'package:things_to_win/features/habits/presentation/providers/habits_providers.dart';
import 'package:things_to_win/features/history/presentation/providers/history_providers.dart';
import 'package:things_to_win/features/insights/presentation/providers/insights_providers.dart';

class _FakeHabitsRepository implements HabitsRepository {
  _FakeHabitsRepository({
    required List<Habit> habits,
    required List<HabitEntry> entries,
  })  : _habits = List.of(habits),
        _entries = List.of(entries);

  final List<Habit> _habits;
  final List<HabitEntry> _entries;
  final HabitStatsCalculator _stats = const HabitStatsCalculator();

  @override
  Future<void> archiveHabit(
      {required String habitId, required bool isArchived}) async {}

  @override
  Future<void> createHabit(Habit habit) async {}

  @override
  Future<void> deleteHabit(String habitId) async {}

  @override
  Future<List<HabitEntry>> getCompletionsForRange({
    String? habitId,
    required DateTime from,
    required DateTime to,
  }) async {
    return _entries.where((entry) {
      if (habitId != null && entry.habitId != habitId) {
        return false;
      }
      final day = DateTime(entry.day.year, entry.day.month, entry.day.day);
      final fromDate = DateTime(from.year, from.month, from.day);
      final toDate = DateTime(to.year, to.month, to.day);
      return !day.isBefore(fromDate) && !day.isAfter(toDate);
    }).toList(growable: false);
  }

  @override
  Future<Habit?> getHabitById(String habitId) async {
    for (final habit in _habits) {
      if (habit.id == habitId) {
        return habit;
      }
    }
    return null;
  }

  @override
  Future<List<Habit>> getHabits({bool includeArchived = false}) async {
    return _habits
        .where((habit) => includeArchived || !habit.isArchived)
        .toList(growable: false);
  }

  @override
  Future<HabitStats> getHabitStats({
    required Habit habit,
    required DateTime from,
    required DateTime to,
  }) async {
    final entries = await getCompletionsForRange(
      habitId: habit.id,
      from: from,
      to: to,
    );
    return _stats.calculate(start: from, end: to, entries: entries);
  }

  @override
  Future<bool> isHabitCompleted(
          {required String habitId, required DateTime day}) async =>
      false;

  @override
  Future<void> saveHabit(Habit habit) async {}

  @override
  Future<void> setHabitCompletion(HabitEntry entry) async {}

  @override
  Future<void> updateHabit(Habit habit) async {}

  @override
  Future<void> updateHabitOrder(List<String> orderedHabitIds) async {}
}

void main() {
  group('provider integration flows', () {
    late Habit h1;
    late Habit h2;
    late DateTime today;
    late ProviderContainer container;

    setUp(() {
      today = DateTime.now();
      final dateOnly = DateTime(today.year, today.month, today.day);
      h1 = Habit(
        id: 'h1',
        title: 'Workout',
        colorHex: 0xFF00AA77,
        createdAt: dateOnly.subtract(const Duration(days: 10)),
        order: 0,
      );
      h2 = Habit(
        id: 'h2',
        title: 'Read',
        colorHex: 0xFF3366DD,
        createdAt: dateOnly.subtract(const Duration(days: 10)),
        order: 1,
      );

      final entries = [
        HabitEntry(habitId: 'h1', day: dateOnly, isCompleted: true),
        HabitEntry(habitId: 'h2', day: dateOnly, isCompleted: false),
        HabitEntry(
            habitId: 'h1',
            day: dateOnly.subtract(const Duration(days: 1)),
            isCompleted: true),
        HabitEntry(
            habitId: 'h2',
            day: dateOnly.subtract(const Duration(days: 1)),
            isCompleted: true),
      ];

      final fakeRepository = _FakeHabitsRepository(
        habits: [h1, h2],
        entries: entries,
      );

      container = ProviderContainer(
        overrides: [
          habitsRepositoryProvider.overrideWith((ref) async => fakeRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('today completion provider maps completion state by habit id',
        () async {
      final completionMap =
          await container.read(todayHabitCompletionsProvider.future);
      expect(completionMap['h1'], isTrue);
      expect(completionMap['h2'], isFalse);
    });

    test('history overview provider builds month and timeline data', () async {
      final month = DateTime(today.year, today.month);
      container.read(selectedHistoryMonthProvider.notifier).state = month;

      final overview = await container.read(historyOverviewProvider.future);
      expect(overview.activeHabitsCount, 2);
      expect(overview.recentTimeline, isNotEmpty);
      expect(
          overview.daySummaryFor(DateTime(today.year, today.month, today.day)),
          isNotNull);
    });

    test('insights overview provider calculates rankings and streak insights',
        () async {
      container.read(selectedInsightsRangeProvider.notifier).state =
          InsightsRange.last7Days;

      final overview = await container.read(insightsOverviewProvider.future);
      expect(overview.totalHabits, 2);
      expect(overview.ranking, isNotEmpty);
      expect(overview.topCurrentStreak, isNotNull);
    });
  });
}
