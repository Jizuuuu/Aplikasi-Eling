import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class SpeechToTextService {
  static final SpeechToTextService instance = SpeechToTextService._init();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isInitialized = false;

  SpeechToTextService._init();

  bool get isListening => _speech.isListening;
  bool get isAvailable => _isInitialized;

  /// Inisialisasi STT dan periksa apakah mikrofon tersedia
  Future<bool> initialize({
    Function(String status)? onStatus,
    Function(dynamic error)? onError,
  }) async {
    if (_isInitialized) return true;

    // Periksa dan minta izin mikrofon terlebih dahulu
    final micStatus = await Permission.microphone.request();
    if (micStatus != PermissionStatus.granted) {
      return false;
    }

    _isInitialized = await _speech.initialize(
      onStatus: onStatus,
      onError: onError,
      debugLogging: false,
    );

    return _isInitialized;
  }

  /// Mulai mendengarkan suara pengguna dengan preferensi Bahasa Indonesia (id_ID)
  Future<void> startListening({
    required Function(String recognizedWords, bool isFinal) onResult,
    Function(double soundLevel)? onSoundLevelChange,
  }) async {
    if (!_isInitialized) {
      final success = await initialize();
      if (!success) {
        throw Exception('Mikrofon tidak diizinkan atau tidak didukung pada perangkat ini.');
      }
    }

    // Cari locale bahasa Indonesia jika tersedia pada device
    final locales = await _speech.locales();
    final idLocale = locales.firstWhere(
      (loc) => loc.localeId.toLowerCase().startsWith('id'),
      orElse: () => locales.isNotEmpty
          ? locales.first
          : stt.LocaleName('id_ID', 'Bahasa Indonesia'),
    );

    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      localeId: idLocale.localeId,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 4),
      partialResults: true,
      onSoundLevelChange: onSoundLevelChange,
      cancelOnError: true,
      listenMode: stt.ListenMode.confirmation,
    );
  }

  /// Berhenti mendengarkan
  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  /// Batalkan sesi pendengaran
  Future<void> cancelListening() async {
    if (_speech.isListening) {
      await _speech.cancel();
    }
  }
}
