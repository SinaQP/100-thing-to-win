import 'package:flutter/material.dart';
import 'package:things_to_win/core/theme/app_motion.dart';
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
        return AnimatedScale(
          duration: AppMotion.short,
          curve: AppMotion.emphasisCurve,
          scale: selected ? 1 : 0.98,
          child: ChoiceChip(
            label: Text(category.label),
            selected: selected,
            onSelected: (_) => onSelected(category.value),
          ),
        );
      }).toList(growable: false),
    );
  }
}
