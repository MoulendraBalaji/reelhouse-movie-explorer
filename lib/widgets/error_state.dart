// REUSABLE WIDGET: ErrorState
// Cinema themed error state placeholder ("THE REEL SNAPPED – RETRY").

import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/text_styles.dart';

class ErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;

  const ErrorState({
    super.key,
    this.title = 'THE REEL SNAPPED',
    this.message = 'The projector gate encountered an obstruction while spooling film.',
    required this.onRetry,
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
                border: Border.all(color: CinemaTokens.ticketRed, width: 2),
                shape: BoxShape.circle,
                color: CinemaTokens.boothBrown,
              ),
              child: const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 36,
                  color: CinemaTokens.ticketRed,
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
                color: CinemaTokens.ticketRed,
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: CinemaText.bodyMedium(color: CinemaTokens.ash),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('RETHREAD PROJECTOR REEL'),
            ),
          ],
        ),
      ),
    );
  }
}
