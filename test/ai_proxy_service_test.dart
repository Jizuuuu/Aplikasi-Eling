import 'package:flutter_test/flutter_test.dart';
import 'package:eling_app/features/voice_ai/data/datasources/ai_proxy_service.dart';

void main() {
  group('AI Proxy & Indonesian Speech Entity Parsing Tests (IMPAL Unit Testing)', () {
    late AiProxyService aiService;

    setUp(() {
      aiService = AiProxyService();
    });

    test('Harus mengekstrak kata kunci tugas kuliah dan tanggal besok', () async {
      const speech = 'Ingatkan kumpul tugas laporan IMPAL besok jam 2 siang';

      final proposal = await aiService.parseSpeechToReminder(speech);

      expect(proposal.title.contains('Kumpul tugas laporan IMPAL'), isTrue);
      expect(proposal.categoryName, 'Tugas');
      expect(proposal.originalSpeechText, speech);

      // Verifikasi jam 2 siang = 14:00
      expect(proposal.remindAt.hour, 14);

      // Verifikasi tanggal besok
      final expectedTomorrow = DateTime.now().add(const Duration(days: 1)).day;
      expect(proposal.remindAt.day, expectedTomorrow);
    });

    test('Harus mengklasifikasikan kategori belanja dengan benar', () async {
      const speech = 'Tolong ingatkan beli modul kuliah di fotokopi';

      final proposal = await aiService.parseSpeechToReminder(speech);

      expect(proposal.categoryName, 'Belanja');
      expect(proposal.title.contains('Beli modul kuliah'), isTrue);
    });

    test('Harus menangani kata "lusa" untuk penambahan 2 hari', () async {
      const speech = 'Jadwalkan rapat kelompok lusa jam 8 malam';

      final proposal = await aiService.parseSpeechToReminder(speech);

      final expectedLusa = DateTime.now().add(const Duration(days: 2)).day;
      expect(proposal.remindAt.day, expectedLusa);
      expect(proposal.remindAt.hour, 20); // 8 malam = 20:00
    });
  });
}
