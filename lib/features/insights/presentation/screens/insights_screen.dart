import 'package:flutter/material.dart';
import 'package:things_to_win/core/widgets/app_page_scaffold.dart';
import 'package:things_to_win/core/widgets/placeholder_card.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'Insights',
      subtitle: 'Understand momentum and consistency.',
      body: ListView(
        children: const [
          PlaceholderCard(
            icon: Icons.local_fire_department_rounded,
            title: 'Streak Analytics',
            description: 'Current streak, best streak, and weekly trend charts arrive in Phase 2.',
          ),
          SizedBox(height: 12),
          PlaceholderCard(
            icon: Icons.percent_rounded,
            title: 'Completion Rate',
            description: 'Rolling 7/30 day completion rates and habit-level rankings.',
          ),
        ],
      ),
    );
  }
}
