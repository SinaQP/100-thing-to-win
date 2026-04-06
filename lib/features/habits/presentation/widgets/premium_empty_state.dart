import 'package:flutter/material.dart';

class PremiumEmptyState extends StatelessWidget {
  const PremiumEmptyState({
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.onPressed,
    this.icon = Icons.rocket_launch_rounded,
    super.key,
  });

  final String title;
  final String subtitle;
  final String ctaLabel;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.18),
                theme.colorScheme.secondary.withOpacity(0.10),
                theme.colorScheme.tertiary.withOpacity(0.08),
              ],
            ),
            border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.35)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface.withOpacity(0.85),
                ),
                child: Icon(icon, size: 34, color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 16),
              Text(title, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(subtitle, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onPressed,
                icon: const Icon(Icons.add_rounded),
                label: Text(ctaLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
