/// Formats a DateTime as DD/MM/YYYY, returns '-' for null.
String formatDate(DateTime? d) {
  if (d == null) return '-';
  return '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}

/// Groups an integer using the Indian numbering system.
/// e.g. 1234567 -> "12,34,567". Handles negative values.
String groupIndian(int value) {
  final neg = value < 0;
  final digits = value.abs().toString();
  if (digits.length <= 3) return neg ? '-$digits' : digits;
  final last3 = digits.substring(digits.length - 3);
  var rest = digits.substring(0, digits.length - 3);
  final parts = <String>[];
  while (rest.length > 2) {
    parts.insert(0, rest.substring(rest.length - 2));
    rest = rest.substring(0, rest.length - 2);
  }
  if (rest.isNotEmpty) parts.insert(0, rest);
  final grouped = '${parts.join(',')},$last3';
  return neg ? '-$grouped' : grouped;
}

/// Formats an amount as a rupee string with Indian digit grouping.
String formatAmount(int? amount) => '₹${groupIndian(amount ?? 0)}';

/// Extracts the error detail string from a DioException response body.
String extractApiError(Object? e) {
  try {
    final err = e.toString();
    if (err.contains('"detail"')) {
      final start = err.indexOf('"detail":') + 10;
      final end = err.indexOf('"', start);
      return err.substring(start, end);
    }
  } catch (_) {}
  return 'An error occurred. Please try again.';
}
