import 'package:flutter/material.dart';
import 'package:things_to_win/core/widgets/app_page_scaffold.dart';
import 'package:things_to_win/core/widgets/placeholder_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Today',
      subtitle: 'Win your day one thing at a time.',
      body: ListView(
        children: const [
          PlaceholderCard(
            icon: Icons.stacked_bar_chart_rounded,
            title: 'Today Progress Ring',
            description: 'Phase 2 will add real-time completion percentage and motivational status.',
          ),
          SizedBox(height: 12),
          PlaceholderCard(
            icon: Icons.flash_on_rounded,
            title: 'Current Streak Highlights',
            description: 'Top streak and recovery suggestions will appear here.',
          ),
        ],
      ),
    );
  }
}
