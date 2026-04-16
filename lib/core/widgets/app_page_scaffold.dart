import 'package:flutter/material.dart';
import 'package:things_to_win/core/theme/app_colors.dart';
import 'package:things_to_win/core/theme/app_spacing.dart';

class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    required this.title,
    required this.subtitle,
    required this.body,
    super.key,
    this.trailing,
    this.maxContentWidth = 760,
    this.padding = AppSpacing.pagePadding,
  });

  final String title;
  final String subtitle;
  final Widget body;
  final Widget? trailing;
  final double maxContentWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(gradient: colors.pageGradient),
      child: Stack(
        children: [
          Positioned(
            top: -90,
            right: -30,
            child: IgnorePointer(
              child: _GlowOrb(
                color: colors.backgroundGlow
                    .withValues(alpha: colors.isDark ? 0.22 : 0.2),
                size: 240,
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -50,
            child: IgnorePointer(
              child: _GlowOrb(
                color: colors.accent
                    .withValues(alpha: colors.isDark ? 0.12 : 0.08),
                size: 180,
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: padding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: theme.textTheme.displaySmall),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    subtitle,
                                    style: theme.textTheme.bodyLarge
                                        ?.copyWith(color: colors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            if (trailing != null) ...[
                              const SizedBox(width: AppSpacing.md),
                              trailing!,
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Expanded(child: body),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
