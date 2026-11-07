// REUSABLE WIDGET: SectionHeader
// Editorial cinema section header with numbered reveal mask and left-to-right drawing underline rule.

import 'package:flutter/material.dart';
import 'motion/numbered_heading_mask.dart';
import 'motion/scroll_reveal_stagger.dart';

class SectionHeader extends StatelessWidget {
  final String number;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration delay;

  const SectionHeader({
    super.key,
    required this.number,
    required this.title,
    this.actionLabel,
    this.onAction,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            NumberedHeadingMask(
              number: number,
              title: title,
              delay: delay,
            ),
            if (actionLabel != null)
              TextButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.arrow_forward, size: 14),
                label: Text(actionLabel!.toUpperCase()),
              ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedUnderlineRule(delay: delay),
      ],
    );
  }
}
