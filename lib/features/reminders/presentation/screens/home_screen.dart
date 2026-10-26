import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/date_formatter.dart';
import '../controllers/reminder_providers.dart';
import '../widgets/reminder_card.dart';
import 'reminder_form_screen.dart';
import '../../../voice_ai/presentation/screens/voice_input_modal.dart';
import '../../../voice_ai/presentation/controllers/ai_extraction_controller.dart';
import '../../../voice_ai/presentation/widgets/ai_review_confirmation_sheet.dart';
import '../../../settings/presentation/screens/battery_guide_screen.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../auth/presentation/screens/login_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final remindersAsync = ref.watch(reminderListNotifierProvider);
    final selectedTab = ref.watch(selectedTabProvider);

    return Scaffold(
      appBar: AppBar(
        title: Builder(
          builder: (context) {
            final currentUser = ref.watch(currentUserProvider);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'ELING',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: Color(0xFF2563EB),
                        fontSize: 22,
                      ),
                    ),
                    if (currentUser != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          currentUser.namaPengguna.split(' ').first,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  currentUser != null
                      ? 'Halo, ${currentUser.namaPengguna}'
                      : DateFormatter.formatFullDate(DateTime.now()),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_outlined),
            tooltip: 'Panduan Baterai & Notifikasi',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const BatteryGuideScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            tooltip: 'Keluar (Logout)',
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs (Hari Ini, Mendatang, Selesai)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _buildTabButton(
                    context: context,
                    ref: ref,
                    index: 0,
                    label: 'Hari Ini',
                    isSelected: selectedTab == 0,
                  ),
                  _buildTabButton(
                    context: context,
                    ref: ref,
                    index: 1,
                    label: 'Mendatang',
                    isSelected: selectedTab == 1,
                  ),
                  _buildTabButton(
                    context: context,
                    ref: ref,
                    index: 2,
                    label: 'Selesai',
                    isSelected: selectedTab == 2,
                  ),
                ],
              ),
            ),
          ),

          // Main Reminder List
          Expanded(
            child: remindersAsync.when(
              data: (reminders) {
                if (reminders.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            selectedTab == 2
                                ? Icons.task_alt_rounded
                                : Icons.event_available_rounded,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            selectedTab == 0
                                ? 'Tidak ada pengingat hari ini'
                                : selectedTab == 1
                                    ? 'Belum ada pengingat mendatang'
                                    : 'Belum ada pengingat yang selesai',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            selectedTab == 2
                                ? 'Selesaikan tugasmu untuk melihat daftarnya di sini.'
                                : 'Tekan tombol (+) di bawah untuk membuat pengingat baru.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref
                      .read(reminderListNotifierProvider.notifier)
                      .loadReminders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80, top: 4),
                    itemCount: reminders.length,
                    itemBuilder: (context, index) {
                      final item = reminders[index];
                      final notifier =
                          ref.read(reminderListNotifierProvider.notifier);

                      return ReminderCard(
                        reminder: item,
                        onToggleComplete: () => notifier.toggleComplete(item),
                        onToggleActive: () => notifier.toggleActive(item),
                        onDelete: () => notifier.deleteReminder(item),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Text('Terjadi kesalahan: $err'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Voice AI Action (Speech-to-Text)
          FloatingActionButton.small(
            heroTag: 'fab_voice',
            backgroundColor: Colors.purple.shade600,
            foregroundColor: Colors.white,
            onPressed: () {
              VoiceInputModal.show(
                context: context,
                onProceedToAi: (transcribedText) async {
                  // Tampilkan dialog loading AI
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: Colors.purple),
                              SizedBox(height: 16),
                              Text(
                                'Menganalisis pengingat dengan AI...',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );

                  final proposal = await ref
                      .read(aiExtractionNotifierProvider.notifier)
                      .extractFromSpeech(transcribedText);

                  // Tutup loading dialog
                  if (context.mounted) {
                    Navigator.of(context, rootNavigator: true).pop();
                  }

                  if (proposal != null && context.mounted) {
                    // Buka modal review konfirmasi sebelum data disimpan
                    AiReviewConfirmationSheet.show(
                      context: context,
                      proposal: proposal,
                    );
                  }
                },
              );
            },
            child: const Icon(Icons.mic_rounded),
          ),
          const SizedBox(height: 12),
          // Manual Add Action
          FloatingActionButton.extended(
            heroTag: 'fab_manual',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ReminderFormScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required BuildContext context,
    required WidgetRef ref,
    required int index,
    required String label,
    required bool isSelected,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          ref.read(selectedTabProvider.notifier).state = index;
          ref.read(reminderListNotifierProvider.notifier).loadReminders();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
