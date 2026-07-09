/// Formats a DateTime as DD/MM/YYYY, returns '-' for null.
String formatDate(DateTime? d) {
  if (d == null) return '-';
  return '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}

/// Formats an amount as a currency string.
String formatAmount(int? amount) => '₹${(amount ?? 0)}';

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
