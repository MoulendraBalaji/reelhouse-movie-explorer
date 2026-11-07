// ANIMATION: explicit (single AnimationController + Interval Curves + Screen Shake + Elastic Bounce)
// TicketTearAnimation: Cinema ticket stub splits along perforation, slides away, and slams in a red "SAVED" rubber stamp.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../theme/app_theme.dart';
import '../../theme/motion.dart';
import '../../theme/text_styles.dart';

class TicketTearAnimation extends StatefulWidget {
  final bool isSaved;
  final VoidCallback onToggle;
  final String title;
  final String dateInfo;

  const TicketTearAnimation({
    super.key,
    required this.isSaved,
    required this.onToggle,
    this.title = 'ADMIT ONE • 35MM REEL',
    this.dateInfo = 'REELHOUSE ARCHIVE',
  });

  @override
  State<TicketTearAnimation> createState() => _TicketTearAnimationState();
}

class _TicketTearAnimationState extends State<TicketTearAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  // Sequenced Intervals on single AnimationController
  late final Animation<double> _tearOffset;
  late final Animation<double> _tearRotation;
  late final Animation<double> _stubOpacity;
  late final Animation<double> _screenShake;
  late final Animation<double> _stampScale;
  late final Animation<double> _stampOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: CinemaMotion.slow,
    );

    // 1. Perforation tear & slide: 0.0 -> 0.45
    _tearOffset = Tween<double>(begin: 0.0, end: 40.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    _tearRotation = Tween<double>(begin: 0.0, end: 0.22).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeIn),
      ),
    );

    _stubOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.20, 0.45, curve: Curves.easeOut),
      ),
    );

    // 2. Screen shake: 0.40 -> 0.50
    _screenShake = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 2.5), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 2.5, end: -2.5), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -2.5, end: 1.5), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 1.5, end: 0.0), weight: 25),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.52, curve: Curves.linear),
      ),
    );

    // 3. Red "SAVED" rubber stamp slam: 0.45 -> 0.90
    _stampScale = Tween<double>(begin: 1.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.85, curve: Curves.elasticOut),
      ),
    );

    _stampOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.60, curve: Curves.easeIn),
      ),
    );

    if (widget.isSaved) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant TicketTearAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSaved != oldWidget.isSaved) {
      if (widget.isSaved) {
        _controller.forward(from: 0.0);
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReduced = CinemaMotion.isReducedMotion(context);
    final colors = context.cinemaColors;

    if (isReduced) {
      return OutlinedButton.icon(
        onPressed: widget.onToggle,
        icon: Icon(
          widget.isSaved ? Icons.bookmark : Icons.bookmark_border,
          color: widget.isSaved ? colors.accentRed : colors.accentAmber,
        ),
        label: Text(widget.isSaved ? 'SAVED TO WATCHLIST' : 'ADD TO WATCHLIST'),
      );
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Transform.translate(
            offset: Offset(_screenShake.value, 0),
            child: InkWell(
              onTap: widget.onToggle,
              child: Container(
                height: 80,
                constraints: const BoxConstraints(maxWidth: 360),
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border.all(
                    color: widget.isSaved
                        ? colors.accentRed
                        : colors.borderHairline,
                    width: 1.0,
                  ),
                  borderRadius: CinemaTokens.borderSharp,
                ),
                child: Stack(
                  children: [
                    // Main Ticket Body
                    Positioned.fill(
                      right: 90,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: CinemaText.monoLabel(color: colors.accentAmber),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.isSaved
                                  ? 'SAVED IN PATRON VAULT'
                                  : 'TEAR TICKET TO ADD TO WATCHLIST',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: CinemaText.bodySmall(color: colors.textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Perforated Dashed Tear Line
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: 90,
                      child: CustomPaint(
                        painter: DashedTearLinePainter(color: colors.borderHairline),
                      ),
                    ),

                    // Stub Half (Splits, Rotates and Slides away)
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: 0,
                      width: 90,
                      child: Transform.translate(
                        offset: Offset(_tearOffset.value, 0),
                        child: Transform.rotate(
                          angle: _tearRotation.value,
                          alignment: Alignment.bottomRight,
                          child: Opacity(
                            opacity: _stubOpacity.value.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: colors.surfaceElevated,
                                border: Border(left: BorderSide(color: colors.borderHairline)),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.confirmation_number_outlined,
                                    size: 18,
                                    color: colors.accentAmber,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'TEAR STUB',
                                    style: CinemaText.monoBadge(color: colors.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Red "SAVED" Rubber Stamp Slamming In
                    if (_stampOpacity.value > 0.01)
                      Positioned(
                        right: 18,
                        top: 14,
                        child: Transform.rotate(
                          angle: -12.0 * math.pi / 180.0,
                          child: Transform.scale(
                            scale: _stampScale.value,
                            child: Opacity(
                              opacity: _stampOpacity.value.clamp(0.0, 1.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: CinemaTokens.ticketRed,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                  color: CinemaTokens.ticketRed.withValues(alpha: 0.15),
                                ),
                                child: Text(
                                  'SAVED',
                                  style: TextStyle(
                                    fontFamily: CinemaTokens.fontDisplay,
                                    fontSize: 22.0,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.0,
                                    color: CinemaTokens.ticketRed,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
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

class DashedTearLinePainter extends CustomPainter {
  final Color color;

  DashedTearLinePainter({this.color = CinemaTokens.hairline});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5;

    const dashHeight = 4.0;
    const dashSpace = 4.0;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant DashedTearLinePainter oldDelegate) => oldDelegate.color != color;
}
