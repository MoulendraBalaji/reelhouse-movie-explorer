// SIGNATURE WIDGET: FilmStripBorder
// Perforated 35mm sprocket-hole edge for film posters, headers, and separators.

import 'package:flutter/material.dart';
import '../theme/tokens.dart';

enum SprocketOrientation { horizontal, vertical }

class FilmStripBorder extends StatelessWidget {
  final Widget child;
  final int sprocketCount;
  final double borderOpacity;
  final SprocketOrientation orientation;

  const FilmStripBorder({
    super.key,
    required this.child,
    this.sprocketCount = 6,
    this.borderOpacity = 1.0,
    this.orientation = SprocketOrientation.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: FilmStripBorderPainter(
        sprocketCount: sprocketCount,
        opacity: borderOpacity,
        orientation: orientation,
      ),
      child: child,
    );
  }
}

class FilmStripBorderPainter extends CustomPainter {
  final int sprocketCount;
  final double opacity;
  final SprocketOrientation orientation;

  FilmStripBorderPainter({
    required this.sprocketCount,
    required this.opacity,
    required this.orientation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.01) return;

    final holePaint = Paint()
      ..color = CinemaTokens.celluloidBlack.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = CinemaTokens.hairline.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    if (orientation == SprocketOrientation.horizontal) {
      const holeW = 8.0;
      const holeH = 12.0;
      final step = size.width / (sprocketCount + 1);

      for (int i = 1; i <= sprocketCount; i++) {
        final cx = i * step;
        // Top edge holes
        final topRect = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, 10), width: holeW, height: holeH),
          const Radius.circular(2),
        );
        canvas.drawRRect(topRect, holePaint);
        canvas.drawRRect(topRect, borderPaint);

        // Bottom edge holes
        final btmRect = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(cx, size.height - 10), width: holeW, height: holeH),
          const Radius.circular(2),
        );
        canvas.drawRRect(btmRect, holePaint);
        canvas.drawRRect(btmRect, borderPaint);
      }
    } else {
      const holeW = 12.0;
      const holeH = 8.0;
      final step = size.height / (sprocketCount + 1);

      for (int i = 1; i <= sprocketCount; i++) {
        final cy = i * step;
        // Left edge holes
        final leftRect = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(10, cy), width: holeW, height: holeH),
          const Radius.circular(2),
        );
        canvas.drawRRect(leftRect, holePaint);
        canvas.drawRRect(leftRect, borderPaint);

        // Right edge holes
        final rightRect = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(size.width - 10, cy), width: holeW, height: holeH),
          const Radius.circular(2),
        );
        canvas.drawRRect(rightRect, holePaint);
        canvas.drawRRect(rightRect, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant FilmStripBorderPainter oldDelegate) {
    return oldDelegate.opacity != opacity ||
        oldDelegate.sprocketCount != sprocketCount ||
        oldDelegate.orientation != orientation;
  }
}
