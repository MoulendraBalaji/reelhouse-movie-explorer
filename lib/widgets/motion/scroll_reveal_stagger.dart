// ANIMATION: explicit (AnimationController + CurvedAnimation + Staggered Delay + Clip Wipe)
// ScrollRevealStagger: Grid and section items reveal with translateY 32->0, opacity fade,
// and 60ms stagger per index.

import 'package:flutter/material.dart';
import '../../theme/motion.dart';
import '../../theme/tokens.dart';

class ScrollRevealStagger extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration staggerDelay;
  final Duration duration;
  final double translateY;

  const ScrollRevealStagger({
    super.key,
    required this.child,
    this.index = 0,
    this.staggerDelay = const Duration(milliseconds: 60),
    this.duration = CinemaMotion.base,
    this.translateY = 32.0,
  });

  @override
  State<ScrollRevealStagger> createState() => _ScrollRevealStaggerState();
}

class _ScrollRevealStaggerState extends State<ScrollRevealStagger>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _clipWipeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _slideAnimation = Tween<double>(begin: widget.translateY, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: CinemaMotion.entranceCurve,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.75, curve: Curves.easeIn),
      ),
    );

    _clipWipeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    // Staggered launch
    final delay = widget.staggerDelay * widget.index;
    Future.delayed(delay, () {
      if (mounted) {
        _controller.forward();
      }
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
      return widget.child;
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: ClipRect(
                clipper: HorizontalWipeClipper(progress: _clipWipeAnimation.value),
                child: child,
              ),
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}

class HorizontalWipeClipper extends CustomClipper<Rect> {
  final double progress;

  HorizontalWipeClipper({required this.progress});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, size.width, size.height * progress.clamp(0.0, 1.0));
  }

  @override
  bool shouldReclip(covariant HorizontalWipeClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}

/// Underline rule that draws left-to-right when revealing
class AnimatedUnderlineRule extends StatefulWidget {
  final Duration delay;

  const AnimatedUnderlineRule({
    super.key,
    this.delay = Duration.zero,
  });

  @override
  State<AnimatedUnderlineRule> createState() => _AnimatedUnderlineRuleState();
}

class _AnimatedUnderlineRuleState extends State<AnimatedUnderlineRule>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _widthFactor;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: CinemaMotion.slow,
    );
    _widthFactor = CurvedAnimation(parent: _controller, curve: Curves.easeOutExpo);

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
      return const Divider(height: 1, color: CinemaTokens.hairline);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Align(
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: _widthFactor.value.clamp(0.0, 1.0),
            child: Container(
              height: 1.0,
              color: CinemaTokens.projectorAmber.withValues(alpha: 0.6),
            ),
          ),
        );
      },
    );
  }
}
