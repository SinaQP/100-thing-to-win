import 'package:flutter/material.dart';
import 'package:things_to_win/features/habits/presentation/constants/habit_form_options.dart';

class HabitColorSelector extends StatelessWidget {
  const HabitColorSelector({
    required this.selectedColorHex,
    required this.onSelected,
    super.key,
  });

  final int selectedColorHex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: habitColorOptions.map((colorHex) {
        final selected = colorHex == selectedColorHex;
        final color = Color(colorHex);
        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => onSelected(colorHex),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: selected ? Theme.of(context).colorScheme.onSurface : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.28),
                  blurRadius: selected ? 10 : 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: selected ? const Icon(Icons.check_rounded, size: 18, color: Colors.white) : null,
          ),
        );
      }).toList(growable: false),
    );
  }
}
