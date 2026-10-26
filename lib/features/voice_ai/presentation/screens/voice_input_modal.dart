import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/voice_record_controller.dart';
import '../widgets/speech_wave_widget.dart';

class VoiceInputModal extends ConsumerStatefulWidget {
  final Function(String transcribedText) onProceedToAi;

  const VoiceInputModal({
    super.key,
    required this.onProceedToAi,
  });

  static Future<void> show({
    required BuildContext context,
    required Function(String transcribedText) onProceedToAi,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VoiceInputModal(onProceedToAi: onProceedToAi),
    );
  }

  @override
  ConsumerState<VoiceInputModal> createState() => _VoiceInputModalState();
}

class _VoiceInputModalState extends ConsumerState<VoiceInputModal> {
  late TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();

    // Otomatis mulai merekam saat modal terbuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(voiceRecordNotifierProvider.notifier).startListening();
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceState = ref.watch(voiceRecordNotifierProvider);
    final voiceNotifier = ref.read(voiceRecordNotifierProvider.notifier);

    // Sync transcription into local controller if user hasn't edited manually
    if (voiceState.recognizedText.isNotEmpty &&
        _textEditingController.text != voiceState.recognizedText) {
      _textEditingController.text = voiceState.recognizedText;
    }

    final hasContent = _textEditingController.text.trim().isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.auto_awesome,
                        color: Colors.purple.shade700, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Input Suara Bahasa Indonesia',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.grey),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Speech Wave / Mic Animation
          SpeechWaveWidget(
            isListening: voiceState.isListening,
            soundLevel: voiceState.soundLevel,
            onTap: () {
              if (voiceState.isListening) {
                voiceNotifier.stopListening();
              } else {
                voiceNotifier.startListening();
              }
            },
          ),
          const SizedBox(height: 12),

          // Status hint
          Text(
            voiceState.isListening
                ? 'Mendengarkan... Silakan sebutkan pengingatmu'
                : 'Ketuk mikrofon di atas untuk mulai bicara',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: voiceState.isListening
                  ? Colors.purple.shade700
                  : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Contoh: "Ingatkan tugas IMPAL besok jam 2 siang"',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Error banner if any
          if (voiceState.errorMessage != null)
            Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      voiceState.errorMessage!,
                      style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

          // Transcription display / editable text box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: voiceState.isListening
                    ? Colors.purple.shade300
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: TextField(
              controller: _textEditingController,
              maxLines: 3,
              onChanged: (text) => voiceNotifier.updateTextManually(text),
              decoration: const InputDecoration(
                hintText: 'Teks ucapanmu akan muncul di sini...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                fillColor: Colors.transparent,
              ),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    voiceNotifier.cancelListening();
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: hasContent
                      ? () {
                          final text = _textEditingController.text.trim();
                          voiceNotifier.stopListening();
                          Navigator.of(context).pop();
                          widget.onProceedToAi(text);
                        }
                      : null,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text(
                    'Lanjut ke AI',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade200,
                    disabledForegroundColor: Colors.grey.shade500,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
