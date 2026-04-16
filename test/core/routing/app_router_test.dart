import 'package:flutter_test/flutter_test.dart';
import 'package:things_to_win/core/constants/app_routes.dart';
import 'package:things_to_win/core/routing/app_router.dart';

void main() {
  group('onboardingRedirectFor', () {
    test('redirects to onboarding when onboarding not completed', () {
      final redirect = onboardingRedirectFor(
        hasCompletedOnboarding: false,
        location: AppRoutes.dashboard,
      );

      expect(redirect, AppRoutes.onboarding);
    });

    test('does not redirect while in onboarding routes before completion', () {
      final redirect = onboardingRedirectFor(
        hasCompletedOnboarding: false,
        location: AppRoutes.firstHabitSetup,
      );

      expect(redirect, isNull);
    });

    test('redirects to dashboard after onboarding completion', () {
      final redirect = onboardingRedirectFor(
        hasCompletedOnboarding: true,
        location: AppRoutes.onboarding,
      );

      expect(redirect, AppRoutes.dashboard);
    });

    test('redirects first-habit setup route to dashboard once completed', () {
      final redirect = onboardingRedirectFor(
        hasCompletedOnboarding: true,
        location: AppRoutes.firstHabitSetup,
      );

      expect(redirect, AppRoutes.dashboard);
    });
  });
}
