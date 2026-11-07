// ANIMATION: explicit (AnimationController + CustomPainter + Ticker + Gate-weave jitter)
// ProjectorCountdownLeader: Authentic 35mm SMPTE universal film leader countdown (3-2-1),
// rotating sweep hand, animated film scratches, scrolling sprocket holes, gate-weave, and projector lamp flash.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../theme/motion.dart';
import '../../theme/text_styles.dart';

class ProjectorCountdownLeader extends StatefulWidget {
  final VoidCallback onCountdownComplete;

  const ProjectorCountdownLeader({
    super.key,
    required this.onCountdownComplete,
  });

  @override
  State<ProjectorCountdownLeader> createState() => _ProjectorCountdownLeaderState();
}

class _ProjectorCountdownLeaderState extends State<ProjectorCountdownLeader>
    with TickerProviderStateMixin {
  late final AnimationController _countdownController;
  late final AnimationController _jitterController;
  final math.Random _random = math.Random();

  double _gateWeaveX = 0.0;
  double _gateWeaveY = 0.0;
  int _currentNumber = 3;

  @override
  void initState() {
    super.initState();

    // 3 seconds total countdown (1 second per count) + 300ms flash
    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3300),
    );

    // Continuous high-frequency jitter for gate-weave and film scratches
    _jitterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    )..repeat();

    _jitterController.addListener(() {
      if (mounted) {
        setState(() {
          _gateWeaveX = (_random.nextDouble() - 0.5) * 2.0; // ±1px jitter
          _gateWeaveY = (_random.nextDouble() - 0.5) * 2.0;
        });
      }
    });

    _countdownController.addListener(() {
      final v = _countdownController.value;
      int num = 3;
      if (v >= 0.66) {
        num = 1;
      } else if (v >= 0.33) {
        num = 2;
      }
      if (num != _currentNumber) {
        setState(() {
          _currentNumber = num;
        });
      }
    });

    _countdownController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onCountdownComplete();
      }
    });

    _countdownController.forward();
  }

  @override
  void dispose() {
    _countdownController.dispose();
    _jitterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (CinemaMotion.isReducedMotion(context)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('REELHOUSE', style: CinemaText.heroTitle(color: CinemaTokens.projectorAmber)),
            const SizedBox(height: 16),
            Text('INITIALIZING PROJECTION...', style: CinemaText.monoLabel(color: CinemaTokens.ash)),
          ],
        ),
      );
    }

    return RepaintBoundary(
      child: Transform.translate(
        offset: Offset(_gateWeaveX, _gateWeaveY),
        child: AnimatedBuilder(
          animation: _countdownController,
          builder: (context, _) {
            final t = _countdownController.value;
            // End flash in final 10%
            final flashOpacity = t > 0.90 ? math.min(1.0, (t - 0.90) / 0.10) : 0.0;

            return Stack(
              fit: StackFit.expand,
              children: [
                // Film gate background with vintage grain tone
                Container(color: CinemaTokens.celluloidBlack),

                // Scrolling 35mm Sprocket Holes on Left & Right
                Positioned.fill(
                  child: CustomPaint(
                    painter: SprocketHolesPainter(progress: t * 12.0),
                  ),
                ),

                // Concentric Leader Crosshair & Rotating Sweep Arm
                Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: CustomPaint(
                      painter: LeaderCrosshairPainter(
                        sweepAngle: (t * 3.0 * 2.0 * math.pi) % (2.0 * math.pi),
                        seed: _jitterController.value,
                      ),
                      child: Center(
                        child: AnimatedScale(
                          scale: 1.0 + ((1.0 - (t * 3.0 % 1.0)) * 0.4),
                          duration: const Duration(milliseconds: 80),
                          child: Text(
                            t > 0.95 ? 'START' : '$_currentNumber',
                            style: TextStyle(
                              fontFamily: CinemaTokens.fontDisplay,
                              fontSize: t > 0.95 ? 64.0 : 120.0,
                              fontWeight: FontWeight.w400,
                              color: CinemaTokens.bone,
                              letterSpacing: 4.0,
                              shadows: [
                                Shadow(
                                  color: CinemaTokens.projectorAmber.withValues(alpha: 0.8),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Top & Bottom Cinema Framing Bars
                Positioned(
                  top: 24,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      '35MM FILM LEADER • SOUND HEAD • 24 FPS',
                      style: CinemaText.monoLabel(color: CinemaTokens.ash.withValues(alpha: 0.6)),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      'REELHOUSE MOTION PICTURE ARCHIVES',
                      style: CinemaText.monoBadge(color: CinemaTokens.projectorAmber),
                    ),
                  ),
                ),

                // Projector Lamp Flash when leader finishes
                if (flashOpacity > 0.0)
                  Positioned.fill(
                    child: Container(
                      color: Colors.white.withValues(alpha: flashOpacity),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// CustomPainter for scrolling 35mm sprocket holes along both margins
class SprocketHolesPainter extends CustomPainter {
  final double progress;

  SprocketHolesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paintHole = Paint()
      ..color = CinemaTokens.hairline.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    final paintBorder = Paint()
      ..color = CinemaTokens.hairline.withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final holeWidth = 16.0;
    final holeHeight = 24.0;
    final holeSpacing = 36.0;
    final margin = 16.0;

    final offset = (progress * holeSpacing) % holeSpacing;

    for (double y = -holeSpacing + offset; y < size.height + holeSpacing; y += holeSpacing) {
      // Left sprocket
      final leftRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(margin, y, holeWidth, holeHeight),
        const Radius.circular(3),
      );
      canvas.drawRRect(leftRect, paintHole);
      canvas.drawRRect(leftRect, paintBorder);

      // Right sprocket
      final rightRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width - margin - holeWidth, y, holeWidth, holeHeight),
        const Radius.circular(3),
      );
      canvas.drawRRect(rightRect, paintHole);
      canvas.drawRRect(rightRect, paintBorder);
    }
  }

  @override
  bool shouldRepaint(covariant SprocketHolesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// CustomPainter for universal countdown leader circles and clock sweep hand
class LeaderCrosshairPainter extends CustomPainter {
  final double sweepAngle;
  final double seed;

  LeaderCrosshairPainter({required this.sweepAngle, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.36;

    final ringPaint = Paint()
      ..color = CinemaTokens.hairline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final amberPaint = Paint()
      ..color = CinemaTokens.projectorAmber.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Outer & inner leader circles
    canvas.drawCircle(center, radius, ringPaint);
    canvas.drawCircle(center, radius * 0.72, ringPaint);
    canvas.drawCircle(center, radius * 0.44, amberPaint);

    // Crosshairs
    canvas.drawLine(
      Offset(center.dx - radius * 1.25, center.dy),
      Offset(center.dx + radius * 1.25, center.dy),
      ringPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 1.25),
      Offset(center.dx, center.dy + radius * 1.25),
      ringPaint,
    );

    // Sweep Sector (clock hand rotating around circle)
    final sweepPaint = Paint()
      ..color = CinemaTokens.projectorAmber.withValues(alpha: 0.18)
      ..style = PaintingStyle.fill;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      true,
      sweepPaint,
    );

    // Rotating clock arm line
    final armPaint = Paint()
      ..color = CinemaTokens.projectorAmber
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.square;

    final handAngle = -math.pi / 2 + sweepAngle;
    final handEnd = Offset(
      center.dx + radius * math.cos(handAngle),
      center.dy + radius * math.sin(handAngle),
    );
    canvas.drawLine(center, handEnd, armPaint);

    // Dynamic random celluloid scratches
    final scratchPaint = Paint()
      ..color = CinemaTokens.bone.withValues(alpha: 0.25)
      ..strokeWidth = 1.0;

    final math.Random rnd = math.Random((seed * 1000).toInt());
    for (int i = 0; i < 3; i++) {
      final sx = rnd.nextDouble() * size.width;
      canvas.drawLine(Offset(sx, 0), Offset(sx + (rnd.nextDouble() - 0.5) * 8, size.height), scratchPaint);
    }
  }

  @override
  bool shouldRepaint(covariant LeaderCrosshairPainter oldDelegate) {
    return oldDelegate.sweepAngle != sweepAngle || oldDelegate.seed != seed;
  }
}
