import 'package:flutter/material.dart';
import 'package:things_to_win/core/widgets/app_page_scaffold.dart';
import 'package:things_to_win/core/widgets/placeholder_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: 'History',
      subtitle: 'Review consistency day by day.',
      body: ListView(
        children: const [
          PlaceholderCard(
            icon: Icons.calendar_today_rounded,
            title: 'Calendar Heatmap',
            description:
                'Phase 2 adds monthly completion heatmap and per-day drilldown.',
          ),
          SizedBox(height: 12),
          PlaceholderCard(
            icon: Icons.history_toggle_off_rounded,
            title: 'Daily Timeline',
            description: 'See completed and skipped habits for each date.',
          ),
        ],
      ),
    );
  }
}
