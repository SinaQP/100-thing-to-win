import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:things_to_win/core/widgets/app_page_scaffold.dart';
import 'package:things_to_win/core/widgets/placeholder_card.dart';
import 'package:things_to_win/features/settings/presentation/providers/theme_mode_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMode = ref.watch(themeModeProvider);
    final notifier = ref.read(appSettingsAsyncProvider.notifier);

    return AppPageScaffold(
      title: 'Settings',
      subtitle: 'Personalize app behavior and local data control.',
      body: ListView(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Theme Mode', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.phone_android_rounded), label: Text('System')),
                      ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode_rounded), label: Text('Light')),
                      ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode_rounded), label: Text('Dark')),
                    ],
                    selected: {selectedMode},
                    onSelectionChanged: (selection) {
                      notifier.setThemeMode(selection.first);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          const PlaceholderCard(
            icon: Icons.save_alt_rounded,
            title: 'Local Backup Export',
            description: 'Phase 2 will export habits and completions to a local JSON backup.',
          ),
          const SizedBox(height: 12),
          const PlaceholderCard(
            icon: Icons.restore_rounded,
            title: 'Local Backup Import',
            description: 'Phase 2 will validate and import backups without cloud dependency.',
          ),
        ],
      ),
    );
  }
}
