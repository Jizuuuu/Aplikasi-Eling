import '../../domain/entities/reminder.dart';

class ReminderModel extends Reminder {
  const ReminderModel({
    super.id,
    required super.title,
    super.description,
    required super.remindAt,
    super.categoryId,
    super.isCompleted = false,
    super.isActive = true,
    required super.notificationId,
    super.source = ReminderSource.manual,
    required super.createdAt,
    required super.updatedAt,
    super.categoryName,
    super.categoryColorHex,
  });

  factory ReminderModel.fromEntity(Reminder entity) {
    return ReminderModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      remindAt: entity.remindAt,
      categoryId: entity.categoryId,
      isCompleted: entity.isCompleted,
      isActive: entity.isActive,
      notificationId: entity.notificationId,
      source: entity.source,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      categoryName: entity.categoryName,
      categoryColorHex: entity.categoryColorHex,
    );
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    DateTime parseTime(dynamic val) {
      if (val is int) {
        return DateTime.fromMillisecondsSinceEpoch(val, isUtc: true).toLocal();
      } else if (val is String) {
        return DateTime.tryParse(val) ?? DateTime.now();
      }
      return DateTime.now();
    }

    return ReminderModel(
      id: map['id'] as int?,
      title: (map['title'] ?? map['NamaAktivitas'] ?? 'Aktivitas') as String,
      description: (map['description'] ?? map['Deskripsi']) as String?,
      remindAt: parseTime(map['remind_at'] ?? map['WaktuPengingat']),
      categoryId: map['category_id'] is int ? map['category_id'] as int : 1,
      isCompleted: (map['is_completed'] == 1 || map['StatusAktivitas'] == 'Selesai'),
      isActive: (map['is_active'] == 1 || map['StatusPengingat'] == 'Aktif'),
      notificationId: map['notification_id'] is int ? map['notification_id'] as int : 1001,
      source: (map['source'] as String?) == 'VOICE_AI'
          ? ReminderSource.voiceAi
          : ReminderSource.manual,
      createdAt: parseTime(map['created_at']),
      updatedAt: parseTime(map['updated_at'] ?? map['WaktuPengingat']),
      categoryName: (map['category_name'] ?? map['NamaKategori']) as String?,
      categoryColorHex: (map['category_color_hex'] ?? map['color_hex']) as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'description': description,
      'remind_at': remindAt.toUtc().millisecondsSinceEpoch,
      'category_id': categoryId,
      'is_completed': isCompleted ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'notification_id': notificationId,
      'source': source == ReminderSource.voiceAi ? 'VOICE_AI' : 'MANUAL',
      'created_at': createdAt.toUtc().millisecondsSinceEpoch,
      'updated_at': updatedAt.toUtc().millisecondsSinceEpoch,
    };
  }
}
