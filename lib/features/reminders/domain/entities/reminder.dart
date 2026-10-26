enum ReminderSource { manual, voiceAi }

class Reminder {
  final int? id;
  final String title;
  final String? description;
  final DateTime remindAt;
  final int? categoryId;
  final bool isCompleted;
  final bool isActive;
  final int notificationId;
  final ReminderSource source;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Optional join field for UI convenience
  final String? categoryName;
  final String? categoryColorHex;

  const Reminder({
    this.id,
    required this.title,
    this.description,
    required this.remindAt,
    this.categoryId,
    this.isCompleted = false,
    this.isActive = true,
    required this.notificationId,
    this.source = ReminderSource.manual,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
    this.categoryColorHex,
  });

  Reminder copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? remindAt,
    int? categoryId,
    bool? isCompleted,
    bool? isActive,
    int? notificationId,
    ReminderSource? source,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoryName,
    String? categoryColorHex,
  }) {
    return Reminder(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      remindAt: remindAt ?? this.remindAt,
      categoryId: categoryId ?? this.categoryId,
      isCompleted: isCompleted ?? this.isCompleted,
      isActive: isActive ?? this.isActive,
      notificationId: notificationId ?? this.notificationId,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryName: categoryName ?? this.categoryName,
      categoryColorHex: categoryColorHex ?? this.categoryColorHex,
    );
  }
}
