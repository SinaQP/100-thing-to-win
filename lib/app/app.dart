import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:things_to_win/core/routing/app_router.dart';
import 'package:things_to_win/core/theme/app_theme.dart';
import 'package:things_to_win/features/settings/presentation/providers/theme_mode_provider.dart';

class ThingsToWinApp extends ConsumerWidget {
  const ThingsToWinApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: '100 Things to Win',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
