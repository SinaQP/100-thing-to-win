import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:things_to_win/core/constants/app_routes.dart';
import 'package:things_to_win/core/theme/app_colors.dart';
import 'package:things_to_win/core/theme/app_spacing.dart';
import 'package:things_to_win/core/widgets/app_card.dart';
import 'package:things_to_win/core/widgets/app_page_scaffold.dart';
import 'package:things_to_win/core/widgets/app_state_view.dart';
import 'package:things_to_win/features/history/presentation/providers/history_providers.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewAsync = ref.watch(historyOverviewProvider);

    return AppPageScaffold(
      title: 'History',
      subtitle: 'Review consistency day by day.',
      body: overviewAsync.when(
        data: (overview) {
          if (overview.activeHabitsCount == 0) {
            return AppEmptyState(
              title: 'No habits yet',
              message:
                  'Create your first habit to start building history day by day.',
              actionLabel: 'Create first habit',
              onAction: () => context.push(AppRoutes.habitCreate),
              icon: Icons.flag_rounded,
            );
          }

          return _HistoryContent(overview: overview);
        },
        loading: () => const AppLoadingState(label: 'Loading history...'),
        error: (error, stackTrace) => AppErrorState(
          title: 'Could not load history',
          message: error.toString(),
          onRetry: () => ref.invalidate(historyOverviewProvider),
        ),
      ),
    );
  }
}

class _HistoryContent extends ConsumerWidget {
  const _HistoryContent({
    required this.overview,
  });

  final HistoryOverview overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDay = ref.watch(selectedHistoryDayProvider);
    final selectedSummary =
        selectedDay == null ? null : overview.daySummaryFor(selectedDay);

    return ListView(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxxl),
      children: [
        _MonthSelector(
          month: overview.month,
          onPrevious: () {
            ref.read(selectedHistoryMonthProvider.notifier).state =
                DateTime(overview.month.year, overview.month.month - 1);
            ref.read(selectedHistoryDayProvider.notifier).state = null;
          },
          onNext: () {
            ref.read(selectedHistoryMonthProvider.notifier).state =
                DateTime(overview.month.year, overview.month.month + 1);
            ref.read(selectedHistoryDayProvider.notifier).state = null;
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        _MonthHeatmapCard(
          overview: overview,
          selectedDay: selectedDay,
          onSelectDay: (day) {
            ref.read(selectedHistoryDayProvider.notifier).state = day;
          },
        ),
        if (!overview.hasAnyCompletedInSelectedMonth) ...[
          const SizedBox(height: AppSpacing.md),
          const AppCard(
            child: Text(
              'No completions in this month yet. Switch month or complete habits today to start the timeline.',
            ),
          ),
        ],
        if (selectedSummary != null) ...[
          const SizedBox(height: AppSpacing.lg),
          _SelectedDayCard(summary: selectedSummary),
        ],
        const SizedBox(height: AppSpacing.lg),
        _RecentTimelineCard(overview: overview),
      ],
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final monthLabel = localizations.formatMonthYear(month);

    return AppCard(
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left_rounded),
            tooltip: 'Previous month',
          ),
          Expanded(
            child: Text(
              monthLabel,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right_rounded),
            tooltip: 'Next month',
          ),
        ],
      ),
    );
  }
}

class _MonthHeatmapCard extends StatelessWidget {
  const _MonthHeatmapCard({
    required this.overview,
    required this.selectedDay,
    required this.onSelectDay,
  });

  final HistoryOverview overview;
  final DateTime? selectedDay;
  final ValueChanged<DateTime> onSelectDay;

  @override
  Widget build(BuildContext context) {
    final month = overview.month;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekdayOffset = DateTime(month.year, month.month, 1).weekday - 1;
    final totalCells = ((firstWeekdayOffset + daysInMonth + 6) ~/ 7) * 7;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Monthly completion',
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          const _WeekdayHeader(),
          const SizedBox(height: AppSpacing.xs),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: AppSpacing.xs,
              crossAxisSpacing: AppSpacing.xs,
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final dayNumber = index - firstWeekdayOffset + 1;
              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final day = DateTime(month.year, month.month, dayNumber);
              final summary = overview.daySummaryFor(day);
              final isSelected =
                  selectedDay != null && DateUtils.isSameDay(selectedDay, day);

              return _DayCell(
                day: day,
                summary: summary,
                isSelected: isSelected,
                onTap: () => onSelectDay(day),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  static const _labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: _labels
          .map(
            (label) => Expanded(
              child: Center(
                child: Text(
                  label,
                  style: theme.textTheme.labelSmall,
                ),
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.summary,
    required this.isSelected,
    required this.onTap,
  });

  final DateTime day;
  final HistoryDaySummary? summary;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final theme = Theme.of(context);
    final ratio = summary?.completionRatio ?? 0.0;
    final now = DateTime.now();
    final isToday = DateUtils.isSameDay(now, day);

    final cellColor = Color.lerp(
          colors.cardMuted,
          colors.accent,
          ratio.clamp(0.0, 1.0),
        ) ??
        colors.cardMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: cellColor.withValues(
                alpha: ratio == 0 ? (colors.isDark ? 0.36 : 0.3) : 0.78),
            border: Border.all(
              color: isSelected
                  ? colors.accentStrong
                  : (isToday ? colors.accent : colors.border),
              width: isSelected ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '${day.day}',
            style: theme.textTheme.labelMedium,
          ),
        ),
      ),
    );
  }
}

class _SelectedDayCard extends StatelessWidget {
  const _SelectedDayCard({
    required this.summary,
  });

  final HistoryDaySummary summary;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final dateLabel = localizations.formatFullDate(summary.date);
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(dateLabel, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${summary.completedCount}/${summary.totalCount} completed',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          if (summary.completedHabitNames.isEmpty)
            const Text('No completed habits on this day.')
          else
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: summary.completedHabitNames
                  .map(
                    (habitName) => Chip(
                      label: Text(habitName),
                      visualDensity: VisualDensity.compact,
                    ),
                  )
                  .toList(growable: false),
            ),
        ],
      ),
    );
  }
}

class _RecentTimelineCard extends StatelessWidget {
  const _RecentTimelineCard({
    required this.overview,
  });

  final HistoryOverview overview;

  @override
  Widget build(BuildContext context) {
    final localizations = MaterialLocalizations.of(context);
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Recent activity', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.sm),
          if (overview.recentTimeline.isEmpty)
            const Text('No recent activity yet.')
          else
            ...overview.recentTimeline.map(
              (day) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        localizations.formatMediumDate(day.date),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${day.completedCount}/${day.totalCount}',
                      style: theme.textTheme.titleSmall,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
