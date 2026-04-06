String? validateHabitTitle(String? value) {
  final raw = (value ?? '').trim();
  if (raw.isEmpty) {
    return 'Habit name is required.';
  }
  if (raw.length < 2) {
    return 'Use at least 2 characters.';
  }
  if (raw.length > 40) {
    return 'Keep it under 40 characters.';
  }
  return null;
}

String? validateHabitDescription(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  if (value.trim().length > 140) {
    return 'Keep description under 140 characters.';
  }
  return null;
}
