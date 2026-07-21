import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the device's default phone dialer pre-filled with [rawNumber].
///
/// Strips formatting (spaces, dashes, parentheses) but keeps a leading `+` for
/// country codes. Shows a SnackBar if the number is empty or no dialer exists.
Future<void> dialNumber(BuildContext context, String rawNumber) async {
  final messenger = ScaffoldMessenger.of(context);
  final sanitized = rawNumber.replaceAll(RegExp(r'[^\d+]'), '');
  if (sanitized.isEmpty) {
    messenger.showSnackBar(
      const SnackBar(content: Text('No phone number for this customer')),
    );
    return;
  }
  final uri = Uri(scheme: 'tel', path: sanitized);
  try {
    final launched = await launchUrl(uri);
    if (!launched) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not open dialer for $sanitized')),
      );
    }
  } catch (_) {
    messenger.showSnackBar(
      SnackBar(content: Text('Could not open dialer for $sanitized')),
    );
  }
}
