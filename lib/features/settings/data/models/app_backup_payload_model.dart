import 'dart:convert';

import 'package:things_to_win/features/habits/data/models/habit_entry_model.dart';
import 'package:things_to_win/features/habits/data/models/habit_model.dart';
import 'package:things_to_win/features/settings/domain/entities/app_backup.dart';

const backupSchemaVersion = 1;

class AppBackupPayloadModel {
  const AppBackupPayloadModel({
    required this.version,
    required this.exportedAt,
    required this.habits,
    required this.habitEntries,
  });

  final int version;
  final DateTime exportedAt;
  final List<HabitModel> habits;
  final List<HabitEntryModel> habitEntries;

  Map<String, Object?> toJson() {
    return {
      'version': version,
      'schema': 'things_to_win_backup',
      'exportedAt': exportedAt.toIso8601String(),
      'metadata': {
        'source': '100-things-to-win',
        'backupSchemaVersion': backupSchemaVersion,
      },
      'habits': habits.map((habit) => _habitToBackupJson(habit)).toList(),
      'habitEntries':
          habitEntries.map((entry) => _habitEntryToBackupJson(entry)).toList(),
    };
  }

  String toJsonString() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  static AppBackupPayloadModel fromJsonString(String rawJson) {
    dynamic parsed;
    try {
      parsed = jsonDecode(rawJson);
    } catch (_) {
      throw const BackupValidationException('Backup file is not valid JSON.');
    }
    if (parsed is! Map<String, dynamic>) {
      throw const BackupValidationException(
        'Backup file root must be a JSON object.',
      );
    }
    return fromJsonMap(parsed);
  }

  static AppBackupPayloadModel fromJsonMap(Map<String, dynamic> json) {
    final versionRaw = json['version'];
    if (versionRaw is! int) {
      throw const BackupValidationException(
        'Backup file is missing a valid "version".',
      );
    }
    if (versionRaw != backupSchemaVersion) {
      throw BackupValidationException(
        'Unsupported backup version: $versionRaw.',
      );
    }

    final exportedAtRaw = json['exportedAt'];
    if (exportedAtRaw is! String) {
      throw const BackupValidationException(
        'Backup file is missing "exportedAt".',
      );
    }
    DateTime exportedAt;
    try {
      exportedAt = DateTime.parse(exportedAtRaw);
    } catch (_) {
      throw const BackupValidationException(
        'Backup "exportedAt" must be an ISO date string.',
      );
    }

    final habitsRaw = json['habits'];
    if (habitsRaw is! List) {
      throw const BackupValidationException(
        'Backup file is missing "habits" array.',
      );
    }
    final entriesRaw = json['habitEntries'];
    if (entriesRaw is! List) {
      throw const BackupValidationException(
        'Backup file is missing "habitEntries" array.',
      );
    }

    final habits = habitsRaw
        .map((item) => _habitFromBackupJson(item))
        .toList(growable: false);
    final entries = entriesRaw
        .map((item) => _habitEntryFromBackupJson(item))
        .toList(growable: false);

    _validateNoDuplicates(habits, entries);

    return AppBackupPayloadModel(
      version: versionRaw,
      exportedAt: exportedAt,
      habits: habits,
      habitEntries: entries,
    );
  }
}

Map<String, Object?> _habitToBackupJson(HabitModel habit) {
  return {
    'id': habit.id,
    'title': habit.title,
    'description': habit.description,
    'category': habit.category,
    'iconKey': habit.iconKey,
    'colorHex': habit.colorHex,
    'createdAt': habit.createdAtIso,
    'isArchived': habit.isArchived,
    'sortOrder': habit.order,
  };
}

