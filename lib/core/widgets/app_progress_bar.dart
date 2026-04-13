import 'package:flutter/material.dart';
import 'package:things_to_win/core/theme/app_colors.dart';
import 'package:things_to_win/core/theme/app_motion.dart';
import 'package:things_to_win/core/theme/app_radii.dart';

class AppProgressBar extends StatelessWidget {
  const AppProgressBar({
    required this.value,
    super.key,
    this.height = 12,
    this.color,
  });

  final double value;
  final double height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final safeValue = value.clamp(0.0, 1.0);
    final activeColor = color ?? colors.accent;

    return ClipRRect(
      borderRadius: AppRadii.full,
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: colors.progressTrack),
            ),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: safeValue),
              duration: AppMotion.long,
              curve: AppMotion.emphasisCurve,
              builder: (context, animatedValue, child) {
                return FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: animatedValue,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          activeColor,
                          activeColor.withValues(alpha: 0.82),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AppProgressRing extends StatelessWidget {
  const AppProgressRing({
    required this.value,
    required this.label,
    super.key,
    this.size = 92,
    this.strokeWidth = 9,
    this.color,
  });

  final double value;
  final String label;
  final double size;
  final double strokeWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final safeValue = value.clamp(0.0, 1.0);
    final activeColor = color ?? colors.accent;
    final theme = Theme.of(context);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: safeValue),
            duration: AppMotion.long,
            curve: AppMotion.emphasisCurve,
            builder: (context, animatedValue, child) {
              return CircularProgressIndicator(
                value: animatedValue,
                strokeWidth: strokeWidth,
                strokeCap: StrokeCap.round,
                color: activeColor,
                backgroundColor: colors.progressTrack,
              );
            },
          ),
          Text(label, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}
