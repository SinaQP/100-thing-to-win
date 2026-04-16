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
import 'package:things_to_win/core/widgets/app_state_view.dart';
import 'package:things_to_win/features/dashboard/presentation/providers/dashboard_providers.dart';
import 'package:things_to_win/features/habits/presentation/constants/habit_form_options.dart';
import 'package:things_to_win/features/habits/presentation/providers/habits_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return AppPageScaffold(
      title: 'Today',
      subtitle: 'Win your day one thing at a time.',
      trailing: AppPrimaryButton(
        label: 'Open habits',
        icon: Icons.flag_rounded,
        expand: false,
        onPressed: () => context.go(AppRoutes.habits),
      ),
      body: summaryAsync.when(
        data: (summary) {
          if (summary.totalHabits == 0) {
            return AppEmptyState(
              title: 'No habits yet',
              message:
                  'Create your first habit to start tracking daily wins on this dashboard.',
              actionLabel: 'Create first habit',
              onAction: () => context.push(AppRoutes.habitCreate),
              icon: Icons.flag_rounded,
            );
          }

          return _DashboardContent(
            summary: summary,
            onToggleTodayHabit: (habitId, isCompleted) async {
              await ref.read(habitsActionsProvider).toggleTodayCompletion(
                    habitId: habitId,
                    isCompleted: isCompleted,
                  );
            },
          );
        },
        loading: () => const AppLoadingState(label: 'Loading today summary...'),
        error: (error, stackTrace) => AppErrorState(
          title: 'Could not load dashboard',
          message: error.toString(),
          onRetry: () => ref.invalidate(dashboardSummaryProvider),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.summary,
    required this.onToggleTodayHabit,
  });

  final DashboardSummary summary;
  final Future<void> Function(String habitId, bool isCompleted)
      onToggleTodayHabit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      children: [
        AppFadeSlideIn(
          child: _TodayProgressCard(summary: summary),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppFadeSlideIn(
          delay: const Duration(milliseconds: 60),
          child: _StreakHighlightsCard(summary: summary),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppFadeSlideIn(
          delay: const Duration(milliseconds: 120),
          child: _TodayHabitsCard(
            summary: summary,
            onToggleTodayHabit: onToggleTodayHabit,
          ),
        ),
      ],
    );
  }
}

class _TodayProgressCard extends StatelessWidget {
  const _TodayProgressCard({
    required this.summary,
  });

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final progressPercent = (summary.todayProgress * 100).round();

    return AppCard(
      borderRadius: BorderRadius.circular(28),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colors.card,
          colors.accentSoft.withValues(alpha: colors.isDark ? 0.56 : 0.9),
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
                    Text(
                      'TODAY',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: colors.accentStrong),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${summary.completedTodayCount} of ${summary.totalHabits} habits complete',
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      summary.remainingTodayCount == 0
                          ? 'Everything is done for today. Keep the rhythm tomorrow.'
                          : '${summary.remainingTodayCount} habit${summary.remainingTodayCount == 1 ? '' : 's'} left to close the day.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              AppScaleIn(
                delay: const Duration(milliseconds: 80),
                child: AppProgressRing(
                  value: summary.todayProgress,
                  label: '$progressPercent%',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppProgressBar(value: summary.todayProgress),
        ],
      ),
    );
  }
}

class _StreakHighlightsCard extends StatelessWidget {
  const _StreakHighlightsCard({
    required this.summary,
  });

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;
    final topStreak = summary.topStreak;
    final hasActiveStreak = topStreak != null && topStreak.currentStreak > 0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Streak highlights',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            hasActiveStreak
                ? '"${topStreak.habit.title}" leads with a ${topStreak.currentStreak}-day streak.'
                : 'No active streak yet. Complete one habit today to start momentum.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _MetricTile(
                  label: 'Top current streak',
                  value: hasActiveStreak
                      ? '${topStreak.currentStreak} days'
                      : '0 days',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetricTile(
                  label: 'Avg 7-day completion',
                  value:
                      '${summary.averageWeeklyCompletionRate.round().clamp(0, 100)}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _MetricTile(
            label: 'Habits with active streak',
            value:
                '${summary.habitsWithActiveStreak} of ${summary.totalHabits}',
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: colors.surfaceElevated
            .withValues(alpha: colors.isDark ? 0.7 : 0.75),
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

class _TodayHabitsCard extends StatelessWidget {
  const _TodayHabitsCard({
    required this.summary,
    required this.onToggleTodayHabit,
  });

  final DashboardSummary summary;
  final Future<void> Function(String habitId, bool isCompleted)
      onToggleTodayHabit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's habits", style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Toggle completions directly to keep today updated in real time.',
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: colors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...summary.todayHabits.map(
            (habitSummary) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _TodayHabitTile(
                habitSummary: habitSummary,
                onToggleTodayHabit: onToggleTodayHabit,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayHabitTile extends StatelessWidget {
  const _TodayHabitTile({
    required this.habitSummary,
    required this.onToggleTodayHabit,
  });

  final DashboardHabitHighlight habitSummary;
  final Future<void> Function(String habitId, bool isCompleted)
      onToggleTodayHabit;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final habit = habitSummary.habit;
    final accentColor = Color(habit.colorHex);

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      color: colors.cardMuted.withValues(alpha: colors.isDark ? 0.45 : 0.75),
      onTap: () => onToggleTodayHabit(habit.id, !habitSummary.completedToday),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor,
            ),
            child: Icon(
              habitIconByKey(habit.iconKey),
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    decoration: habitSummary.completedToday
                        ? TextDecoration.lineThrough
                        : null,
                    color: habitSummary.completedToday
                        ? colors.textSecondary
                        : null,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  habit.category,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ),
          Checkbox(
            value: habitSummary.completedToday,
            onChanged: (value) => onToggleTodayHabit(habit.id, value ?? false),
          ),
        ],
      ),
    );
  }
}
