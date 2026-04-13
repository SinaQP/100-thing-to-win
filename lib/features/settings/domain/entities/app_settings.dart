import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class AppSettings extends Equatable {
  const AppSettings({
    required this.themeMode,
    this.dailyReminderEnabled = false,
    this.showArchivedHabits = false,
    this.hasCompletedOnboarding = false,
  });

  final ThemeMode themeMode;
  final bool dailyReminderEnabled;
  final bool showArchivedHabits;
  final bool hasCompletedOnboarding;

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? dailyReminderEnabled,
    bool? showArchivedHabits,
    bool? hasCompletedOnboarding,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      showArchivedHabits: showArchivedHabits ?? this.showArchivedHabits,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }

  @override
  List<Object?> get props => [
        themeMode,
        dailyReminderEnabled,
        showArchivedHabits,
        hasCompletedOnboarding
      ];
}
