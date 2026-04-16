import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:things_to_win/core/theme/app_theme.dart';
import 'package:things_to_win/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:things_to_win/features/dashboard/presentation/screens/dashboard_screen.dart';

void main() {
  testWidgets('Dashboard shows empty state when there are no habits',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardSummaryProvider.overrideWith(
            (ref) async => DashboardSummary.empty(),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const Scaffold(body: DashboardScreen()),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('No habits yet'), findsOneWidget);
    expect(find.text('Create first habit'), findsOneWidget);
  });
}
