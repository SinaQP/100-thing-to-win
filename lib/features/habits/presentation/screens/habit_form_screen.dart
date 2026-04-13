import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:things_to_win/core/constants/app_routes.dart';
import 'package:things_to_win/core/theme/app_colors.dart';
import 'package:things_to_win/core/theme/app_motion.dart';
import 'package:things_to_win/core/theme/app_spacing.dart';
import 'package:things_to_win/core/utils/id_generator.dart';
import 'package:things_to_win/core/widgets/app_buttons.dart';
import 'package:things_to_win/core/widgets/app_card.dart';
import 'package:things_to_win/core/widgets/app_section_header.dart';
import 'package:things_to_win/core/widgets/app_state_view.dart';
import 'package:things_to_win/features/habits/domain/entities/habit.dart';
import 'package:things_to_win/features/habits/presentation/constants/habit_form_options.dart';
import 'package:things_to_win/features/habits/presentation/providers/habits_providers.dart';
import 'package:things_to_win/features/habits/presentation/utils/habit_validation.dart';
import 'package:things_to_win/features/habits/presentation/widgets/habit_category_selector.dart';
import 'package:things_to_win/features/habits/presentation/widgets/habit_color_selector.dart';
import 'package:things_to_win/features/habits/presentation/widgets/habit_icon_selector.dart';
import 'package:things_to_win/features/settings/presentation/providers/theme_mode_provider.dart';

class HabitFormScreen extends ConsumerStatefulWidget {
  const HabitFormScreen({
    this.habitId,
    this.isFirstHabitSetup = false,
    super.key,
  });

  final String? habitId;
  final bool isFirstHabitSetup;

  @override
  ConsumerState<HabitFormScreen> createState() => _HabitFormScreenState();
}

