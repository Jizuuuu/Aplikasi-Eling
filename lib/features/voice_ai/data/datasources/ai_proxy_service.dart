import 'package:dio/dio.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/parsed_reminder_proposal.dart';

class AiProxyService {
  final Dio _dio;

  AiProxyService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConstants.aiProxyBaseUrl,
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 12),
                headers: {'Content-Type': 'application/json'},
              ),
            );

  /// Mengirim teks ucapan ke AI Proxy untuk diekstrak entitasnya
  Future<ParsedReminderProposal> parseSpeechToReminder(String speechText) async {
    final nowIso = DateTime.now().toIso8601String();

    try {
      final response = await _dio.post(
        '/api/parse-reminder',
        data: {
          'text': speechText,
          'user_local_time': nowIso,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> data =
            response.data is Map<String, dynamic>
                ? response.data as Map<String, dynamic>
                : Map<String, dynamic>.from(response.data as Map);

        return ParsedReminderProposal.fromJson(
          data,
          originalSpeechText: speechText,
        );
      } else {
        throw Exception('Status respon proxy: ${response.statusCode}');
      }
    } catch (e) {
      // Offline / Connection Fallback:
      // Jika proxy server belum dinyalakan atau tidak ada internet,
      // fallback parser lokal cerdas tetap memproses ucapan agar mahasiswa
      // tetap bisa mendemokan aplikasi tanpa hambatan.
      return _generateClientSideFallback(speechText);
    }
  }

  /// Heuristik offline cerdas untuk bahasa Indonesia
  ParsedReminderProposal _generateClientSideFallback(String text) {
    final now = DateTime.now();
    final lower = text.toLowerCase();

    DateTime targetDate = now;
    String category = 'Lainnya';

    // 1. Ekstraksi Hari
    if (lower.contains('besok')) {
      targetDate = now.add(const Duration(days: 1));
    } else if (lower.contains('lusa')) {
      targetDate = now.add(const Duration(days: 2));
    }

    // 2. Ekstraksi Kategori
    if (lower.contains('beli') || lower.contains('belanja') || lower.contains('pasar')) {
      category = 'Belanja';
    } else if (lower.contains('tugas') || lower.contains('pr') || lower.contains('proyek')) {
      category = 'Tugas';
    } else if (lower.contains('kuliah') || lower.contains('dosen') || lower.contains('kelas') || lower.contains('matkul')) {
      category = 'Kuliah';
    } else if (lower.contains('olahraga') || lower.contains('makan') || lower.contains('tidur')) {
      category = 'Pribadi';
    }

    // 3. Ekstraksi Jam
    int hour = 9;
    if (lower.contains('siang')) hour = 13;
    if (lower.contains('sore')) hour = 16;
    if (lower.contains('malam')) hour = 19;

    final hourReg = RegExp(r'jam\s+(\d{1,2})');
    final match = hourReg.firstMatch(lower);
    if (match != null) {
      int parsedH = int.tryParse(match.group(1) ?? '') ?? hour;
      if ((lower.contains('siang') || lower.contains('sore') || lower.contains('malam')) && parsedH < 12) {
        parsedH += 12;
      }
      hour = parsedH;
    }

    targetDate = DateTime(targetDate.year, targetDate.month, targetDate.day, hour, 0);

    // 4. Bersihkan Judul
    String cleanTitle = text
        .replaceAll(RegExp(r'^(ingatkan|tolong ingatkan|ingatkan saya|jadwalkan)\s+', caseSensitive: false), '')
        .trim();
    if (cleanTitle.isEmpty) cleanTitle = 'Aktivitas Baru';
    cleanTitle = cleanTitle[0].toUpperCase() + cleanTitle.substring(1);

    return ParsedReminderProposal(
      title: cleanTitle,
      description: 'Dibuat via Voice AI (Fallback Lokal): "$text"',
      remindAt: targetDate,
      categoryName: category,
      originalSpeechText: text,
    );
  }
}
