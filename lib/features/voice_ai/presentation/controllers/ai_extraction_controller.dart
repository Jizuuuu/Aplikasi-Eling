import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/ai_proxy_service.dart';
import '../../domain/entities/parsed_reminder_proposal.dart';

final aiProxyServiceProvider = Provider<AiProxyService>((ref) {
  return AiProxyService();
});

class AiExtractionState {
  final bool isLoading;
  final ParsedReminderProposal? proposal;
  final String? errorMessage;

  const AiExtractionState({
    this.isLoading = false,
    this.proposal,
    this.errorMessage,
  });
}

class AiExtractionNotifier extends StateNotifier<AiExtractionState> {
  final AiProxyService _aiService;

  AiExtractionNotifier(this._aiService) : super(const AiExtractionState());

  Future<ParsedReminderProposal?> extractFromSpeech(String speechText) async {
    state = const AiExtractionState(isLoading: true);
    try {
      final result = await _aiService.parseSpeechToReminder(speechText);
      state = AiExtractionState(isLoading: false, proposal: result);
      return result;
    } catch (e) {
      state = AiExtractionState(
        isLoading: false,
        errorMessage: 'Gagal mengekstrak pengingat: $e',
      );
      return null;
    }
  }

  void reset() {
    state = const AiExtractionState();
  }
}

final aiExtractionNotifierProvider =
    StateNotifierProvider<AiExtractionNotifier, AiExtractionState>((ref) {
  final service = ref.watch(aiProxyServiceProvider);
  return AiExtractionNotifier(service);
});
