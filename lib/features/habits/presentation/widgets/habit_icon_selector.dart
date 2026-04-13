import 'package:flutter/material.dart';
import 'package:things_to_win/core/theme/app_colors.dart';
import 'package:things_to_win/core/theme/app_motion.dart';
import 'package:things_to_win/core/theme/app_spacing.dart';
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
    final colors = context.appColors;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: habitIconOptions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        final option = habitIconOptions[index];
        final selected = option.key == selectedIconKey;

        return InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => onSelected(option.key),
          child: AnimatedContainer(
            duration: AppMotion.short,
            curve: AppMotion.emphasisCurve,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: selected ? colors.accentSoft : colors.cardMuted,
              border:
                  Border.all(color: selected ? colors.accent : colors.border),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: colors.accent
                            .withValues(alpha: colors.isDark ? 0.18 : 0.14),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              option.icon,
              color: selected ? colors.accentStrong : colors.textSecondary,
            ),
          ),
        );
      },
    );
  }
}
