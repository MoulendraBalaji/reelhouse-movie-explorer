// REUSABLE WIDGET: EmptyState
// Cinema themed empty state placeholder ("NO SPOOLS IN VAULT").

import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/text_styles.dart';

class EmptyState extends StatelessWidget {
  final String title;
  final String message;
  final Widget? action;

  const EmptyState({
    super.key,
    this.title = 'NO SPOOLS IN VAULT',
    this.message = 'The projection archives contain no matching film canisters.',
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                border: Border.all(color: CinemaTokens.hairline, width: 2),
                shape: BoxShape.circle,
                color: CinemaTokens.boothBrown,
              ),
              child: const Center(
                child: Icon(
                  Icons.camera_roll_outlined,
                  size: 36,
                  color: CinemaTokens.ash,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontFamily: CinemaTokens.fontDisplay,
                fontSize: 28,
                letterSpacing: 2,
                color: CinemaTokens.bone,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: CinemaText.bodyMedium(color: CinemaTokens.ash),
              ),
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
