import '../entities/reminder.dart';
import '../entities/category.dart';

abstract class ReminderRepository {
  Future<List<Reminder>> getAllReminders({String? userCode});
  Future<List<Reminder>> getTodayReminders({String? userCode});
  Future<List<Reminder>> getUpcomingReminders({String? userCode});
  Future<List<Reminder>> getCompletedReminders({String? userCode});
  Future<Reminder?> getReminderById(int id);
  Future<int> insertReminder(Reminder reminder, {String? userCode});
  Future<int> updateReminder(Reminder reminder);
  Future<int> deleteReminder(int id);
  Future<int> toggleComplete(int id, bool isCompleted);
  Future<int> toggleActive(int id, bool isActive);
  Future<List<Category>> getAllCategories();
}
