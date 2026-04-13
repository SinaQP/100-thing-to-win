import 'package:flutter/material.dart';
import 'package:things_to_win/core/theme/app_colors.dart';
import 'package:things_to_win/core/theme/app_elevation.dart';
import 'package:things_to_win/core/theme/app_motion.dart';
import 'package:things_to_win/core/theme/app_radii.dart';
import 'package:things_to_win/core/theme/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    super.key,
    this.padding = AppSpacing.cardPadding,
    this.onTap,
    this.gradient,
    this.color,
    this.borderColor,
    this.borderRadius,
    this.showShadow = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? color;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final radius = borderRadius ?? AppRadii.card;
    final decoration = BoxDecoration(
      color: gradient == null ? (color ?? colors.card) : null,
      gradient: gradient,
      borderRadius: radius,
      border: Border.all(
        color: (borderColor ?? colors.border)
            .withValues(alpha: colors.isDark ? 0.9 : 0.75),
      ),
      boxShadow: showShadow
          ? AppElevation.soft(
              colors.shadow,
              opacity: colors.isDark ? 0.24 : 0.07,
            )
          : null,
    );

    final content = AnimatedContainer(
      duration: AppMotion.short,
      curve: AppMotion.enterCurve,
      decoration: decoration,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap == null) {
      return content;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: content,
      ),
    );
  }
}
