import 'package:equatable/equatable.dart';
import 'package:things_to_win/core/utils/date_utils.dart';

class HabitEntry extends Equatable {
  HabitEntry({
    required this.habitId,
    required DateTime day,
    required this.isCompleted,
    this.completedAt,
  }) : day = toDateOnly(day);

  final String habitId;
  final DateTime day;
  final bool isCompleted;
  final DateTime? completedAt;

  HabitEntry copyWith({
    bool? isCompleted,
    DateTime? completedAt,
  }) {
    return HabitEntry(
      habitId: habitId,
      day: day,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [habitId, day, isCompleted, completedAt];
}
