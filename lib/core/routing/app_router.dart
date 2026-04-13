import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:things_to_win/app/navigation/app_navigation_shell.dart';
import 'package:things_to_win/core/constants/app_routes.dart';
import 'package:things_to_win/core/theme/app_motion.dart';
import 'package:things_to_win/features/habits/presentation/screens/habit_form_screen.dart';
import 'package:things_to_win/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:things_to_win/features/settings/presentation/providers/theme_mode_provider.dart';

final appRouterProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) async {
      final settingsRepository =
          await ref.read(settingsRepositoryProvider.future);
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
        pageBuilder: (context, state) => AppMotion.page<void>(
          key: state.pageKey,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.firstHabitSetup,
        pageBuilder: (context, state) => AppMotion.page<void>(
          key: state.pageKey,
          child: const HabitFormScreen(isFirstHabitSetup: true),
        ),
      ),
      GoRoute(
        path: AppRoutes.habitCreate,
        pageBuilder: (context, state) => AppMotion.page<void>(
          key: state.pageKey,
          child: const HabitFormScreen(),
        ),
      ),
      GoRoute(
        path: '${AppRoutes.habitEditBase}/:habitId',
        pageBuilder: (context, state) {
          final habitId = state.pathParameters['habitId']!;
          return AppMotion.page<void>(
            key: state.pageKey,
            child: HabitFormScreen(habitId: habitId),
          );
        },
      ),
      ...appShellRoutes,
    ],
  ),
);
