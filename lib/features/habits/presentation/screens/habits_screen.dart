import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:things_to_win/core/constants/app_routes.dart';
import 'package:things_to_win/core/widgets/app_page_scaffold.dart';
import 'package:things_to_win/features/habits/domain/entities/habit.dart';
import 'package:things_to_win/features/habits/presentation/constants/habit_form_options.dart';
import 'package:things_to_win/features/habits/presentation/providers/habits_providers.dart';
import 'package:things_to_win/features/habits/presentation/widgets/premium_empty_state.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  Future<void> _onMenuAction(
    BuildContext context,
    WidgetRef ref,
    Habit habit,
    _HabitMenuAction action,
  ) async {
    final actions = ref.read(habitsActionsProvider);

    switch (action) {
      case _HabitMenuAction.edit:
        context.push(AppRoutes.habitEdit(habit.id));
        return;
      case _HabitMenuAction.archive:
        await actions.archiveHabit(habitId: habit.id, archived: true);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${habit.title}" archived.')),
        );
        return;
      case _HabitMenuAction.delete:
        await actions.deleteHabit(habit.id);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${habit.title}" deleted.')),
        );
        return;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsListProvider);
    final todayCompletionAsync = ref.watch(todayHabitCompletionsProvider);

    return AppPageScaffold(
      title: 'Habits',
      subtitle: 'Design the standards that move your life forward.',
      body: habitsAsync.when(
        data: (habits) {
          if (habits.isEmpty) {
            return PremiumEmptyState(
              title: 'Your Winboard Is Empty',
              subtitle:
                  'Add your first habit and make the start intentional. One action done daily compounds faster than motivation.',
              ctaLabel: 'Create First Habit',
              onPressed: () => context.push(AppRoutes.habitCreate),
              icon: Icons.flag_rounded,
            );
          }

          return todayCompletionAsync.when(
            data: (completionMap) {
              final completedCount = habits.where((habit) => completionMap[habit.id] ?? false).length;
              final progressPercent = habits.isEmpty ? 0 : ((completedCount / habits.length) * 100).round();

              return ListView(
                children: [
                  _TodayProgressCard(
                    totalCount: habits.length,
                    completedCount: completedCount,
                    progressPercent: progressPercent,
                    onCreatePressed: () => context.push(AppRoutes.habitCreate),
                  ),
                  const SizedBox(height: 12),
                  ...habits.map(
                    (habit) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _HabitTile(
                        habit: habit,
                        completedToday: completionMap[habit.id] ?? false,
                        onToggle: (value) async {
                          await ref.read(habitsActionsProvider).toggleTodayCompletion(
                                habitId: habit.id,
                                isCompleted: value,
                              );
                        },
                        onMenuAction: (action) => _onMenuAction(context, ref, habit, action),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stackTrace) => Center(child: Text('Failed to load completion data: $error')),
          );
        },
        error: (error, stackTrace) => Center(child: Text('Failed to load habits: $error')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _TodayProgressCard extends StatelessWidget {
  const _TodayProgressCard({
    required this.totalCount,
    required this.completedCount,
    required this.progressPercent,
    required this.onCreatePressed,
  });

  final int totalCount;
  final int completedCount;
  final int progressPercent;
  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.17),
            theme.colorScheme.secondary.withOpacity(0.10),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Today: $completedCount / $totalCount completed',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              FilledButton.tonalIcon(
                onPressed: onCreatePressed,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: totalCount == 0 ? 0 : completedCount / totalCount,
            ),
          ),
          const SizedBox(height: 8),
          Text('$progressPercent% complete today', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _HabitTile extends StatelessWidget {
  const _HabitTile({
    required this.habit,
    required this.completedToday,
    required this.onToggle,
    required this.onMenuAction,
  });

  final Habit habit;
  final bool completedToday;
  final ValueChanged<bool> onToggle;
  final ValueChanged<_HabitMenuAction> onMenuAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = Color(habit.colorHex);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.28),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(habitIconByKey(habit.iconKey), color: Colors.white),
        ),
        title: Text(
          habit.title,
          style: theme.textTheme.titleMedium?.copyWith(
            decoration: completedToday ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: theme.colorScheme.surfaceContainerHighest,
                ),
                child: Text(habit.category, style: theme.textTheme.bodySmall),
              ),
              if (habit.description != null && habit.description!.isNotEmpty)
                Text(habit.description!, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: completedToday,
              onChanged: (value) => onToggle(value ?? false),
            ),
            PopupMenuButton<_HabitMenuAction>(
              onSelected: onMenuAction,
              itemBuilder: (context) => const [
                PopupMenuItem(value: _HabitMenuAction.edit, child: Text('Edit')),
                PopupMenuItem(value: _HabitMenuAction.archive, child: Text('Archive')),
                PopupMenuItem(value: _HabitMenuAction.delete, child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _HabitMenuAction {
  edit,
  archive,
  delete,
}
