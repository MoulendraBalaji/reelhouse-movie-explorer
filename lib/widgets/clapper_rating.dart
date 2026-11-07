// SIGNATURE WIDGET: ClapperRating
// Rating visualised as 5 film reel spools / clapperboards instead of plain stars.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/text_styles.dart';

class ClapperRating extends StatelessWidget {
  final double rating; // 0.0 to 10.0 (converted to 5-spool scale: rating / 2.0)
  final double size;
  final bool showNumeric;

  const ClapperRating({
    super.key,
    required this.rating,
    this.size = 14.0,
    this.showNumeric = true,
  });

  @override
  Widget build(BuildContext context) {
    // TMDB ratings are 0-10; convert to 5 spools (e.g. 8.6/10 -> 4.3 reels)
    final spoolRating = (rating / 2.0).clamp(0.0, 5.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (int i = 1; i <= 5; i++) ...[
          _buildReelSpool(i, spoolRating),
          if (i < 5) SizedBox(width: size * 0.22),
        ],
        if (showNumeric) ...[
          const SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: CinemaText.monoBadge(color: CinemaTokens.projectorAmber),
          ),
        ],
      ],
    );
  }

  Widget _buildReelSpool(int index, double activeRating) {
    double fillFraction = 0.0;
    if (activeRating >= index) {
      fillFraction = 1.0;
    } else if (activeRating > index - 1) {
      fillFraction = activeRating - (index - 1);
    }

    return CustomPaint(
      size: Size(size, size),
      painter: ReelSpoolPainter(fillFraction: fillFraction),
    );
  }
}

class ReelSpoolPainter extends CustomPainter {
  final double fillFraction;

  ReelSpoolPainter({required this.fillFraction});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final outerPaint = Paint()
      ..color = fillFraction > 0.0 ? CinemaTokens.projectorAmber : CinemaTokens.hairline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Draw spool outer rim
    canvas.drawCircle(center, radius - 0.6, outerPaint);

    // Inner hub
    final hubRadius = radius * 0.35;
    final hubPaint = Paint()
      ..color = fillFraction > 0.0
          ? CinemaTokens.projectorAmber.withValues(alpha: fillFraction)
          : CinemaTokens.hairline
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, hubRadius, hubPaint);

    // Spool holes (3 holes)
    final holeRadius = radius * 0.20;
    final holeDist = radius * 0.60;
    final holePaint = Paint()
      ..color = fillFraction > 0.0 ? CinemaTokens.celluloidBlack : CinemaTokens.hairline
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 3; i++) {
      final angle = i * (2 * math.pi / 3);
      final hx = center.dx + holeDist * math.cos(angle);
      final hy = center.dy + holeDist * math.sin(angle);
      canvas.drawCircle(Offset(hx, hy), holeRadius, holePaint);
    }
  }

  @override
  bool shouldRepaint(covariant ReelSpoolPainter oldDelegate) {
    return oldDelegate.fillFraction != fillFraction;
  }
}
