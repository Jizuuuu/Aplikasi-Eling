import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../data/datasources/reminder_local_datasource.dart';
import '../../data/repositories/reminder_repository_impl.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

// 1. Core Providers
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

final reminderLocalDataSourceProvider = Provider<ReminderLocalDataSource>((ref) {
  final dbHelper = ref.watch(databaseHelperProvider);
  return ReminderLocalDataSourceImpl(dbHelper: dbHelper);
});

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  final dataSource = ref.watch(reminderLocalDataSourceProvider);
  return ReminderRepositoryImpl(localDataSource: dataSource);
});

// 2. Categories Provider
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repo = ref.watch(reminderRepositoryProvider);
  return repo.getAllCategories();
});

// 3. Tab State (0: Hari Ini, 1: Mendatang, 2: Selesai)
final selectedTabProvider = StateProvider<int>((ref) => 0);

// 4. Reminder List State Notifier
class ReminderListNotifier extends StateNotifier<AsyncValue<List<Reminder>>> {
  final ReminderRepository repository;
  final NotificationService notificationService;
  final Ref ref;

  ReminderListNotifier({
    required this.repository,
    required this.notificationService,
    required this.ref,
  }) : super(const AsyncValue.loading()) {
    loadReminders();
  }

  Future<void> loadReminders() async {
    state = const AsyncValue.loading();
    try {
      final tabIndex = ref.read(selectedTabProvider);
      final user = ref.read(currentUserProvider);
      final userCode = user?.kodePengguna;

      List<Reminder> reminders;
      if (tabIndex == 0) {
        reminders = await repository.getTodayReminders(userCode: userCode);
      } else if (tabIndex == 1) {
        reminders = await repository.getUpcomingReminders(userCode: userCode);
      } else {
        reminders = await repository.getCompletedReminders(userCode: userCode);
      }
      state = AsyncValue.data(reminders);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addReminder({
    required String title,
    String? description,
    required DateTime remindAt,
    int? categoryId,
    ReminderSource source = ReminderSource.manual,
  }) async {
    final now = DateTime.now();
    // Generate a positive 31-bit integer for Android notification ID
    final notificationId = Random().nextInt(100000000);

    final newReminder = Reminder(
      title: title,
      description: description,
      remindAt: remindAt,
      categoryId: categoryId,
      notificationId: notificationId,
      source: source,
      createdAt: now,
      updatedAt: now,
    );

    final user = ref.read(currentUserProvider);
    await repository.insertReminder(newReminder, userCode: user?.kodePengguna);

    // Schedule local notification immediately without needing any internet/AI
    await notificationService.scheduleReminder(
      notificationId: notificationId,
      title: title,
      body: description,
      scheduledDate: remindAt,
    );

    await loadReminders();
  }

  Future<void> toggleComplete(Reminder reminder) async {
    if (reminder.id == null) return;
    final newStatus = !reminder.isCompleted;

    await repository.toggleComplete(reminder.id!, newStatus);

    if (newStatus) {
      // Completed: cancel notification
      await notificationService.cancelNotification(reminder.notificationId);
    } else if (reminder.isActive && reminder.remindAt.isAfter(DateTime.now())) {
      // Uncompleted & still in the future: reschedule
      await notificationService.scheduleReminder(
        notificationId: reminder.notificationId,
        title: reminder.title,
        body: reminder.description,
        scheduledDate: reminder.remindAt,
      );
    }

    await loadReminders();
  }

  Future<void> toggleActive(Reminder reminder) async {
    if (reminder.id == null) return;
    final newActiveState = !reminder.isActive;

    await repository.toggleActive(reminder.id!, newActiveState);

    if (newActiveState && reminder.remindAt.isAfter(DateTime.now())) {
      // Turned on: schedule
      await notificationService.scheduleReminder(
        notificationId: reminder.notificationId,
        title: reminder.title,
        body: reminder.description,
        scheduledDate: reminder.remindAt,
      );
    } else {
      // Turned off: cancel
      await notificationService.cancelNotification(reminder.notificationId);
    }

    await loadReminders();
  }

  Future<void> deleteReminder(Reminder reminder) async {
    if (reminder.id == null) return;
    await repository.deleteReminder(reminder.id!);
    await notificationService.cancelNotification(reminder.notificationId);
    await loadReminders();
  }
}

final reminderListNotifierProvider =
    StateNotifierProvider<ReminderListNotifier, AsyncValue<List<Reminder>>>((ref) {
  final repository = ref.watch(reminderRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  return ReminderListNotifier(
    repository: repository,
    notificationService: notificationService,
    ref: ref,
  );
});
