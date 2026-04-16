import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:things_to_win/core/constants/app_routes.dart';
import 'package:things_to_win/core/theme/app_colors.dart';
import 'package:things_to_win/core/theme/app_motion.dart';
import 'package:things_to_win/core/theme/app_spacing.dart';
import 'package:things_to_win/core/widgets/app_card.dart';
import 'package:things_to_win/core/widgets/app_page_scaffold.dart';
import 'package:things_to_win/core/widgets/app_progress_bar.dart';
import 'package:things_to_win/core/widgets/app_state_view.dart';
import 'package:things_to_win/features/insights/presentation/providers/insights_providers.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(insightsOverviewProvider);
    final selectedRange = ref.watch(selectedInsightsRangeProvider);

    return AppPageScaffold(
      title: 'Insights',
      subtitle: 'Understand momentum and consistency.',
      body: overviewAsync.when(
        data: (overview) {
          if (overview.totalHabits == 0) {
            return AppEmptyState(
              title: 'No habits yet',
              message: 'Create habits first to unlock completion analytics.',
              actionLabel: 'Create first habit',
              onAction: () => context.push(AppRoutes.habitCreate),
              icon: Icons.flag_rounded,
            );
          }

          return _InsightsContent(
            overview: overview,
            selectedRange: selectedRange,
            onRangeSelected: (range) {
              ref.read(selectedInsightsRangeProvider.notifier).state = range;
            },
          );
        },
        loading: () => const AppLoadingState(label: 'Loading insights...'),
        error: (error, stackTrace) => AppErrorState(
          title: 'Could not load insights',
          message: error.toString(),
          onRetry: () => ref.invalidate(insightsOverviewProvider),
        ),
      ),
    );
  }
}

class _InsightsContent extends StatelessWidget {
  const _InsightsContent({
    required this.overview,
    required this.selectedRange,
    required this.onRangeSelected,
  });

  final InsightsOverview overview;
  final InsightsRange selectedRange;
  final ValueChanged<InsightsRange> onRangeSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      children: [
        _RangeSelector(
          selected: selectedRange,
          onSelected: onRangeSelected,
        ),
        const SizedBox(height: AppSpacing.lg),
        AppFadeSlideIn(
          child: _OverallMetricsCard(overview: overview),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppFadeSlideIn(
          delay: const Duration(milliseconds: 60),
          child: _StreakInsightsCard(overview: overview),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppFadeSlideIn(
          delay: const Duration(milliseconds: 120),
          child: _RankingCard(overview: overview),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppFadeSlideIn(
          delay: const Duration(milliseconds: 160),
          child: _PerHabitSummaryCard(overview: overview),
        ),
      ],
    );
  }
}

class _RangeSelector extends StatelessWidget {
  const _RangeSelector({
    required this.selected,
    required this.onSelected,
  });

  final InsightsRange selected;
  final ValueChanged<InsightsRange> onSelected;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SegmentedButton<InsightsRange>(
        segments: const [
          ButtonSegment(
            value: InsightsRange.last7Days,
            label: Text('7 days'),
            icon: Icon(Icons.date_range_rounded),
          ),
          ButtonSegment(
            value: InsightsRange.last30Days,
            label: Text('30 days'),
            icon: Icon(Icons.calendar_month_rounded),
          ),
          ButtonSegment(
            value: InsightsRange.allTime,
            label: Text('All time'),
            icon: Icon(Icons.all_inclusive_rounded),
          ),
        ],
        selected: {selected},
        onSelectionChanged: (selection) => onSelected(selection.first),
      ),
    );
  }
}

class _OverallMetricsCard extends StatelessWidget {
  const _OverallMetricsCard({
    required this.overview,
  });

  final InsightsOverview overview;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final rate = overview.overallCompletionRate.clamp(0, 100).round();

    return AppCard(
      borderRadius: BorderRadius.circular(28),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colors.card,
          colors.accentSoft.withValues(alpha: colors.isDark ? 0.55 : 0.88),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall completion',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${overview.completedDaysSum} completed days across ${overview.trackedDaysSum} tracked habit-days.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              AppProgressRing(
                value: overview.overallCompletionRate / 100,
                label: '$rate%',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          AppProgressBar(value: overview.overallCompletionRate / 100),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MetricPill(
                  label: 'Today done',
                  value:
                      '${overview.completedTodayCount}/${overview.totalHabits}',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MetricPill(
                  label: 'Active habits',
                  value: '${overview.totalHabits}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Includes active (non-archived) habits only.',
            style: theme.textTheme.labelMedium
                ?.copyWith(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _StreakInsightsCard extends StatelessWidget {
  const _StreakInsightsCard({
    required this.overview,
  });

  final InsightsOverview overview;

  @override
  Widget build(BuildContext context) {
    final currentLeader = overview.topCurrentStreak;
    final bestLeader = overview.topBestStreak;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Streak insights',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          _MetricPill(
            label: 'Habits with active streak',
            value: '${overview.activeStreakHabits} of ${overview.totalHabits}',
          ),
          const SizedBox(height: AppSpacing.sm),
          _MetricPill(
            label: 'Top current streak',
            value: currentLeader == null
                ? 'No streak yet'
                : '${currentLeader.habit.title} (${currentLeader.stats.currentStreak} days)',
          ),
          const SizedBox(height: AppSpacing.sm),
          _MetricPill(
            label: 'Best streak in range',
            value: bestLeader == null
                ? 'No streak yet'
                : '${bestLeader.habit.title} (${bestLeader.stats.bestStreak} days)',
          ),
        ],
      ),
    );
  }
}

class _RankingCard extends StatelessWidget {
  const _RankingCard({
    required this.overview,
  });

  final InsightsOverview overview;

  @override
  Widget build(BuildContext context) {
    if (!overview.hasAnyCompletion) {
      return const AppCard(
        child: Text(
          'No completions in this range yet. Complete habits today to generate rankings.',
        ),
      );
    }

    final top = overview.ranking.take(3).toList(growable: false);
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Completion ranking', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          ...top.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _RankedHabitTile(
                    rank: entry.key + 1,
                    insight: entry.value,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _PerHabitSummaryCard extends StatelessWidget {
  const _PerHabitSummaryCard({
    required this.overview,
  });

  final InsightsOverview overview;

  @override
  Widget build(BuildContext context) {
    final sortedByName = [...overview.habitInsights]
      ..sort((a, b) => a.habit.title.compareTo(b.habit.title));

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Per-habit summary',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          ...sortedByName.map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _HabitSummaryRow(insight: insight),
            ),
          ),
        ],
      ),
    );
  }
}

class _RankedHabitTile extends StatelessWidget {
  const _RankedHabitTile({
    required this.rank,
    required this.insight,
  });

  final int rank;
  final HabitInsight insight;

  @override
  Widget build(BuildContext context) {
    final completionPercent =
        insight.stats.completionRate.clamp(0, 100).round();
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.appColors.surfaceElevated,
          ),
          child: Text('$rank'),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(insight.habit.title,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.xxs),
              AppProgressBar(
                  value: insight.stats.completionRate / 100, height: 8),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text('$completionPercent%'),
      ],
    );
  }
}

class _HabitSummaryRow extends StatelessWidget {
  const _HabitSummaryRow({
    required this.insight,
  });

  final HabitInsight insight;

  @override
  Widget build(BuildContext context) {
    final stats = insight.stats;
    final rate = stats.completionRate.clamp(0, 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          insight.habit.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          'Rate $rate% | Current streak ${stats.currentStreak} | Best streak ${stats.bestStreak}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
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
