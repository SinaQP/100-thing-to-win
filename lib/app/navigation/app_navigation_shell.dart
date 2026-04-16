import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:things_to_win/core/constants/app_routes.dart';
import 'package:things_to_win/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:things_to_win/features/habits/presentation/screens/habits_screen.dart';
import 'package:things_to_win/features/history/presentation/screens/history_screen.dart';
import 'package:things_to_win/features/insights/presentation/screens/insights_screen.dart';
import 'package:things_to_win/features/settings/presentation/screens/settings_screen.dart';

class AppNavigationShell extends StatelessWidget {
  const AppNavigationShell({
    required this.child,
    super.key,
  });

  final Widget child;

  static const _tabs = <_TabDestination>[
    _TabDestination(
        label: 'Today', icon: Icons.home_rounded, route: AppRoutes.dashboard),
    _TabDestination(
        label: 'Habits', icon: Icons.flag_rounded, route: AppRoutes.habits),
    _TabDestination(
        label: 'History',
        icon: Icons.calendar_month_rounded,
        route: AppRoutes.history),
    _TabDestination(
        label: 'Insights',
        icon: Icons.insights_rounded,
        route: AppRoutes.insights),
    _TabDestination(
        label: 'Settings',
        icon: Icons.settings_rounded,
        route: AppRoutes.settings),
  ];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex =
        _tabs.indexWhere((tab) => location.startsWith(tab.route));

    return Scaffold(
      body: KeyedSubtree(
        key: ValueKey<String>(location),
        child: child,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex < 0 ? 0 : currentIndex,
        destinations: _tabs
            .map(
              (tab) => NavigationDestination(
                icon: Icon(tab.icon),
                label: tab.label,
              ),
            )
            .toList(growable: false),
        onDestinationSelected: (index) {
          context.go(_tabs[index].route);
        },
      ),
    );
  }
}

class _TabDestination {
  const _TabDestination({
    required this.label,
    required this.icon,
    required this.route,
  });

  final String label;
  final IconData icon;
  final String route;
}

final appShellRoutes = [
  ShellRoute(
    builder: (context, state, child) => AppNavigationShell(child: child),
    routes: [
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.habits,
        builder: (context, state) => const HabitsScreen(),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.insights,
        builder: (context, state) => const InsightsScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  ),
];
