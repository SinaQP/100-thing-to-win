import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:things_to_win/core/constants/app_routes.dart';
import 'package:things_to_win/core/utils/id_generator.dart';
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

      if (widget.isFirstHabitSetup) {
        await ref.read(appSettingsAsyncProvider.notifier).completeOnboarding();
        if (!mounted) {
          return;
        }
        context.go(AppRoutes.dashboard);
        return;
      }

      if (!mounted) {
        return;
      }
      context.pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save habit: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final title = widget.isFirstHabitSetup
        ? 'Create Your First Habit'
        : (_isEditing ? 'Edit Habit' : 'New Habit');

    final subtitle = widget.isFirstHabitSetup
        ? 'Start strong with one daily standard you can keep.'
        : 'Design the habit with a category, icon, and signature color.';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
            children: [
              Text(subtitle, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 16),
              _HabitPreview(
                title: _titleController.text.trim().isEmpty ? 'Your Habit' : _titleController.text.trim(),
                category: _category,
                icon: habitIconByKey(_iconKey),
                color: Color(_colorHex),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Habit name',
                  hintText: 'e.g. 30 min deep work',
                ),
                textInputAction: TextInputAction.next,
                validator: validateHabitTitle,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  hintText: 'Short note to keep this habit clear.',
                ),
                validator: validateHabitDescription,
              ),
              const SizedBox(height: 18),
              Text('Category', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              HabitCategorySelector(
                selectedCategory: _category,
                onSelected: (value) => setState(() => _category = value),
              ),
              const SizedBox(height: 18),
              Text('Icon', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              HabitIconSelector(
                selectedIconKey: _iconKey,
                onSelected: (value) => setState(() => _iconKey = value),
              ),
              const SizedBox(height: 18),
              Text('Color', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              HabitColorSelector(
                selectedColorHex: _colorHex,
                onSelected: (value) => setState(() => _colorHex = value),
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _save,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(
                    widget.isFirstHabitSetup
                        ? 'Start Winning'
                        : (_isEditing ? 'Save Changes' : 'Create Habit'),
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
    required this.icon,
    required this.color,
  });

  final String title;
  final String category;
  final IconData icon;
  final Color color;

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
            color.withOpacity(0.24),
            color.withOpacity(0.08),
          ],
        ),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(category, style: theme.textTheme.bodySmall),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
