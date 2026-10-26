import 'package:flutter_test/flutter_test.dart';
import 'package:eling_app/features/reminders/domain/entities/reminder.dart';
import 'package:eling_app/features/reminders/data/models/reminder_model.dart';

void main() {
  group('Reminder Model & Entity Serialization Tests (IMPAL Verification)', () {
    final fixedTime = DateTime.parse('2026-10-25 14:00:00');

    test('Harus berhasil mengonversi ReminderModel ke Map SQLite (toMap)', () {
      final model = ReminderModel(
        id: 1,
        title: 'Tugas Besar IMPAL',
        description: 'Testing unit dan integrasi SQLite',
        remindAt: fixedTime,
        categoryId: 2,
        isCompleted: false,
        isActive: true,
        notificationId: 1024,
        source: ReminderSource.manual,
        createdAt: fixedTime,
        updatedAt: fixedTime,
      );

      final map = model.toMap();

      expect(map['id'], 1);
      expect(map['title'], 'Tugas Besar IMPAL');
      expect(map['description'], 'Testing unit dan integrasi SQLite');
      expect(map['is_completed'], 0);
      expect(map['is_active'], 1);
      expect(map['notification_id'], 1024);
      expect(map['source'], 'MANUAL');
    });

    test('Harus berhasil membuat ReminderModel dari Map SQLite (fromMap)', () {
      final map = {
        'id': 2,
        'title': 'Rapat Kelompok ELING',
        'description': null,
        'remind_at': fixedTime.toUtc().millisecondsSinceEpoch,
        'category_id': 1,
        'is_completed': 1,
        'is_active': 0,
        'notification_id': 2048,
        'source': 'VOICE_AI',
        'created_at': fixedTime.toUtc().millisecondsSinceEpoch,
        'updated_at': fixedTime.toUtc().millisecondsSinceEpoch,
        'category_name': 'Kuliah',
        'category_color_hex': '#3B82F6',
      };

      final model = ReminderModel.fromMap(map);

      expect(model.id, 2);
      expect(model.title, 'Rapat Kelompok ELING');
      expect(model.isCompleted, true);
      expect(model.isActive, false);
      expect(model.notificationId, 2048);
      expect(model.source, ReminderSource.voiceAi);
      expect(model.categoryName, 'Kuliah');
    });
  });
}
