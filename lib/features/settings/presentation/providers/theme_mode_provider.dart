import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:things_to_win/features/settings/data/datasources/settings_local_data_source.dart';
import 'package:things_to_win/features/settings/data/settings_repository_impl.dart';
import 'package:things_to_win/features/settings/domain/entities/app_settings.dart';
import 'package:things_to_win/features/settings/domain/repositories/settings_repository.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

final settingsRepositoryProvider = FutureProvider<SettingsRepository>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final dataSource = SharedPrefsSettingsDataSource(prefs);
  return SettingsRepositoryImpl(dataSource);
});

class AppSettingsNotifier extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() async {
    final repo = await ref.watch(settingsRepositoryProvider.future);
    return repo.getSettings();
  }

  Future<void> saveSettings(AppSettings settings) async {
    state = const AsyncValue.loading();
    final repo = await ref.read(settingsRepositoryProvider.future);
    await repo.saveSettings(settings);
    state = AsyncValue.data(settings);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final current = state.valueOrNull ?? await _loadCurrent();
    await saveSettings(current.copyWith(themeMode: mode));
  }

  Future<void> completeOnboarding() async {
    final current = state.valueOrNull ?? await _loadCurrent();
    if (current.hasCompletedOnboarding) {
      return;
    }
    await saveSettings(current.copyWith(hasCompletedOnboarding: true));
  }

  Future<AppSettings> _loadCurrent() async {
    final repo = await ref.read(settingsRepositoryProvider.future);
    return repo.getSettings();
  }
}

final appSettingsAsyncProvider = AsyncNotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);

final appSettingsProvider = Provider<AppSettings>((ref) {
  final settings = ref.watch(appSettingsAsyncProvider).valueOrNull;
  return settings ?? const AppSettings(themeMode: ThemeMode.system);
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(appSettingsProvider).themeMode;
});

final hasCompletedOnboardingProvider = Provider<bool>((ref) {
  return ref.watch(appSettingsProvider).hasCompletedOnboarding;
});