HabitModel _habitFromBackupJson(Object? input) {
  if (input is! Map<String, dynamic>) {
    throw const BackupValidationException('Each habit must be a JSON object.');
  }
  final id = _readRequiredString(input, 'id', context: 'habit');
  final title = _readRequiredString(input, 'title', context: 'habit');
  final description =
      _readOptionalString(input, 'description', context: 'habit');
  final category = _readRequiredString(input, 'category', context: 'habit');
  final iconKey = _readRequiredString(input, 'iconKey', context: 'habit');
  final colorHex = _readRequiredInt(input, 'colorHex', context: 'habit');
  final createdAt = _readRequiredString(input, 'createdAt', context: 'habit');
  final isArchived = _readRequiredBool(input, 'isArchived', context: 'habit');
  final sortOrder = _readRequiredInt(input, 'sortOrder', context: 'habit');

  try {
    DateTime.parse(createdAt);
  } catch (_) {
    throw const BackupValidationException(
      'Habit "createdAt" must be a valid ISO date string.',
    );
  }

  return HabitModel(
    id: id,
    title: title,
    description: description,
    category: category,
    iconKey: iconKey,
    colorHex: colorHex,
    createdAtIso: createdAt,
    isArchived: isArchived,
    order: sortOrder,
  );
}

Map<String, Object?> _habitEntryToBackupJson(HabitEntryModel entry) {
  return {
    'habitId': entry.habitId,
    'dayKey': entry.dayKey,
    'isCompleted': entry.isCompleted,
    'completedAt': entry.completedAtIso,
  };
}

HabitEntryModel _habitEntryFromBackupJson(Object? input) {
  if (input is! Map<String, dynamic>) {
    throw const BackupValidationException(
      'Each habit entry must be a JSON object.',
    );
  }

  final habitId = _readRequiredString(input, 'habitId', context: 'habit entry');
  final dayKey = _readRequiredString(input, 'dayKey', context: 'habit entry');
  final isCompleted =
      _readRequiredBool(input, 'isCompleted', context: 'habit entry');
  final completedAt =
      _readOptionalString(input, 'completedAt', context: 'habit entry');

  try {
    DateTime.parse(dayKey);
  } catch (_) {
    throw const BackupValidationException(
      'Habit entry "dayKey" must be a valid YYYY-MM-DD date string.',
    );
  }

  if (completedAt != null) {
    try {
      DateTime.parse(completedAt);
    } catch (_) {
      throw const BackupValidationException(
        'Habit entry "completedAt" must be an ISO date string when present.',
      );
    }
  }

  return HabitEntryModel(
    habitId: habitId,
    dayKey: dayKey,
    isCompleted: isCompleted,
    completedAtIso: completedAt,
  );
}

void _validateNoDuplicates(
  List<HabitModel> habits,
  List<HabitEntryModel> entries,
) {
  final habitIds = <String>{};
  for (final habit in habits) {
    if (!habitIds.add(habit.id)) {
      throw BackupValidationException(
        'Backup contains duplicate habit id "${habit.id}".',
      );
    }
  }

  final entryKeys = <String>{};
  for (final entry in entries) {
    final key = '${entry.habitId}:${entry.dayKey}';
    if (!entryKeys.add(key)) {
      throw BackupValidationException(
        'Backup contains duplicate habit entry key "$key".',
      );
    }
  }
}

String _readRequiredString(
  Map<String, dynamic> input,
  String key, {
  required String context,
}) {
  final value = input[key];
  if (value is String) {
    return value;
  }
  throw BackupValidationException(
    'Invalid or missing "$key" in $context.',
  );
}

String? _readOptionalString(
  Map<String, dynamic> input,
  String key, {
  required String context,
}) {
  final value = input[key];
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }
  throw BackupValidationException(
    'Invalid "$key" in $context.',
  );
}

int _readRequiredInt(
  Map<String, dynamic> input,
  String key, {
  required String context,
}) {
  final value = input[key];
  if (value is int) {
    return value;
  }
  throw BackupValidationException(
    'Invalid or missing "$key" in $context.',
  );
}

bool _readRequiredBool(
  Map<String, dynamic> input,
  String key, {
  required String context,
}) {
  final value = input[key];
  if (value is bool) {
    return value;
  }
  throw BackupValidationException(
    'Invalid or missing "$key" in $context.',
  );
}
