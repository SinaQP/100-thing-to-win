import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:things_to_win/core/constants/app_routes.dart';
import 'package:things_to_win/features/settings/presentation/providers/theme_mode_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  var _index = 0;

  static const _slides = <_OnboardingSlideData>[
    _OnboardingSlideData(
      title: 'Turn Intent Into Daily Wins',
      subtitle: 'Capture the habits that matter, then win each day with clarity and momentum.',
      icon: Icons.emoji_events_rounded,
    ),
    _OnboardingSlideData(
      title: 'Progress You Can Feel',
      subtitle: 'Track completion, streaks, and consistency with an offline-first experience that never waits.',
      icon: Icons.stacked_line_chart_rounded,
    ),
    _OnboardingSlideData(
      title: 'Start With Your First Habit',
      subtitle: 'Choose your category, color, and icon, then build your first daily standard.',
      icon: Icons.auto_awesome_rounded,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _skip() async {
    await ref.read(appSettingsAsyncProvider.notifier).completeOnboarding();
    if (!mounted) {
      return;
    }
    context.go(AppRoutes.dashboard);
  }

  void _next() {
    if (_index == _slides.length - 1) {
      context.go(AppRoutes.firstHabitSetup);
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLast = _index == _slides.length - 1;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primary.withOpacity(0.12),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('100 Things to Win', style: theme.textTheme.titleMedium),
                    TextButton(onPressed: _skip, child: const Text('Skip')),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    itemCount: _slides.length,
                    onPageChanged: (value) => setState(() => _index = value),
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return _OnboardingSlide(
                        data: slide,
                        isActive: index == _index,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _index == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: _index == index
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.26),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _next,
                    child: Text(isLast ? 'Set Up My First Habit' : 'Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingSlideData {
  const _OnboardingSlideData({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class _OnboardingSlide extends StatelessWidget {
  const _OnboardingSlide({
    required this.data,
    required this.isActive,
  });

  final _OnboardingSlideData data;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 240),
      opacity: isActive ? 1 : 0.6,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            width: double.infinity,
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withOpacity(0.22),
                  theme.colorScheme.secondary.withOpacity(0.14),
                ],
              ),
            ),
            child: Center(
              child: Container(
                width: 98,
                height: 98,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface.withOpacity(0.9),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.28),
                      blurRadius: 26,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(data.icon, size: 48, color: theme.colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Text(data.title, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 12),
          Text(data.subtitle, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
