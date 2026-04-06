class AppRoutes {
  const AppRoutes._();

  static const onboarding = '/onboarding';
  static const firstHabitSetup = '/onboarding/first-habit';

  static const dashboard = '/dashboard';
  static const habits = '/habits';
  static const habitCreate = '/habits/new';
  static const habitEditBase = '/habits/edit';
  static const history = '/history';
  static const insights = '/insights';
  static const settings = '/settings';

  static String habitEdit(String habitId) => '$habitEditBase/$habitId';
}
