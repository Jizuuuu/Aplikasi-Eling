class ParsedReminderProposal {
  final String title;
  final String? description;
  final DateTime remindAt;
  final String categoryName;
  final String originalSpeechText;

  const ParsedReminderProposal({
    required this.title,
    this.description,
    required this.remindAt,
    required this.categoryName,
    required this.originalSpeechText,
  });

  factory ParsedReminderProposal.fromJson(
    Map<String, dynamic> json, {
    required String originalSpeechText,
  }) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['remind_at'] as String).toLocal();
    } catch (_) {
      // Default to tomorrow 09:00 if date parsing fails
      final now = DateTime.now().add(const Duration(days: 1));
      parsedDate = DateTime(now.year, now.month, now.day, 9, 0);
    }

    return ParsedReminderProposal(
      title: (json['title'] as String?)?.trim() ?? 'Aktivitas Baru',
      description: json['description'] as String?,
      remindAt: parsedDate,
      categoryName: (json['category'] as String?) ?? 'Lainnya',
      originalSpeechText: originalSpeechText,
    );
  }
}
