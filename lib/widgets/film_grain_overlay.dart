// SIGNATURE WIDGET: FilmGrainOverlay
// Subtle animated 35mm celluloid noise overlay, low opacity, paused when reduced motion is enabled.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/motion.dart';
import '../core/responsive.dart';

class FilmGrainOverlay extends StatefulWidget {
  final Widget? child;
  final double opacity;

  const FilmGrainOverlay({
    super.key,
    this.child,
    this.opacity = 0.035,
  });

  @override
  State<FilmGrainOverlay> createState() => _FilmGrainOverlayState();
}

class _FilmGrainOverlayState extends State<FilmGrainOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _grainController;
  final math.Random _rnd = math.Random();

  @override
  void initState() {
    super.initState();
    _grainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    )..repeat();
  }

  @override
  void dispose() {
    _grainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Disable grain on mobile viewports or reduced motion to maintain strict 60fps performance budget
    final isMobile = Responsive.isMobile(context);
    final isReduced = CinemaMotion.isReducedMotion(context);

    if (isMobile || isReduced) {
      return widget.child ?? const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          if (widget.child != null) widget.child!,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _grainController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: GrainPainter(
                      opacity: widget.opacity,
                      seed: _rnd.nextDouble(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GrainPainter extends CustomPainter {
  final double opacity;
  final double seed;

  GrainPainter({required this.opacity, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width == 0 || size.height == 0) return;

    final rnd = math.Random((seed * 10000).toInt());
    final paintLight = Paint()..color = CinemaTokens.bone.withValues(alpha: opacity);
    final paintDark = Paint()..color = CinemaTokens.celluloidBlack.withValues(alpha: opacity * 1.5);

    // Render random noise speckles
    const speckleCount = 180;
    for (int i = 0; i < speckleCount; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height;
      final paint = rnd.nextBool() ? paintLight : paintDark;
      canvas.drawRect(Rect.fromLTWH(x, y, 1.2, 1.2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant GrainPainter oldDelegate) => true;
}
