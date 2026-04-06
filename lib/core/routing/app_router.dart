import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:things_to_win/app/navigation/app_navigation_shell.dart';
import 'package:things_to_win/core/constants/app_routes.dart';
import 'package:things_to_win/features/habits/presentation/screens/habit_form_screen.dart';
import 'package:things_to_win/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:things_to_win/features/settings/presentation/providers/theme_mode_provider.dart';

final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) async {
      final settingsRepository = await ref.read(settingsRepositoryProvider.future);
      final settings = await settingsRepository.getSettings();
      final hasCompletedOnboarding = settings.hasCompletedOnboarding;
      final location = state.uri.path;
      final inOnboarding = location.startsWith(AppRoutes.onboarding);

      if (!hasCompletedOnboarding && !inOnboarding) {
        return AppRoutes.onboarding;
      }

      if (hasCompletedOnboarding && inOnboarding) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.firstHabitSetup,
        builder: (context, state) => const HabitFormScreen(isFirstHabitSetup: true),
      ),
      GoRoute(
        path: AppRoutes.habitCreate,
        builder: (context, state) => const HabitFormScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.habitEditBase}/:habitId',
        builder: (context, state) {
          final habitId = state.pathParameters['habitId']!;
          return HabitFormScreen(habitId: habitId);
        },
      ),
      ...appShellRoutes,
    ],
  ),
);
