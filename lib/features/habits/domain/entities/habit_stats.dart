import 'package:equatable/equatable.dart';

class HabitStats extends Equatable {
  const HabitStats({
    required this.currentStreak,
    required this.bestStreak,
    required this.completionRate,
    required this.completedDays,
    required this.totalDays,
  });

  final int currentStreak;
  final int bestStreak;
  final double completionRate;
  final int completedDays;
  final int totalDays;

  @override
  List<Object?> get props =>
      [currentStreak, bestStreak, completionRate, completedDays, totalDays];
}
