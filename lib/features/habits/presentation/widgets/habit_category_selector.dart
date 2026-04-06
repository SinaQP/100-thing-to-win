import 'package:flutter/material.dart';
import 'package:things_to_win/features/habits/presentation/constants/habit_form_options.dart';

class HabitCategorySelector extends StatelessWidget {
  const HabitCategorySelector({
    required this.selectedCategory,
    required this.onSelected,
    super.key,
  });

  final String selectedCategory;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: habitCategoryOptions.map((category) {
        final selected = category.value == selectedCategory;
        return ChoiceChip(
          label: Text(category.label),
          selected: selected,
          onSelected: (_) => onSelected(category.value),
        );
      }).toList(growable: false),
    );
  }
}
