import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:things_to_win/core/theme/app_theme.dart';

void main() {
  test('light and dark themes are material3 enabled', () {
    expect(AppTheme.light.useMaterial3, isTrue);
    expect(AppTheme.dark.useMaterial3, isTrue);
  });

  test('dark theme has dark brightness', () {
    expect(AppTheme.dark.colorScheme.brightness, Brightness.dark);
  });
}
