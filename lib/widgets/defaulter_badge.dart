import 'package:flutter/material.dart';

/// Small red "DEFAULTER" chip — shown next to a flagged customer's name in lists.
class DefaulterBadge extends StatelessWidget {
  const DefaulterBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 5 : 7, vertical: compact ? 1 : 2),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.money_off,
              size: compact ? 11 : 13, color: scheme.onErrorContainer),
          const SizedBox(width: 3),
          Text(
            'DEFAULTER',
            style: TextStyle(
              color: scheme.onErrorContainer,
              fontSize: compact ? 9 : 10.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width red warning banner — shown on the order-taking and packing screens.
class DefaulterBanner extends StatelessWidget {
  const DefaulterBanner({super.key, this.reason});

  final String? reason;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: scheme.onErrorContainer),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DEFAULTER — refuses payment',
                  style: TextStyle(
                      color: scheme.onErrorContainer,
                      fontWeight: FontWeight.bold),
                ),
                if (reason != null && reason!.isNotEmpty)
                  Text(reason!,
                      style: TextStyle(
                          color: scheme.onErrorContainer, fontSize: 12.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
