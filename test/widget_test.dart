import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:eling_app/app.dart';
import 'package:eling_app/features/auth/domain/entities/user_account.dart';
import 'package:eling_app/features/auth/presentation/controllers/auth_controller.dart';
import 'package:eling_app/features/reminders/domain/entities/reminder.dart';
import 'package:eling_app/features/reminders/domain/entities/category.dart';
import 'package:eling_app/features/reminders/domain/repositories/reminder_repository.dart';
import 'package:eling_app/features/reminders/presentation/controllers/reminder_providers.dart';

class FakeReminderRepository implements ReminderRepository {
  @override
  Future<List<Reminder>> getAllReminders({String? userCode}) async => [];

  @override
  Future<List<Reminder>> getTodayReminders({String? userCode}) async => [];

  @override
  Future<List<Reminder>> getUpcomingReminders({String? userCode}) async => [];

  @override
  Future<List<Reminder>> getCompletedReminders({String? userCode}) async => [];

  @override
  Future<Reminder?> getReminderById(int id) async => null;

  @override
  Future<int> insertReminder(Reminder reminder, {String? userCode}) async => 1;

  @override
  Future<int> updateReminder(Reminder reminder) async => 1;

  @override
  Future<int> deleteReminder(int id) async => 1;

  @override
  Future<int> toggleComplete(int id, bool isCompleted) async => 1;

  @override
  Future<int> toggleActive(int id, bool isActive) async => 1;

  @override
  Future<List<Category>> getAllCategories() async => [
        const Category(id: 1, name: 'Pendidikan', colorHex: '#3B82F6', iconName: 'school'),
        const Category(id: 2, name: 'Pekerjaan', colorHex: '#EF4444', iconName: 'assignment'),
      ];
}

void main() {
  testWidgets('HomeScreen harus menampilkan judul ELING, tabs, dan action buttons setelah login',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentUserProvider.overrideWith((ref) => const UserAccount(
                kodePengguna: 'U0001',
                namaPengguna: 'Aziz Faadihilah',
                email: 'aziz@example.com',
              )),
          reminderRepositoryProvider.overrideWithValue(FakeReminderRepository()),
        ],
        child: const ElingApp(),
      ),
    );

    await tester.pumpAndSettle();

    // Verifikasi judul aplikasi muncul di AppBar
    expect(find.text('ELING'), findsOneWidget);

    // Verifikasi nama pengguna muncul di AppBar
    expect(find.text('Aziz'), findsOneWidget);

    // Verifikasi 3 tab filter utama tersedia
    expect(find.text('Hari Ini'), findsOneWidget);
    expect(find.text('Mendatang'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);

    // Verifikasi tombol tambah manual, mikrofon, dan logout ada
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    expect(find.byIcon(Icons.mic_rounded), findsOneWidget);
    expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
  });
}
