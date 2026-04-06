import 'package:things_to_win/core/utils/date_utils.dart';
import 'package:things_to_win/features/habits/domain/entities/habit_entry.dart';

class HabitEntryModel {
  const HabitEntryModel({
    required this.habitId,
    required this.dayKey,
    required this.isCompleted,
    required this.completedAtIso,
  });

  final String habitId;
  final String dayKey;
  final bool isCompleted;
  final String? completedAtIso;

  HabitEntry toEntity() {
    return HabitEntry(
      habitId: habitId,
      day: DateTime.parse(dayKey),
      isCompleted: isCompleted,
      completedAt: completedAtIso == null ? null : DateTime.parse(completedAtIso!),
    );
  }

  factory HabitEntryModel.fromEntity(HabitEntry entry) {
    return HabitEntryModel(
      habitId: entry.habitId,
      dayKey: toDayKey(entry.day),
      isCompleted: entry.isCompleted,
      completedAtIso: entry.completedAt?.toIso8601String(),
    );
  }

  factory HabitEntryModel.fromMap(Map<String, Object?> map) {
    return HabitEntryModel(
      habitId: map['habit_id']! as String,
      dayKey: map['day_key']! as String,
      isCompleted: (map['is_completed']! as int) == 1,
      completedAtIso: map['completed_at'] as String?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'habit_id': habitId,
      'day_key': dayKey,
      'is_completed': isCompleted ? 1 : 0,
      'completed_at': completedAtIso,
    };
  }
}
