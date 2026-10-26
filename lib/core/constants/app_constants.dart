class AppConstants {
  static const String appName = 'ELING';
  static const String appTagline = 'Smart Daily Reminder';

  // SQLite Constants
  static const String databaseName = 'eling_database.db';
  static const int databaseVersion = 2;

  // Notification Constants
  static const String notificationChannelId = 'eling_reminders_channel';
  static const String notificationChannelName = 'Pengingat Harian ELING';
  static const String notificationChannelDescription =
      'Saluran notifikasi untuk alarm pengingat tugas dan aktivitas harian.';
  // AI Proxy Configuration (No API keys exposed in app)
  // Gunakan 'http://10.0.2.2:3000' untuk Android Emulator, atau IP laptop (misal: 'http://192.168.1.X:3000') untuk HP fisik
  static const String aiProxyBaseUrl = 'http://10.0.2.2:3000';

  // Default Categories
  static const List<Map<String, dynamic>> defaultCategories = [
    {
      'name': 'Kuliah',
      'color_hex': '#3B82F6', // Blue
      'icon_name': 'school',
    },
    {
      'name': 'Tugas',
      'color_hex': '#EF4444', // Red
      'icon_name': 'assignment',
    },
    {
      'name': 'Pribadi',
      'color_hex': '#10B981', // Green
      'icon_name': 'person',
    },
    {
      'name': 'Belanja',
      'color_hex': '#F59E0B', // Amber
      'icon_name': 'shopping_cart',
    },
    {
      'name': 'Lainnya',
      'color_hex': '#8B5CF6', // Purple
      'icon_name': 'more_horiz',
    },
  ];
}
