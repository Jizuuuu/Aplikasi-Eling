import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _dayDateMonthYear =
      DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
  static final DateFormat _shortDate = DateFormat('dd MMM yyyy', 'id_ID');
  static final DateFormat _time24 = DateFormat('HH:mm');

  static String formatFullDate(DateTime dateTime) {
    try {
      return _dayDateMonthYear.format(dateTime);
    } catch (_) {
      return DateFormat('EEEE, dd MMMM yyyy').format(dateTime);
    }
  }

  static String formatShortDate(DateTime dateTime) {
    try {
      return _shortDate.format(dateTime);
    } catch (_) {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }

  static String formatTime(DateTime dateTime) {
    return _time24.format(dateTime);
  }

  static bool isToday(DateTime dateTime) {
    final now = DateTime.now();
    return dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day;
  }

  static bool isTomorrow(DateTime dateTime) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dateTime.year == tomorrow.year &&
        dateTime.month == tomorrow.month &&
        dateTime.day == tomorrow.day;
  }

  static String getRelativeDayString(DateTime dateTime) {
    if (isToday(dateTime)) {
      return 'Hari Ini, ${formatTime(dateTime)}';
    } else if (isTomorrow(dateTime)) {
      return 'Besok, ${formatTime(dateTime)}';
    } else {
      return '${formatShortDate(dateTime)} • ${formatTime(dateTime)}';
    }
  }
}
