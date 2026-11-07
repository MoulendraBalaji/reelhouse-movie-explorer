// ANIMATION: explicit (Hero + custom flightShuttleBuilder + Sprocket Border Inset + In-flight Tilt)
// HeroFlightShuttle: Custom flight shuttle builder where the movie poster tilts slightly,
// draws sprocket film borders in flight, and lands smoothly onto the detail screen.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../theme/motion.dart';
import '../film_strip_border.dart';

Widget cinemaFlightShuttleBuilder(
  BuildContext flightContext,
  Animation<double> animation,
  HeroFlightDirection flightDirection,
  BuildContext fromHeroContext,
  BuildContext toHeroContext,
) {
  if (CinemaMotion.isReducedMotion(flightContext)) {
    return toHeroContext.widget;
  }

  final curvedAnimation = CurvedAnimation(
    parent: animation,
    curve: CinemaMotion.projectorCurve,
  );

  return AnimatedBuilder(
    animation: curvedAnimation,
    builder: (context, child) {
      // Slight mid-flight tilt (-3 degrees to 0 degrees)
      final midFlightFactor = math.sin(curvedAnimation.value * math.pi);
      final tilt = -0.05 * midFlightFactor;
      final borderProgress = curvedAnimation.value;

      return Transform.rotate(
        angle: tilt,
        alignment: Alignment.center,
        child: Material(
          color: Colors.transparent,
          elevation: 12.0 * midFlightFactor,
          shadowColor: CinemaTokens.projectorAmber.withValues(alpha: 0.4),
          child: FilmStripBorder(
            sprocketCount: 8,
            borderOpacity: borderProgress.clamp(0.0, 1.0),
            child: toHeroContext.widget,
          ),
        ),
      );
    },
  );
}
