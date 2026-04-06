import 'package:things_to_win/features/habits/domain/entities/habit.dart';

class HabitModel {
  const HabitModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.iconKey,
    required this.colorHex,
    required this.createdAtIso,
    required this.isArchived,
    required this.order,
  });

  final String id;
  final String title;
  final String? description;
  final String category;
  final String iconKey;
  final int colorHex;
  final String createdAtIso;
  final bool isArchived;
  final int order;

  Habit toEntity() {
    return Habit(
      id: id,
      title: title,
      description: description,
      category: category,
      iconKey: iconKey,
      colorHex: colorHex,
      createdAt: DateTime.parse(createdAtIso),
      isArchived: isArchived,
      order: order,
    );
  }

  factory HabitModel.fromEntity(Habit habit) {
    return HabitModel(
      id: habit.id,
      title: habit.title,
      description: habit.description,
      category: habit.category,
      iconKey: habit.iconKey,
      colorHex: habit.colorHex,
      createdAtIso: habit.createdAt.toIso8601String(),
      isArchived: habit.isArchived,
      order: habit.order,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'icon_key': iconKey,
      'color_hex': colorHex,
      'created_at': createdAtIso,
      'is_archived': isArchived ? 1 : 0,
      'sort_order': order,
    };
  }

  factory HabitModel.fromMap(Map<String, Object?> map) {
    return HabitModel(
      id: map['id']! as String,
      title: map['title']! as String,
      description: map['description'] as String?,
      category: (map['category'] as String?) ?? 'General',
      iconKey: (map['icon_key'] as String?) ?? 'target',
      colorHex: map['color_hex']! as int,
      createdAtIso: map['created_at']! as String,
      isArchived: (map['is_archived']! as int) == 1,
      order: map['sort_order']! as int,
    );
  }
}
