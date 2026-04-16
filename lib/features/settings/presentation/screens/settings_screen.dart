import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:things_to_win/core/theme/app_spacing.dart';
import 'package:things_to_win/core/widgets/app_buttons.dart';
import 'package:things_to_win/core/widgets/app_card.dart';
import 'package:things_to_win/core/widgets/app_page_scaffold.dart';
import 'package:things_to_win/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:things_to_win/features/habits/presentation/providers/habits_providers.dart';
import 'package:things_to_win/features/history/presentation/providers/history_providers.dart';
import 'package:things_to_win/features/insights/presentation/providers/insights_providers.dart';
import 'package:things_to_win/features/settings/domain/entities/app_backup.dart';
import 'package:things_to_win/features/settings/presentation/providers/theme_mode_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  var _isExporting = false;
  var _isImporting = false;

  @override
  Widget build(BuildContext context) {
    final selectedMode = ref.watch(themeModeProvider);
    final notifier = ref.read(appSettingsAsyncProvider.notifier);

    return AppPageScaffold(
      title: 'Settings',
      subtitle: 'Personalize app behavior and local data control.',
      body: ListView(
        children: [
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme Mode',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.phone_android_rounded),
                      label: Text('System'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_rounded),
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_rounded),
                      label: Text('Dark'),
                    ),
                  ],
                  selected: {selectedMode},
                  onSelectionChanged: (selection) {
                    notifier.setThemeMode(selection.first);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Local backup',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Export habits and entries as versioned JSON. Import supports merge (keep existing + apply backup) or replace (wipe local habits data first).',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.md),
                AppPrimaryButton(
                  label: 'Export Backup',
                  icon: Icons.save_alt_rounded,
                  isLoading: _isExporting,
                  onPressed: _isImporting ? null : _onExportPressed,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppGhostButton(
                  label: 'Import Backup',
                  icon: Icons.restore_rounded,
                  onPressed:
                      (_isImporting || _isExporting) ? null : _onImportPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onExportPressed() async {
    setState(() => _isExporting = true);
    try {
      final repo = await ref.read(settingsRepositoryProvider.future);
      final result = await repo.exportBackup();
      _showMessage(
        'Backup exported (${result.habitsCount} habits, ${result.habitEntriesCount} entries): ${result.filePath}',
      );
    } catch (error) {
      _showMessage('Export failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  Future<void> _onImportPressed() async {
    setState(() => _isImporting = true);
    try {
      final path = await _showImportPathDialog();
      if (path == null) {
        return;
      }

      if (!mounted) return;
      final mode = await _showImportModeDialog();
      if (mode == null) {
        return;
      }

      if (mode == BackupImportMode.replace) {
        final confirmed = await _showReplaceConfirmationDialog();
        if (!confirmed) {
          return;
        }
      }

      final repo = await ref.read(settingsRepositoryProvider.future);
      final result = await repo.importBackup(filePath: path, mode: mode);
      _invalidateDataProviders();
      _showMessage(
        'Import complete (${result.habitsCount} habits, ${result.habitEntriesCount} entries).',
      );
    } catch (error) {
      _showMessage('Import failed: $error');
    } finally {
      if (mounted) {
        setState(() => _isImporting = false);
      }
    }
  }

  void _invalidateDataProviders() {
    ref.invalidate(habitsListProvider);
    ref.invalidate(todayHabitCompletionsProvider);
    ref.invalidate(dashboardSummaryProvider);
    ref.invalidate(historyOverviewProvider);
    ref.invalidate(insightsOverviewProvider);
  }

  Future<BackupImportMode?> _showImportModeDialog() async {
    return showDialog<BackupImportMode>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Import Mode'),
          content: const Text(
            'Choose how to apply the backup.\n\n'
            'Merge: keep current data and apply backup records.\n'
            'Replace: clear local habits data and restore only from backup.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(BackupImportMode.merge),
              child: const Text('Merge'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(BackupImportMode.replace),
              child: const Text('Replace'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showImportPathDialog() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Backup File'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the full path to a local backup JSON file.',
              ),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: r'e.g. /storage/.../things_to_win_backup.json',
                ),
                minLines: 1,
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );
    final normalized = result?.trim();
    if (normalized == null || normalized.isEmpty) {
      return null;
    }
    return normalized;
  }

  Future<bool> _showReplaceConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Replace Import'),
          content: const Text(
            'Replace import will remove all current local habits and history before restoring from the selected backup file.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Replace Local Data'),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