class _HabitFormScreenState extends ConsumerState<HabitFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  var _category = habitCategoryOptions.first.value;
  var _iconKey = habitIconOptions.first.key;
  var _colorHex = habitColorOptions.first;

  Habit? _editingHabit;
  var _isLoading = false;
  var _isSaving = false;
  var _hasSubmitted = false;

  bool get _isEditing => widget.habitId != null;

  @override
  void initState() {
    super.initState();
    _loadHabitIfNeeded();
  }

  Future<void> _loadHabitIfNeeded() async {
    if (!_isEditing) {
      return;
    }

    setState(() => _isLoading = true);
    final repository = await ref.read(habitsRepositoryProvider.future);
    final habit = await repository.getHabitById(widget.habitId!);

    if (!mounted) {
      return;
    }

    if (habit == null) {
      context.go(AppRoutes.habits);
      return;
    }

    _editingHabit = habit;
    _titleController.text = habit.title;
    _descriptionController.text = habit.description ?? '';
    _category = habit.category;
    _iconKey = habit.iconKey;
    _colorHex = habit.colorHex;

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _hasSubmitted = true);
    final validated = _formKey.currentState?.validate() ?? false;
    if (!validated || _isSaving) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final habitsActions = ref.read(habitsActionsProvider);
      final title = _titleController.text.trim();
      final descriptionRaw = _descriptionController.text.trim();

      if (_isEditing && _editingHabit != null) {
        final updatedHabit = _editingHabit!.copyWith(
          title: title,
          description: descriptionRaw.isEmpty ? null : descriptionRaw,
          category: _category,
          iconKey: _iconKey,
          colorHex: _colorHex,
        );
        await habitsActions.updateHabit(updatedHabit);
      } else {
        final habits = await ref.read(habitsListProvider.future);
        final newHabit = Habit(
          id: generateEntityId(),
          title: title,
          description: descriptionRaw.isEmpty ? null : descriptionRaw,
          category: _category,
          iconKey: _iconKey,
          colorHex: _colorHex,
          createdAt: DateTime.now(),
          order: habits.length,
        );
        await habitsActions.createHabit(newHabit);
      }

      if (!mounted) {
        return;
      }

      if (widget.isFirstHabitSetup) {
        await ref.read(appSettingsAsyncProvider.notifier).completeOnboarding();
        if (!mounted) {
          return;
        }
        context.go(AppRoutes.dashboard);
        return;
      }

      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.habits);
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not save the habit. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colors.background,
        body: const AppLoadingState(label: 'Loading habit details...'),
      );
    }

    final title = widget.isFirstHabitSetup
        ? 'Create your first habit'
        : (_isEditing ? 'Edit habit' : 'New habit');

    final subtitle = widget.isFirstHabitSetup
        ? 'Start with one simple daily standard.'
        : 'Keep it clear, recognizable, and easy to repeat.';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(widget.isFirstHabitSetup ? 'First habit' : 'Habit'),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: colors.pageGradient),
        child: SafeArea(
          top: false,
          child: Stack(
            children: [
              Positioned(
                top: -70,
                right: -24,
                child: _GlowOrb(
                  color: colors.backgroundGlow
                      .withValues(alpha: colors.isDark ? 0.22 : 0.18),
                  size: 220,
                ),
              ),
              Positioned(
                bottom: 120,
                left: -36,
                child: _GlowOrb(
                  color: colors.accent
                      .withValues(alpha: colors.isDark ? 0.11 : 0.08),
                  size: 160,
                ),
              ),
              Form(
                key: _formKey,
                autovalidateMode: _hasSubmitted
                    ? AutovalidateMode.onUserInteraction
                    : AutovalidateMode.disabled,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isCompact = constraints.maxWidth < 420;
                        final heroStyle = isCompact
                            ? Theme.of(context).textTheme.headlineLarge
                            : Theme.of(context).textTheme.displaySmall;

                        return ListView(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.pageHorizontal,
                            AppSpacing.lg,
                            AppSpacing.pageHorizontal,
                            AppSpacing.xxxl,
                          ),
                          children: [
                            AppFadeSlideIn(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: heroStyle),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    subtitle,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppScaleIn(
                              delay: const Duration(milliseconds: 50),
                              child: _HabitPreview(
                                title: _titleController.text.trim().isEmpty
                                    ? 'Your habit'
                                    : _titleController.text.trim(),
                                category: _category,
                                description: _descriptionController.text.trim(),
                                icon: habitIconByKey(_iconKey),
                                color: Color(_colorHex),
                                compact: isCompact,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppFadeSlideIn(
                              delay: const Duration(milliseconds: 80),
                              child: AppCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const AppSectionHeader(
                                      title: 'Habit basics',
                                      subtitle:
                                          'Keep it specific and easy to recognize at a glance.',
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    TextFormField(
                                      controller: _titleController,
                                      decoration: const InputDecoration(
                                        labelText: 'Habit name',
                                        hintText: 'e.g. 30 min deep work',
                                        errorMaxLines: 2,
                                      ),
                                      textInputAction: TextInputAction.next,
                                      validator: validateHabitTitle,
                                      onChanged: (_) => setState(() {}),
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    TextFormField(
                                      controller: _descriptionController,
                                      minLines: 3,
                                      maxLines: 4,
                                      decoration: const InputDecoration(
                                        labelText: 'Description (optional)',
                                        hintText:
                                            'Short note to keep this habit clear.',
                                        errorMaxLines: 2,
                                      ),
                                      validator: validateHabitDescription,
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppFadeSlideIn(
                              delay: const Duration(milliseconds: 120),
                              child: AppCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const AppSectionHeader(
                                      title: 'Category',
                                      subtitle:
                                          'Give the habit a role so it is easier to scan in your daily list.',
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    HabitCategorySelector(
                                      selectedCategory: _category,
                                      onSelected: (value) =>
                                          setState(() => _category = value),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppFadeSlideIn(
                              delay: const Duration(milliseconds: 160),
                              child: AppCard(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const AppSectionHeader(
                                      title: 'Identity',
                                      subtitle:
                                          'Choose an icon and color that make the habit instantly recognizable.',
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    Text(
                                      'Icon',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    HabitIconSelector(
                                      selectedIconKey: _iconKey,
                                      onSelected: (value) =>
                                          setState(() => _iconKey = value),
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    Divider(color: colors.divider),
                                    const SizedBox(height: AppSpacing.lg),
                                    Text(
                                      'Color',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    HabitColorSelector(
                                      selectedColorHex: _colorHex,
                                      onSelected: (value) =>
                                          setState(() => _colorHex = value),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            AppFadeSlideIn(
                              delay: const Duration(milliseconds: 210),
                              child: _FormActions(
                                isCompact: isCompact,
                                isSaving: _isSaving,
                                isFirstHabitSetup: widget.isFirstHabitSetup,
                                isEditing: _isEditing,
                                onCancel: _isSaving
                                    ? null
                                    : () {
                                        if (context.canPop()) {
                                          context.pop();
                                        } else {
                                          context.go(AppRoutes.habits);
                                        }
                                      },
                                onSave: _save,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HabitPreview extends StatelessWidget {
  const _HabitPreview({
    required this.title,
    required this.category,
    required this.description,
    required this.icon,
    required this.color,
    required this.compact,
  });

  final String title;
  final String category;
  final String description;
  final IconData icon;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return AppCard(
      borderRadius: BorderRadius.circular(28),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          colors.card,
          color.withValues(alpha: colors.isDark ? 0.18 : 0.16),
        ],
      ),
      child: compact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PreviewIcon(icon: icon, color: color),
                const SizedBox(height: AppSpacing.md),
                _PreviewText(
                  title: title,
                  category: category,
                  description: description,
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _PreviewIcon(icon: icon, color: color),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _PreviewText(
                    title: title,
                    category: category,
                    description: description,
                  ),
                ),
              ],
            ),
    );
  }
}

class _PreviewIcon extends StatelessWidget {
  const _PreviewIcon({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.26),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}

class _PreviewText extends StatelessWidget {
  const _PreviewText({
    required this.title,
    required this.category,
    required this.description,
  });

  final String title;
  final String category;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.appColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preview',
          style:
              theme.textTheme.labelSmall?.copyWith(color: colors.accentStrong),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: colors.surfaceElevated
                .withValues(alpha: colors.isDark ? 0.68 : 0.72),
          ),
          child: Text(category, style: theme.textTheme.labelSmall),
        ),
        if (description.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(description, style: theme.textTheme.bodySmall),
        ],
      ],
    );
  }
}

class _FormActions extends StatelessWidget {
  const _FormActions({
    required this.isCompact,
    required this.isSaving,
    required this.isFirstHabitSetup,
    required this.isEditing,
    required this.onCancel,
    required this.onSave,
  });

  final bool isCompact;
  final bool isSaving;
  final bool isFirstHabitSetup;
  final bool isEditing;
  final VoidCallback? onCancel;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final saveLabel = isFirstHabitSetup
        ? 'Start'
        : (isEditing ? 'Save habit' : 'Create habit');

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPrimaryButton(
            label: saveLabel,
            icon: Icons.check_rounded,
            isLoading: isSaving,
            onPressed: onSave,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppGhostButton(
            label: 'Back',
            icon: Icons.arrow_back_rounded,
            onPressed: onCancel,
          ),
        ],
      );
    }

    return Row(
      children: [
        Flexible(
          child: AppGhostButton(
            label: 'Back',
            icon: Icons.arrow_back_rounded,
            onPressed: onCancel,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          flex: 2,
          child: AppPrimaryButton(
            label: saveLabel,
            icon: Icons.check_rounded,
            isLoading: isSaving,
            onPressed: onSave,
          ),
        ),
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
