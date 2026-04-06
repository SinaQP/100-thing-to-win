import 'package:flutter/material.dart';
import 'package:things_to_win/features/habits/presentation/constants/habit_form_options.dart';

class HabitIconSelector extends StatelessWidget {
  const HabitIconSelector({
    required this.selectedIconKey,
    required this.onSelected,
    super.key,
  });

  final String selectedIconKey;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: habitIconOptions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final option = habitIconOptions[index];
        final selected = option.key == selectedIconKey;

        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => onSelected(option.key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: selected ? scheme.primary.withOpacity(0.16) : scheme.surfaceContainerHighest,
              border: Border.all(color: selected ? scheme.primary : scheme.outlineVariant),
            ),
            child: Icon(
              option.icon,
              color: selected ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}
