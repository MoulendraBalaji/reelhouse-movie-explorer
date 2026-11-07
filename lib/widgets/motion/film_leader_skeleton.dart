// ANIMATION: explicit (CustomPainter + Ticker + Celluloid Scratches - NO generic shimmer)
// FilmLeaderSkeleton: Authentic 35mm film leader loading placeholder with looping countdown frames.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../theme/motion.dart';
import '../../theme/text_styles.dart';

class FilmLeaderSkeleton extends StatefulWidget {
  final double width;
  final double height;

  const FilmLeaderSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 200.0,
  });

  @override
  State<FilmLeaderSkeleton> createState() => _FilmLeaderSkeletonState();
}

class _FilmLeaderSkeletonState extends State<FilmLeaderSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scratchController;
  final math.Random _rnd = math.Random();

  @override
  void initState() {
    super.initState();
    _scratchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    )..repeat();
  }

  @override
  void dispose() {
    _scratchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (CinemaMotion.isReducedMotion(context)) {
      return Container(
        width: widget.width,
        height: widget.height,
        color: CinemaTokens.boothBrown,
        child: Center(
          child: Text('LOADING REEL...', style: CinemaText.monoLabel(color: CinemaTokens.ash)),
        ),
      );
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _scratchController,
        builder: (context, _) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: CinemaTokens.boothBrown,
              border: Border.all(color: CinemaTokens.hairline),
              borderRadius: CinemaTokens.borderSharp,
            ),
            child: CustomPaint(
              painter: SkeletonScratchesPainter(seed: _rnd.nextDouble()),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: CinemaTokens.hairline, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          '${((_scratchController.value * 3).toInt() % 3) + 1}',
                          style: TextStyle(
                            fontFamily: CinemaTokens.fontDisplay,
                            fontSize: 24,
                            color: CinemaTokens.projectorAmber.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'THREADING FILM...',
                      style: CinemaText.monoBadge(color: CinemaTokens.ash),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SkeletonScratchesPainter extends CustomPainter {
  final double seed;

  SkeletonScratchesPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random((seed * 1000).toInt());
    final scratchPaint = Paint()
      ..color = CinemaTokens.hairline.withValues(alpha: 0.3)
      ..strokeWidth = 1.0;

    for (int i = 0; i < 4; i++) {
      final x = rnd.nextDouble() * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x + (rnd.nextDouble() - 0.5) * 6, size.height), scratchPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SkeletonScratchesPainter oldDelegate) => true;
}
