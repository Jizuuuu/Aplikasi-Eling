import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/speech_to_text_service.dart';

class VoiceRecordState {
  final bool isListening;
  final String recognizedText;
  final double soundLevel;
  final String? errorMessage;
  final bool isReady;

  const VoiceRecordState({
    this.isListening = false,
    this.recognizedText = '',
    this.soundLevel = 0.0,
    this.errorMessage,
    this.isReady = false,
  });

  VoiceRecordState copyWith({
    bool? isListening,
    String? recognizedText,
    double? soundLevel,
    String? errorMessage,
    bool? isReady,
  }) {
    return VoiceRecordState(
      isListening: isListening ?? this.isListening,
      recognizedText: recognizedText ?? this.recognizedText,
      soundLevel: soundLevel ?? this.soundLevel,
      errorMessage: errorMessage,
      isReady: isReady ?? this.isReady,
    );
  }
}

class VoiceRecordNotifier extends StateNotifier<VoiceRecordState> {
  final SpeechToTextService _sttService;

  VoiceRecordNotifier(this._sttService) : super(const VoiceRecordState());

  Future<void> startListening() async {
    state = state.copyWith(
      isListening: true,
      recognizedText: '',
      soundLevel: 0.0,
      errorMessage: null,
    );

    try {
      final hasPermission = await _sttService.initialize(
        onError: (err) {
          state = state.copyWith(
            isListening: false,
            errorMessage: 'Gagal mengenali suara: ${(err as dynamic)?.errorMsg ?? err}',
          );
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            state = state.copyWith(isListening: false);
          }
        },
      );

      if (!hasPermission) {
        state = state.copyWith(
          isListening: false,
          errorMessage: 'Izin mikrofon belum diberikan. Silakan aktifkan izin di pengaturan HP.',
        );
        return;
      }

      await _sttService.startListening(
        onResult: (text, isFinal) {
          state = state.copyWith(
            recognizedText: text,
            isListening: !isFinal,
          );
        },
        onSoundLevelChange: (level) {
          state = state.copyWith(soundLevel: level);
        },
      );
    } catch (e) {
      state = state.copyWith(
        isListening: false,
        errorMessage: 'Terjadi kesalahan saat memulai rekaman: $e',
      );
    }
  }

  Future<void> stopListening() async {
    await _sttService.stopListening();
    state = state.copyWith(isListening: false);
  }

  Future<void> cancelListening() async {
    await _sttService.cancelListening();
    state = state.copyWith(isListening: false, recognizedText: '');
  }

  void updateTextManually(String newText) {
    state = state.copyWith(recognizedText: newText);
  }

  void reset() {
    state = const VoiceRecordState();
  }
}

final sttServiceProvider = Provider<SpeechToTextService>((ref) {
  return SpeechToTextService.instance;
});

final voiceRecordNotifierProvider =
    StateNotifierProvider.autoDispose<VoiceRecordNotifier, VoiceRecordState>((ref) {
  final service = ref.watch(sttServiceProvider);
  return VoiceRecordNotifier(service);
});
