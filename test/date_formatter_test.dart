import 'package:flutter_test/flutter_test.dart';
import 'package:eling_app/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter Indonesian Localization Tests (IMPAL Unit Testing)', () {
    test('isToday harus bernilai true untuk tanggal hari ini', () {
      final now = DateTime.now();
      expect(DateFormatter.isToday(now), isTrue);
    });

    test('isToday harus bernilai false untuk hari esok atau kemarin', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(DateFormatter.isToday(yesterday), isFalse);
      expect(DateFormatter.isToday(tomorrow), isFalse);
    });

    test('isTomorrow harus bernilai true untuk H+1', () {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      expect(DateFormatter.isTomorrow(tomorrow), isTrue);
    });

    test('formatTime harus menghasilkan format 24 jam HH:mm yang benar', () {
      final dt = DateTime(2026, 10, 24, 14, 30);
      final formattedTime = DateFormatter.formatTime(dt);
      expect(formattedTime, '14:30');
    });

    test('getRelativeDayString harus menghasilkan string "Hari Ini" untuk hari ini', () {
      final todayTime = DateTime.now();
      final result = DateFormatter.getRelativeDayString(todayTime);
      expect(result.startsWith('Hari Ini,'), isTrue);
    });

    test('getRelativeDayString harus menghasilkan string "Besok" untuk besok', () {
      final tomorrowTime = DateTime.now().add(const Duration(days: 1));
      final result = DateFormatter.getRelativeDayString(tomorrowTime);
      expect(result.startsWith('Besok,'), isTrue);
    });
  });
}
