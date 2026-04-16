import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:things_to_win/app/app.dart';
import 'package:things_to_win/core/database/database_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapDatabase();
  runApp(const ProviderScope(child: ThingsToWinApp()));
}
