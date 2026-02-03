class Payment {
  Payment({
    required this.amount,
    required this.timestamp,
    this.senderName,
    required this.rawText,
  });

  final double amount;
  final DateTime timestamp;
  final String? senderName;
  final String rawText;

  static Payment? tryParse(String text, DateTime timestamp) {
    final lower = text.toLowerCase();
    if (!(lower.contains('yape') || lower.contains('recibiste'))) {
      return null;
    }
    if (!lower.contains('s/')) {
      return null;
    }

    final amountMatch = RegExp(r's/\s*([0-9]+(?:[\.,][0-9]{1,2})?)', caseSensitive: false)
        .firstMatch(text);
    if (amountMatch == null) {
      return null;
    }
    final amountRaw = amountMatch.group(1) ?? '0';
    final normalized = amountRaw.replaceAll('.', '').replaceAll(',', '.');
    final amount = double.tryParse(normalized);
    if (amount == null) {
      return null;
    }

    String? senderName;
    final senderMatch = RegExp(
      r'recibiste\s+s/\s*[0-9\.,]+\s+de\s+([A-Za-zÁÉÍÓÚÜÑáéíóúüñ\s]+)',
      caseSensitive: false,
    ).firstMatch(text);
    if (senderMatch != null) {
      senderName = senderMatch.group(1)?.trim();
    }

    return Payment(
      amount: amount,
      timestamp: timestamp,
      senderName: senderName?.isEmpty ?? true ? null : senderName,
      rawText: text,
    );
  }
}
