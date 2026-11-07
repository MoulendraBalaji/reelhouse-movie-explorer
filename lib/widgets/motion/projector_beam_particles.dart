// ANIMATION: explicit (CustomPainter + single Ticker + RepaintBoundary + Particle Simulation)
// ProjectorBeamParticles: Atmospheric light cone behind the hero with slow lamp flicker
// and 60 floating dust motes drifting through the amber beam.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../theme/motion.dart';
import '../../core/responsive.dart';

class DustParticle {
  double x;
  double y;
  double vx;
  double vy;
  double radius;
  double alpha;
  double phase;

  DustParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.radius,
    required this.alpha,
    required this.phase,
  });

  void update(Size size, double dt) {
    x += vx * dt;
    y += vy * dt;
    phase += dt * 2.0;

    // Wrap around screen bounds
    if (x < 0) x = size.width;
    if (x > size.width) x = 0;
    if (y < 0) y = size.height;
    if (y > size.height) y = 0;
  }
}

class ProjectorBeamParticles extends StatefulWidget {
  final Widget? child;
  final double height;

  const ProjectorBeamParticles({
    super.key,
    this.child,
    this.height = 480.0,
  });

  @override
  State<ProjectorBeamParticles> createState() => _ProjectorBeamParticlesState();
}

class _ProjectorBeamParticlesState extends State<ProjectorBeamParticles>
    with SingleTickerProviderStateMixin {
  late final AnimationController _tickerController;
  final List<DustParticle> _particles = [];
  final math.Random _rnd = math.Random();
  DateTime _lastTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tickerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _initParticles(50);

    _tickerController.addListener(() {
      final now = DateTime.now();
      final dt = now.difference(_lastTime).inMilliseconds / 1000.0;
      _lastTime = now;

      // Update particle positions
      final size = Size(1280, widget.height);
      for (final p in _particles) {
        p.update(size, dt.clamp(0.0, 0.1));
      }
    });
  }

  void _initParticles(int count) {
    _particles.clear();
    for (int i = 0; i < count; i++) {
      _particles.add(
        DustParticle(
          x: _rnd.nextDouble() * 1280,
          y: _rnd.nextDouble() * widget.height,
          vx: (_rnd.nextDouble() - 0.4) * 14.0, // gentle rightward drift
          vy: (_rnd.nextDouble() - 0.2) * 10.0, // gentle downward drift
          radius: 1.0 + _rnd.nextDouble() * 2.0,
          alpha: 0.2 + _rnd.nextDouble() * 0.5,
          phase: _rnd.nextDouble() * 2 * math.pi,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tickerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (CinemaMotion.isReducedMotion(context)) {
      return SizedBox(
        height: widget.height,
        child: widget.child,
      );
    }

    final isMobile = Responsive.isMobile(context);
    final activeParticleCount = isMobile ? 25 : 55;

    return RepaintBoundary(
      child: Stack(
        children: [
          // Projector Beam Cone & Floating Motes CustomPainter
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _tickerController,
              builder: (context, _) {
                final t = _tickerController.value * 2 * math.pi;
                // Low frequency noise on lamp opacity (lamp flicker)
                final flicker = 0.14 + (0.04 * math.sin(t * 3.0)) + (0.02 * math.cos(t * 7.5));

                return CustomPaint(
                  painter: BeamParticlesPainter(
                    flickerAlpha: flicker.clamp(0.08, 0.22),
                    particles: _particles.take(activeParticleCount).toList(),
                  ),
                );
              },
            ),
          ),
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}

class BeamParticlesPainter extends CustomPainter {
  final double flickerAlpha;
  final List<DustParticle> particles;

  BeamParticlesPainter({
    required this.flickerAlpha,
    required this.particles,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Amber Projector Light Cone
    final Path beamPath = Path();
    final apex = Offset(size.width * 0.72, 0); // Projector booth lens position
    beamPath.moveTo(apex.dx - 40, apex.dy);
    beamPath.lineTo(size.width * 0.1, size.height);
    beamPath.lineTo(size.width * 0.95, size.height);
    beamPath.lineTo(apex.dx + 40, apex.dy);
    beamPath.close();

    final beamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          CinemaTokens.projectorAmber.withValues(alpha: flickerAlpha * 1.5),
          CinemaTokens.projectorAmber.withValues(alpha: flickerAlpha * 0.6),
          Colors.transparent,
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(beamPath, beamPaint);

    // 2. Draw Illuminated Dust Motes drifting in the cone
    final motePaint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      // Glow pulse with particle phase
      final pulse = (0.7 + 0.3 * math.sin(p.phase)).clamp(0.0, 1.0);
      final currentAlpha = (p.alpha * pulse * flickerAlpha * 4.0).clamp(0.0, 0.85);

      motePaint.color = CinemaTokens.projectorAmber.withValues(alpha: currentAlpha);
      canvas.drawCircle(Offset(p.x % size.width, p.y % size.height), p.radius, motePaint);
    }
  }

  @override
  bool shouldRepaint(covariant BeamParticlesPainter oldDelegate) {
    return true; // Continuously repainting on ticker
  }
}
