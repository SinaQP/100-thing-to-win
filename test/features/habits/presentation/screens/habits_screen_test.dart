import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:things_to_win/core/theme/app_theme.dart';
import 'package:things_to_win/features/habits/domain/entities/habit.dart';
import 'package:things_to_win/features/habits/presentation/providers/habits_providers.dart';
import 'package:things_to_win/features/habits/presentation/screens/habits_screen.dart';

void main() {
  testWidgets('Habits shows empty state when no habits exist', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          habitsListProvider.overrideWith((ref) async => const <Habit>[]),
          todayHabitCompletionsProvider
              .overrideWith((ref) async => <String, bool>{}),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const Scaffold(body: HabitsScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Your Winboard Is Empty'), findsOneWidget);
    expect(find.text('Create First Habit'), findsOneWidget);
  });

  testWidgets('Habits shows list content when habits are available',
      (tester) async {
    final habit = Habit(
      id: 'h1',
      title: 'Deep Work',
      description: '90 minutes focused session',
      category: 'Work',
      iconKey: 'target',
      colorHex: 0xFF2FB36E,
      createdAt: DateTime(2026, 4, 16),
      order: 0,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          habitsListProvider.overrideWith((ref) async => [habit]),
          todayHabitCompletionsProvider
              .overrideWith((ref) async => <String, bool>{'h1': true}),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const Scaffold(body: HabitsScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Deep Work'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
    expect(find.text('Your Winboard Is Empty'), findsNothing);
  });
}
