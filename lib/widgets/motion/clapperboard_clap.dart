// ANIMATION: explicit (AnimationController + elasticOut Rotation + Staggered Spring Scale)
// ClapperboardClap: Authentic cinema clapperboard arm snapping shut on review submission
// and interactive rating input with staggered spring-scaling reels.

import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../theme/motion.dart';
import '../../theme/text_styles.dart';

class ClapperboardClap extends StatefulWidget {
  final VoidCallback? onClapFinished;
  final bool isSubmitting;
  final Widget? successChild;

  const ClapperboardClap({
    super.key,
    this.onClapFinished,
    this.isSubmitting = false,
    this.successChild,
  });

  @override
  State<ClapperboardClap> createState() => ClapperboardClapState();
}

class ClapperboardClapState extends State<ClapperboardClap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _armController;
  late final Animation<double> _armRotation;
  bool _clapped = false;

  @override
  void initState() {
    super.initState();
    _armController = AnimationController(
      vsync: this,
      duration: CinemaMotion.base,
    );

    // Clapper stick snaps from open (-32 degrees) to shut (0 degrees)
    _armRotation = Tween<double>(begin: -0.55, end: 0.0).animate(
      CurvedAnimation(
        parent: _armController,
        curve: Curves.elasticOut,
      ),
    );

    _armController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _clapped = true;
        });
        widget.onClapFinished?.call();
      }
    });
  }

  void snapClapper() {
    setState(() => _clapped = false);
    _armController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _armController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (CinemaMotion.isReducedMotion(context)) {
      return widget.successChild ?? const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 220,
            height: 120,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Bottom Slated Clapper Body
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      color: CinemaTokens.boothBrown,
                      border: Border.all(color: CinemaTokens.hairline),
                      borderRadius: CinemaTokens.borderSharp,
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('SCENE: 01', style: CinemaText.monoBadge(color: CinemaTokens.ash)),
                            Text('TAKE: 04', style: CinemaText.monoBadge(color: CinemaTokens.projectorAmber)),
                          ],
                        ),
                        const Spacer(),
                        Center(
                          child: Text(
                            _clapped ? 'TAKE RECORDED!' : 'ACTION',
                            style: TextStyle(
                              fontFamily: CinemaTokens.fontDisplay,
                              fontSize: 20,
                              letterSpacing: 2,
                              color: _clapped ? CinemaTokens.projectorAmber : CinemaTokens.bone,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Top Clapper Stick (Animated Hinge Rotation)
                Positioned(
                  top: 10,
                  left: 0,
                  right: 0,
                  height: 28,
                  child: AnimatedBuilder(
                    animation: _armController,
                    builder: (context, _) {
                      return Transform.rotate(
                        angle: _armRotation.value,
                        alignment: Alignment.bottomLeft,
                        child: CustomPaint(
                          painter: ClapperStickPainter(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_clapped && widget.successChild != null) ...[
            const SizedBox(height: 12),
            widget.successChild!,
          ],
        ],
      ),
    );
  }
}

/// CustomPainter for the classic diagonal zebra stripe clapperboard stick
class ClapperStickPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = CinemaTokens.celluloidBlack;
    final stripePaint = Paint()..color = CinemaTokens.bone;
    final borderPaint = Paint()
      ..color = CinemaTokens.hairline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final stripeWidth = 24.0;
    for (double x = -stripeWidth; x < size.width + stripeWidth; x += stripeWidth * 2) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + stripeWidth, 0)
        ..lineTo(x + stripeWidth * 1.6, 0)
        ..lineTo(x + stripeWidth * 0.6, size.height)
        ..close();
      canvas.drawPath(path, stripePaint);
    }

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

    // Hinge screw on the left
    final hingePaint = Paint()..color = CinemaTokens.projectorAmber;
    canvas.drawCircle(Offset(8, size.height - 4), 3.5, hingePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
