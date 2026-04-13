import 'package:equatable/equatable.dart';

class Habit extends Equatable {
  const Habit({
    required this.id,
    required this.title,
    required this.colorHex,
    required this.createdAt,
    this.description,
    this.category = 'General',
    this.iconKey = 'target',
    this.isArchived = false,
    this.order = 0,
  });

  final String id;
  final String title;
  final String? description;
  final String category;
  final String iconKey;
  final int colorHex;
  final DateTime createdAt;
  final bool isArchived;
  final int order;

  Habit copyWith({
    String? title,
    String? description,
    String? category,
    String? iconKey,
    int? colorHex,
    bool? isArchived,
    int? order,
  }) {
    return Habit(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      iconKey: iconKey ?? this.iconKey,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt,
      isArchived: isArchived ?? this.isArchived,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        category,
        iconKey,
        colorHex,
        createdAt,
        isArchived,
        order
      ];
}
