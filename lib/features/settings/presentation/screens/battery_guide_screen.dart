import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import '../../../reminders/presentation/controllers/reminder_providers.dart';

class BatteryGuideScreen extends ConsumerWidget {
  const BatteryGuideScreen({super.key});

  Future<void> _openBatterySettings(BuildContext context) async {
    try {
      const intent = AndroidIntent(
        action: 'android.settings.IGNORE_BATTERY_OPTIMIZATION_SETTINGS',
        flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    } catch (_) {
      try {
        const fallbackIntent = AndroidIntent(
          action: 'android.settings.APPLICATION_DETAILS_SETTINGS',
          data: 'package:com.eling.app',
          flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await fallbackIntent.launch();
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tidak dapat membuka pengaturan: $e')),
          );
        }
      }
    }
  }

  Future<void> _openNotificationSettings(BuildContext context) async {
    try {
      const intent = AndroidIntent(
        action: 'android.settings.APP_NOTIFICATION_SETTINGS',
        arguments: {
          'android.provider.extra.APP_PACKAGE': 'com.eling.app',
        },
        flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      await intent.launch();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buka Pengaturan HP > Aplikasi > ELING > Notifikasi')),
        );
      }
    }
  }

  Future<void> _testQuickNotification(BuildContext context, WidgetRef ref) async {
    final notificationService = ref.read(notificationServiceProvider);
    final testTime = DateTime.now().add(const Duration(seconds: 10));

    await notificationService.scheduleReminder(
      notificationId: 999999,
      title: 'Tes Pengingat ELING Berhasil!',
      body: 'Alarm dan notifikasi lokal presisimu berfungsi normal.',
      scheduledDate: testTime,
    );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notifikasi tes dijadwalkan! Tunggu 10 detik (bisa kunci layar HP).'),
          backgroundColor: Colors.indigo,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keandalan Notifikasi & Baterai'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Banner Warning
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.amber.shade800, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Penting untuk Pengguna Android',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade900,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Beberapa merek HP (Xiaomi, Samsung, Oppo, Vivo) memiliki fitur penghemat baterai agresif yang dapat menunda atau mematikan alarm pengingat saat layar mati.',
                        style: TextStyle(
                          color: Colors.amber.shade900,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Steps list
          const Text(
            'Langkah Rekomendasi Agar Alarm Tepat Waktu:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 14),

          _buildStepCard(
            stepNumber: '1',
            title: 'Bypass Penghemat Baterai',
            description:
                'Ubah opsi baterai untuk aplikasi ELING menjadi "Tidak Dibatasi" (Unrestricted / No Restrictions).',
            buttonLabel: 'Buka Pengaturan Baterai',
            onTap: () => _openBatterySettings(context),
          ),
          const SizedBox(height: 12),

          _buildStepCard(
            stepNumber: '2',
            title: 'Pastikan Izin Notifikasi Aktif',
            description:
                'Aktifkan notifikasi pop-up di layar (Banners) dan izin suara pengingat di sistem Android.',
            buttonLabel: 'Buka Pengaturan Notifikasi',
            onTap: () => _openNotificationSettings(context),
          ),
          const SizedBox(height: 12),

          _buildStepCard(
            stepNumber: '3',
            title: 'Aktifkan Autostart (Khusus Xiaomi / Oppo / Vivo)',
            description:
                'Buka Pengaturan HP > Aplikasi > Kelola Aplikasi > ELING > aktifkan "Mulai Otomatis" (Autostart).',
          ),
          const SizedBox(height: 32),

          // Quick Notification Test Button
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Uji Coba Alarm Langsung (IMPAL Demo)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tekan tombol di bawah untuk menjadwalkan notifikasi berbunyi dalam 10 detik. Kamu dapat mengunci layar untuk menguji keandalan alarm.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _testQuickNotification(context, ref),
                    icon: const Icon(Icons.alarm_on_rounded),
                    label: const Text('Jadwalkan Notifikasi 10 Detik'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard({
    required String stepNumber,
    required String title,
    required String description,
    String? buttonLabel,
    VoidCallback? onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: const Color(0xFF2563EB),
                child: Text(
                  stepNumber,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
          ),
          if (buttonLabel != null && onTap != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(buttonLabel, style: const TextStyle(fontSize: 12)),
            ),
          ],
        ],
      ),
    );
  }
}
