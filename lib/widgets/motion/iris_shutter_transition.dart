// ANIMATION: explicit (AnimationController + CurvedAnimation + CustomClipper)
// IrisShutterTransition: physical camera iris shutter closing to black and opening to incoming screen with light leak flash.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../theme/motion.dart';

class IrisClipper extends CustomClipper<Path> {
  final double progress; // 0.0 = completely closed (black), 1.0 = completely open
  final Offset? centerOffset;

  IrisClipper({required this.progress, this.centerOffset});

  @override
  Path getClip(Size size) {
    final Path path = Path();
    if (progress >= 1.0) {
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      return path;
    }
    if (progress <= 0.0) {
      return path; // Empty path -> totally clipped
    }

    final center = centerOffset ?? Offset(size.width / 2, size.height / 2);
    final maxRadius = math.sqrt(size.width * size.width + size.height * size.height) / 2 * 1.2;
    final currentRadius = maxRadius * progress;

    path.addOval(Rect.fromCircle(center: center, radius: currentRadius));
    return path;
  }

  @override
  bool shouldReclip(covariant IrisClipper oldClipper) {
    return oldClipper.progress != progress || oldClipper.centerOffset != centerOffset;
  }
}

class IrisShutterTransition extends StatefulWidget {
  final Widget child;
  final VoidCallback? onComplete;
  final bool openOnStart;
  final Duration duration;

  const IrisShutterTransition({
    super.key,
    required this.child,
    this.onComplete,
    this.openOnStart = true,
    this.duration = CinemaMotion.slow,
  });

  @override
  State<IrisShutterTransition> createState() => _IrisShutterTransitionState();
}

class _IrisShutterTransitionState extends State<IrisShutterTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _irisAnimation;
  late final Animation<double> _lightLeakAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _irisAnimation = CurvedAnimation(
      parent: _controller,
      curve: CinemaMotion.projectorCurve,
    );

    // Amber light-leak flash right when the iris hits ~70% open
    _lightLeakAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.6), weight: 30),
      TweenSequenceItem(tween: Tween<double>(begin: 0.6, end: 0.0), weight: 70),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.95, curve: Curves.easeOut),
      ),
    );

    if (widget.openOnStart) {
      _controller.forward().then((_) {
        if (mounted && widget.onComplete != null) {
          widget.onComplete!();
        }
      });
    } else {
      _controller.value = 1.0;
    }
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
          return Stack(
            fit: StackFit.expand,
            children: [
              Container(color: CinemaTokens.celluloidBlack),
              ClipPath(
                clipper: IrisClipper(progress: _irisAnimation.value),
                child: child,
              ),
              // Amber projector light leak flash
              if (_lightLeakAnimation.value > 0.01)
                IgnorePointer(
                  child: Container(
                    color: CinemaTokens.projectorAmber.withValues(alpha: _lightLeakAnimation.value * 0.4),
                  ),
                ),
            ],
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Helper PageRouteBuilder implementing Iris Shutter transition between routes
class IrisPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  IrisPageRoute({required this.page, super.settings})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: CinemaMotion.slow,
          reverseTransitionDuration: CinemaMotion.base,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            if (CinemaMotion.isReducedMotion(context)) {
              return FadeTransition(opacity: animation, child: child);
            }
            final curved = CurvedAnimation(
              parent: animation,
              curve: CinemaMotion.projectorCurve,
            );
            return Stack(
              fit: StackFit.expand,
              children: [
                Container(color: CinemaTokens.celluloidBlack),
                ClipPath(
                  clipper: IrisClipper(progress: curved.value),
                  child: child,
                ),
                // Flash overlay
                FadeTransition(
                  opacity: TweenSequence<double>([
                    TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.5), weight: 40),
                    TweenSequenceItem(tween: Tween(begin: 0.5, end: 0.0), weight: 60),
                  ]).animate(CurvedAnimation(
                    parent: animation,
                    curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
                  )),
                  child: Container(color: CinemaTokens.projectorAmber.withValues(alpha: 0.35)),
                ),
              ],
            );
          },
        );
}
