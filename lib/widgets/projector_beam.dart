// SIGNATURE WIDGET: ProjectorBeam
// Amber projection light cone gradient behind hero banners and featured movies.

import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class ProjectorBeam extends StatelessWidget {
  final Widget? child;
  final double height;
  final double opacity;

  const ProjectorBeam({
    super.key,
    this.child,
    this.height = 360.0,
    this.opacity = 0.20,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: StaticProjectorBeamPainter(opacity: opacity),
          ),
        ),
        ?child,
      ],
    );
  }
}

class StaticProjectorBeamPainter extends CustomPainter {
  final double opacity;

  StaticProjectorBeamPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final Path beamPath = Path();
    final apex = Offset(size.width * 0.70, 0); // Originating from projection aperture

    beamPath.moveTo(apex.dx - 30, apex.dy);
    beamPath.lineTo(size.width * 0.05, size.height);
    beamPath.lineTo(size.width * 0.95, size.height);
    beamPath.lineTo(apex.dx + 30, apex.dy);
    beamPath.close();

    final beamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          CinemaTokens.projectorAmber.withValues(alpha: opacity * 1.6),
          CinemaTokens.projectorAmber.withValues(alpha: opacity * 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.60, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(beamPath, beamPaint);
  }

  @override
  bool shouldRepaint(covariant StaticProjectorBeamPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}
