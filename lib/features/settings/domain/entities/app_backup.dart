import 'package:equatable/equatable.dart';

enum BackupImportMode { merge, replace }

class BackupExportResult extends Equatable {
  const BackupExportResult({
    required this.filePath,
    required this.exportedAt,
    required this.habitsCount,
    required this.habitEntriesCount,
  });

  final String filePath;
  final DateTime exportedAt;
  final int habitsCount;
  final int habitEntriesCount;

  @override
  List<Object?> get props => [
        filePath,
        exportedAt,
        habitsCount,
        habitEntriesCount,
      ];
}

class BackupImportResult extends Equatable {
  const BackupImportResult({
    required this.mode,
    required this.habitsCount,
    required this.habitEntriesCount,
  });

  final BackupImportMode mode;
  final int habitsCount;
  final int habitEntriesCount;

  @override
  List<Object?> get props => [mode, habitsCount, habitEntriesCount];
}

class BackupValidationException implements Exception {
  const BackupValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}
