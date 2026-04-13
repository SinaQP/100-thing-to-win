import 'package:flutter/material.dart';
import 'package:things_to_win/core/theme/app_colors.dart';
import 'package:things_to_win/core/theme/app_motion.dart';
import 'package:things_to_win/core/theme/app_spacing.dart';
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
    final colors = context.appColors;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: habitColorOptions.map((colorHex) {
        final selected = colorHex == selectedColorHex;
        final color = Color(colorHex);
        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => onSelected(colorHex),
          child: AnimatedContainer(
            duration: AppMotion.short,
            curve: AppMotion.emphasisCurve,
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: selected ? colors.textPrimary : Colors.transparent,
                width: selected ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: selected ? 0.3 : 0.18),
                  blurRadius: selected ? 16 : 10,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: selected
                ? const Icon(Icons.check_rounded, size: 20, color: Colors.white)
                : null,
          ),
        );
      }).toList(growable: false),
    );
  }
}
