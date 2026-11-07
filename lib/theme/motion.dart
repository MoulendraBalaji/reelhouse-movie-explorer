import 'package:flutter/widgets.dart';

/// Custom ProjectorCurve: fast mechanical start, soft cinematic settle with subtle overshoot.
class ProjectorCurve extends Curve {
  const ProjectorCurve();

  @override
  double transformInternal(double t) {
    // Modified back-out curve with tiny mechanical overshoot (overshoot factor 1.15)
    final double s = 1.15;
    final double tMinus1 = t - 1.0;
    return tMinus1 * tMinus1 * ((s + 1.0) * tMinus1 + s) + 1.0;
  }
}

/// Motion system durations, curves, and spring descriptions for physical projection hardware feel.
class CinemaMotion {
  CinemaMotion._();

  // Durations
  static const Duration instant = Duration(milliseconds: 120);
  static const Duration quick = Duration(milliseconds: 220);
  static const Duration base = Duration(milliseconds: 380);
  static const Duration slow = Duration(milliseconds: 640);
  static const Duration cinematic = Duration(milliseconds: 1100);

  // Curves
  static const Curve entranceCurve = Curves.easeOutExpo;
  static const Curve transitionCurve = Curves.easeInOutCubicEmphasized;
  static const Curve projectorCurve = ProjectorCurve();
  static const Curve shutterCloseCurve = Curves.easeInCubic;
  static const Curve stampSlamCurve = Curves.elasticOut;

  // Spring Description for physical interactions (magnetic button, dismiss spring, tilt return)
  static const SpringDescription physicalSpring = SpringDescription(
    mass: 1.0,
    stiffness: 180.0,
    damping: 18.0,
  );

  /// Helper to get an adjusted duration taking into account system and in-app reduced motion.
  static Duration getDuration(BuildContext context, Duration original) {
    if (isReducedMotion(context)) {
      return Duration.zero;
    }
    return original;
  }

  /// Checks if reduced motion is requested either via system MediaQuery or via MotionScope.
  static bool isReducedMotion(BuildContext context) {
    final mediaQuery = MediaQuery.maybeOf(context);
    final systemDisabled = mediaQuery?.disableAnimations ?? false;
    final scope = MotionScope.maybeOf(context);
    final appDisabled = scope?.reduceMotion ?? false;
    return systemDisabled || appDisabled;
  }
}

/// InheritedWidget that provides the app-level "Reduce motion" preference down the widget tree.
class MotionScope extends InheritedWidget {
  final bool reduceMotion;

  const MotionScope({
    super.key,
    required this.reduceMotion,
    required super.child,
  });

  static MotionScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<MotionScope>();
  }

  static bool of(BuildContext context) {
    return maybeOf(context)?.reduceMotion ?? false;
  }

  @override
  bool updateShouldNotify(MotionScope oldWidget) {
    return reduceMotion != oldWidget.reduceMotion;
  }
}
