// REUSABLE WIDGET: RatingInput
// Interactive rating input with 5 reel spools and animated spring scaling.

import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/text_styles.dart';
import 'clapper_rating.dart';

class RatingInput extends StatefulWidget {
  final double rating;
  final ValueChanged<double> onRatingChanged;

  const RatingInput({
    super.key,
    required this.rating,
    required this.onRatingChanged,
  });

  @override
  State<RatingInput> createState() => _RatingInputState();
}

class _RatingInputState extends State<RatingInput> {
  double _hoverRating = 0.0;

  @override
  Widget build(BuildContext context) {
    final activeRating = _hoverRating > 0 ? _hoverRating : widget.rating;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 1; i <= 5; i++)
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hoverRating = i.toDouble()),
            onExit: (_) => setState(() => _hoverRating = 0.0),
            child: GestureDetector(
              onTap: () => widget.onRatingChanged(i.toDouble()),
              child: AnimatedScale(
                scale: activeRating >= i ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutBack,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: CustomPaint(
                    size: const Size(28, 28),
                    painter: ReelSpoolPainter(
                      fillFraction: activeRating >= i ? 1.0 : 0.0,
                    ),
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(width: 12),
        Text(
          '${widget.rating.toInt()} / 5 REELS',
          style: CinemaText.monoBadge(color: CinemaTokens.projectorAmber),
        ),
      ],
    );
  }
}
