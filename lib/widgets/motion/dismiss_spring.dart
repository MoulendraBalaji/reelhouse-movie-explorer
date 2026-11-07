// ANIMATION: explicit (Dismissible + Physical Spring Physics + "REMOVED" Stamp Reveal)
// DismissSpring: Watchlist dismissible swipe with physical spring mechanics and undo restoration.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../theme/app_theme.dart';
import '../../theme/text_styles.dart';

class DismissSpring extends StatelessWidget {
  final Key itemKey;
  final Widget child;
  final VoidCallback onDismissed;
  final VoidCallback? onUndo;

  const DismissSpring({
    required this.itemKey,
    required this.child,
    required this.onDismissed,
    this.onUndo,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.cinemaColors;

    return Dismissible(
      key: itemKey,
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        onDismissed();
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: colors.surfaceElevated,
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
              borderRadius: CinemaTokens.borderSharp,
              side: CinemaTokens.borderSideRed,
            ),
            content: Row(
              children: [
                const Icon(Icons.delete_outline, size: 18, color: CinemaTokens.ticketRed),
                const SizedBox(width: 12),
                Text('FILM REEL REMOVED FROM VAULT', style: CinemaText.monoLabel(color: colors.textPrimary)),
              ],
            ),
            action: onUndo != null
                ? SnackBarAction(
                    label: 'RESTORE',
                    textColor: colors.accentAmber,
                    onPressed: onUndo!,
                  )
                : null,
          ),
        );
      },
      background: Container(
        color: CinemaTokens.ticketRed.withValues(alpha: 0.2),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 28),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.rotate(
              angle: -10 * math.pi / 180,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: CinemaTokens.ticketRed, width: 2),
                  borderRadius: CinemaTokens.borderSharp,
                ),
                child: Text(
                  'REMOVED',
                  style: TextStyle(
                    fontFamily: CinemaTokens.fontDisplay,
                    fontSize: 20,
                    letterSpacing: 2,
                    color: CinemaTokens.ticketRed,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.delete_sweep, color: CinemaTokens.ticketRed, size: 28),
          ],
        ),
      ),
      child: child,
    );
  }
}
