// ANIMATION: explicit (AnimationController + Moving Mask Bar Sweep + Wipe Reveal)
// NumberedHeadingMask: Oversized Bebas headings reveal via an amber bar sweeping across then wiping away.

import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../theme/motion.dart';
import '../../theme/text_styles.dart';

class NumberedHeadingMask extends StatefulWidget {
  final String number;
  final String title;
  final Duration delay;

  const NumberedHeadingMask({
    super.key,
    required this.number,
    required this.title,
    this.delay = Duration.zero,
  });

  @override
  State<NumberedHeadingMask> createState() => _NumberedHeadingMaskState();
}

class _NumberedHeadingMaskState extends State<NumberedHeadingMask>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _sweepIn;
  late final Animation<double> _wipeOut;
  late final Animation<double> _textOpacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: CinemaMotion.slow,
    );

    // Phase 1: Amber bar sweeps from 0% to 100% width (0.0 to 0.45)
    _sweepIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeInOutExpo),
      ),
    );

    // Phase 2: Text becomes visible (0.40 to 0.50)
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.40, 0.55, curve: Curves.easeIn),
      ),
    );

    // Phase 3: Amber bar collapses from left to right (0.45 to 0.95)
    _wipeOut = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.95, curve: Curves.easeInOutExpo),
      ),
    );

    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (CinemaMotion.isReducedMotion(context)) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.number, style: CinemaText.sectionTitle(color: CinemaTokens.projectorAmber)),
          const SizedBox(width: 8),
          Text('—', style: CinemaText.sectionTitle(color: CinemaTokens.ash)),
          const SizedBox(width: 8),
          Text(widget.title, style: CinemaText.sectionTitle(color: CinemaTokens.bone)),
        ],
      );
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Revealed Header Text
              Opacity(
                opacity: _textOpacity.value,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(widget.number, style: CinemaText.sectionTitle(color: CinemaTokens.projectorAmber)),
                    const SizedBox(width: 8),
                    Text('—', style: CinemaText.sectionTitle(color: CinemaTokens.ash)),
                    const SizedBox(width: 8),
                    Text(widget.title, style: CinemaText.sectionTitle(color: CinemaTokens.bone)),
                  ],
                ),
              ),

              // Sweeping & Wiping Amber Mask Bar
              if (_wipeOut.value < 0.99)
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final left = constraints.maxWidth * _wipeOut.value;
                      final width = (constraints.maxWidth * _sweepIn.value) - left;

                      if (width <= 0) return const SizedBox.shrink();

                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(left: left.clamp(0.0, constraints.maxWidth)),
                          width: width.clamp(0.0, constraints.maxWidth),
                          color: CinemaTokens.projectorAmber,
                        ),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
