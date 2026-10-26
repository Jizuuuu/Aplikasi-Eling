import '../../domain/entities/reminder.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../datasources/reminder_local_datasource.dart';
import '../models/reminder_model.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  final ReminderLocalDataSource localDataSource;

  ReminderRepositoryImpl({required this.localDataSource});

  @override
  Future<List<Reminder>> getAllReminders({String? userCode}) =>
      localDataSource.getAllReminders(userCode: userCode);

  @override
  Future<List<Reminder>> getTodayReminders({String? userCode}) =>
      localDataSource.getTodayReminders(userCode: userCode);

  @override
  Future<List<Reminder>> getUpcomingReminders({String? userCode}) =>
      localDataSource.getUpcomingReminders(userCode: userCode);

  @override
  Future<List<Reminder>> getCompletedReminders({String? userCode}) =>
      localDataSource.getCompletedReminders(userCode: userCode);

  @override
  Future<Reminder?> getReminderById(int id) => localDataSource.getReminderById(id);

  @override
  Future<int> insertReminder(Reminder reminder, {String? userCode}) {
    return localDataSource.insertReminder(
      ReminderModel.fromEntity(reminder),
      userCode: userCode,
    );
  }

  @override
  Future<int> updateReminder(Reminder reminder) {
    return localDataSource.updateReminder(ReminderModel.fromEntity(reminder));
  }

  @override
  Future<int> deleteReminder(int id) => localDataSource.deleteReminder(id);

  @override
  Future<int> toggleComplete(int id, bool isCompleted) =>
      localDataSource.toggleComplete(id, isCompleted);

  @override
  Future<int> toggleActive(int id, bool isActive) =>
      localDataSource.toggleActive(id, isActive);

  @override
  Future<List<Category>> getAllCategories() => localDataSource.getAllCategories();
}
