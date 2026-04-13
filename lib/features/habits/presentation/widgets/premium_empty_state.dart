import 'package:flutter/material.dart';
import 'package:things_to_win/core/widgets/app_state_view.dart';

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
    return AppEmptyState(
      title: title,
      message: subtitle,
      actionLabel: ctaLabel,
      onAction: onPressed,
      icon: icon,
    );
  }
}
