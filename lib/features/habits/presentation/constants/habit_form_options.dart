import 'package:flutter/material.dart';

class HabitCategoryOption {
  const HabitCategoryOption({
    required this.value,
    required this.label,
    required this.description,
  });

  final String value;
  final String label;
  final String description;
}

class HabitIconOption {
  const HabitIconOption({
    required this.key,
    required this.icon,
    required this.label,
  });

  final String key;
  final IconData icon;
  final String label;
}

const habitColorOptions = <int>[
  0xFF37C871,
  0xFF21B2A6,
  0xFF2596FF,
  0xFF5B6CFF,
  0xFFFF7A59,
  0xFFFF4D8D,
  0xFFF7B801,
  0xFF8D6E63,
];

const habitCategoryOptions = <HabitCategoryOption>[
  HabitCategoryOption(
      value: 'Health',
      label: 'Health',
      description: 'Workout, sleep, nutrition, wellness'),
  HabitCategoryOption(
      value: 'Mindset',
      label: 'Mindset',
      description: 'Journaling, meditation, gratitude'),
  HabitCategoryOption(
      value: 'Learning',
      label: 'Learning',
      description: 'Reading, courses, deliberate study'),
  HabitCategoryOption(
      value: 'Career',
      label: 'Career',
      description: 'Deep work, portfolio, interviews'),
  HabitCategoryOption(
      value: 'Finance',
      label: 'Finance',
      description: 'Budgeting, savings, tracking spend'),
  HabitCategoryOption(
      value: 'Lifestyle',
      label: 'Lifestyle',
      description: 'Environment, routines, social life'),
];

const habitIconOptions = <HabitIconOption>[
  HabitIconOption(
      key: 'target', icon: Icons.track_changes_rounded, label: 'Target'),
  HabitIconOption(
      key: 'fitness', icon: Icons.fitness_center_rounded, label: 'Fitness'),
  HabitIconOption(key: 'book', icon: Icons.menu_book_rounded, label: 'Reading'),
  HabitIconOption(
      key: 'meditation',
      icon: Icons.self_improvement_rounded,
      label: 'Mindful'),
  HabitIconOption(
      key: 'water', icon: Icons.water_drop_rounded, label: 'Hydration'),
  HabitIconOption(key: 'run', icon: Icons.directions_run_rounded, label: 'Run'),
  HabitIconOption(key: 'sleep', icon: Icons.bedtime_rounded, label: 'Sleep'),
  HabitIconOption(key: 'code', icon: Icons.code_rounded, label: 'Code'),
  HabitIconOption(key: 'money', icon: Icons.savings_rounded, label: 'Money'),
  HabitIconOption(
      key: 'focus', icon: Icons.psychology_alt_rounded, label: 'Focus'),
  HabitIconOption(
      key: 'language', icon: Icons.translate_rounded, label: 'Language'),
  HabitIconOption(key: 'music', icon: Icons.music_note_rounded, label: 'Music'),
];

IconData habitIconByKey(String key) {
  final found = habitIconOptions.where((option) => option.key == key);
  if (found.isNotEmpty) {
    return found.first.icon;
  }
  return Icons.track_changes_rounded;
}
