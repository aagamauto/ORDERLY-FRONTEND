import 'package:flutter/material.dart';

/// Max content width for forms on large screens (tablets / large phones landscape).
const double kFormMaxWidth = 520;

/// Max content width for detail & list bodies on large screens.
const double kContentMaxWidth = 720;

/// Centers [child] and caps its width on large screens so forms and content
/// don't stretch edge-to-edge on tablets. On phones (narrower than [maxWidth])
/// it behaves as a no-op and the child fills the available width.
class CenteredConstrained extends StatelessWidget {
  const CenteredConstrained({
    super.key,
    required this.child,
    this.maxWidth = kFormMaxWidth,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    // Top-center (not Center) so short content sits at the top instead of
    // floating in the vertical middle, while still capping width on large
    // screens. Scroll views inside still scroll normally when content is tall.
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
