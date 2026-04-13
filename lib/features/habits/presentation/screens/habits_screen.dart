import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:things_to_win/core/constants/app_routes.dart';
import 'package:things_to_win/core/theme/app_colors.dart';
import 'package:things_to_win/core/theme/app_motion.dart';
import 'package:things_to_win/core/theme/app_spacing.dart';
import 'package:things_to_win/core/widgets/app_buttons.dart';
import 'package:things_to_win/core/widgets/app_card.dart';
import 'package:things_to_win/core/widgets/app_page_scaffold.dart';
import 'package:things_to_win/core/widgets/app_progress_bar.dart';
import 'package:things_to_win/core/widgets/app_section_header.dart';
import 'package:things_to_win/core/widgets/app_state_view.dart';
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
      trailing: AppPrimaryButton(
        label: 'Add habit',
        icon: Icons.add_rounded,
        expand: false,
        onPressed: () => context.push(AppRoutes.habitCreate),
      ),
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
            data: (completionMap) => _HabitsContent(
              habits: habits,
              completionMap: completionMap,
              onCreatePressed: () => context.push(AppRoutes.habitCreate),
              onToggle: (habitId, value) async {
                await ref.read(habitsActionsProvider).toggleTodayCompletion(
                      habitId: habitId,
                      isCompleted: value,
                    );
              },
              onMenuAction: (habit, action) =>
                  _onMenuAction(context, ref, habit, action),
            ),
            loading: () =>
                const AppLoadingState(label: 'Loading today progress...'),
            error: (error, stackTrace) => AppErrorState(
              title: 'Could not load today progress',
              message: error.toString(),
            ),
          );
        },
        error: (error, stackTrace) => AppErrorState(
          title: 'Could not load habits',
          message: error.toString(),
        ),
        loading: () => const AppLoadingState(label: 'Loading habits...'),
      ),
    );
  }
}

class _HabitsContent extends StatelessWidget {
  const _HabitsContent({
    required this.habits,
    required this.completionMap,
    required this.onCreatePressed,
    required this.onToggle,
    required this.onMenuAction,
  });

  final List<Habit> habits;
  final Map<String, bool> completionMap;
  final VoidCallback onCreatePressed;
  final Future<void> Function(String habitId, bool value) onToggle;
  final Future<void> Function(Habit habit, _HabitMenuAction action)
      onMenuAction;

  @override
  Widget build(BuildContext context) {
    final completedCount =
        habits.where((habit) => completionMap[habit.id] ?? false).length;
    final progress = habits.isEmpty ? 0.0 : completedCount / habits.length;

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      children: [
        AppFadeSlideIn(
          child: _TodayProgressCard(
            totalCount: habits.length,
            completedCount: completedCount,
            progress: progress,
            onCreatePressed: onCreatePressed,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        AppFadeSlideIn(
          delay: const Duration(milliseconds: 40),
          child: AppSectionHeader(
            title: 'Your standards',
            subtitle: completedCount == habits.length
                ? 'Everything is complete for today.'
                : 'Stay focused on the next win. Every check keeps the streak alive.',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...habits.asMap().entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: AppFadeSlideIn(
                  delay: Duration(milliseconds: 70 + (entry.key * 35)),
                  child: _HabitTile(
                    habit: entry.value,
                    completedToday: completionMap[entry.value.id] ?? false,
                    onToggle: (value) => onToggle(entry.value.id, value),
                    onMenuAction: (action) => onMenuAction(entry.value, action),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

class _TodayProgressCard extends StatelessWidget {
  const _TodayProgressCard({
    required this.totalCount,
    required this.completedCount,
    required this.progress,
    required this.onCreatePressed,
  });

  final int totalCount;
  final int completedCount;
  final double progress;
  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final progressPercent = (progress * 100).round();

    return AppCard(
      borderRadius: BorderRadius.circular(28),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colors.card,
          colors.accentSoft.withValues(alpha: colors.isDark ? 0.55 : 0.9),
        ],
      ),
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
                    Text('TODAY',
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: colors.accentStrong)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '$completedCount of $totalCount habits complete',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      progress == 1
                          ? 'You closed the day with full momentum.'
                          : 'Keep the pace calm and consistent. One completed action at a time.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              AppScaleIn(
                delay: const Duration(milliseconds: 80),
                child: AppProgressRing(
                  value: progress,
                  label: '$progressPercent%',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppProgressBar(value: progress),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _ProgressMeta(
                  label: 'Completed today',
                  value: '$completedCount',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ProgressMeta(
                  label: 'Remaining',
                  value:
                      '${(totalCount - completedCount).clamp(0, totalCount)}',
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              AppGhostButton(
                label: 'New habit',
                icon: Icons.add_rounded,
                onPressed: onCreatePressed,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressMeta extends StatelessWidget {
  const _ProgressMeta({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: colors.surfaceElevated
            .withValues(alpha: colors.isDark ? 0.72 : 0.7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelSmall),
          const SizedBox(height: AppSpacing.xxs),
          Text(value, style: theme.textTheme.titleMedium),
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
    final colors = context.appColors;
    final color = Color(habit.colorHex);

    return AppCard(
      onTap: () => onToggle(!completedToday),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      child: Row(
        children: [
          AppCompletionFeedback(
            completed: completedToday,
            child: AnimatedContainer(
              duration: AppMotion.short,
              curve: AppMotion.emphasisCurve,
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: completedToday ? 0.2 : 0.28),
                    blurRadius: completedToday ? 12 : 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(habitIconByKey(habit.iconKey), color: Colors.white),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    decoration:
                        completedToday ? TextDecoration.lineThrough : null,
                    color: completedToday ? colors.textSecondary : null,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: colors.cardMuted,
                      ),
                      child: Text(habit.category,
                          style: theme.textTheme.labelSmall),
                    ),
                    if (habit.description != null &&
                        habit.description!.isNotEmpty)
                      Text(
                        habit.description!,
                        style: theme.textTheme.bodySmall,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            children: [
              Checkbox(
                value: completedToday,
                onChanged: (value) => onToggle(value ?? false),
              ),
              PopupMenuButton<_HabitMenuAction>(
                icon: const Icon(Icons.more_horiz_rounded),
                onSelected: onMenuAction,
                itemBuilder: (context) => const [
                  PopupMenuItem(
                      value: _HabitMenuAction.edit, child: Text('Edit')),
                  PopupMenuItem(
                      value: _HabitMenuAction.archive, child: Text('Archive')),
                  PopupMenuItem(
                      value: _HabitMenuAction.delete, child: Text('Delete')),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _HabitMenuAction {
  edit,
  archive,
  delete,
}
