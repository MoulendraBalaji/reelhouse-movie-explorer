import 'package:flutter/material.dart';
import 'tokens.dart';

/// REELHOUSE Cinema Typography:
/// Display = Bebas Neue (huge, tight, uppercase)
/// Body = Fraunces (refined editorial serif)
/// Meta/Code = Space Mono (technical film spools, year, time, rating)
class CinemaText {
  CinemaText._();

  // Display Headings (Bebas Neue)
  static TextStyle heroTitle({Color color = CinemaTokens.bone}) => TextStyle(
        fontFamily: CinemaTokens.fontDisplay,
        fontSize: 56.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 2.5,
        height: 0.95,
        color: color,
      );

  static TextStyle sectionTitle({Color color = CinemaTokens.bone}) => TextStyle(
        fontFamily: CinemaTokens.fontDisplay,
        fontSize: 36.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.5,
        height: 1.0,
        color: color,
      );

  static TextStyle cardTitle({Color color = CinemaTokens.bone}) => TextStyle(
        fontFamily: CinemaTokens.fontDisplay,
        fontSize: 24.0,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.0,
        height: 1.05,
        color: color,
      );

  static TextStyle marqueeText({Color color = CinemaTokens.projectorAmber}) => TextStyle(
        fontFamily: CinemaTokens.fontDisplay,
        fontSize: 22.0,
        letterSpacing: 3.0,
        fontWeight: FontWeight.w400,
        color: color,
      );

  // Serif Body (Fraunces)
  static TextStyle bodyLarge({Color color = CinemaTokens.bone}) => TextStyle(
        fontFamily: CinemaTokens.fontSerif,
        fontSize: 16.0,
        height: 1.6,
        color: color,
      );

  static TextStyle bodyMedium({Color color = CinemaTokens.bone}) => TextStyle(
        fontFamily: CinemaTokens.fontSerif,
        fontSize: 14.0,
        height: 1.5,
        color: color,
      );

  static TextStyle bodySmall({Color color = CinemaTokens.ash}) => TextStyle(
        fontFamily: CinemaTokens.fontSerif,
        fontSize: 12.0,
        height: 1.4,
        color: color,
      );

  static TextStyle quote({Color color = CinemaTokens.bone}) => TextStyle(
        fontFamily: CinemaTokens.fontSerif,
        fontSize: 18.0,
        fontStyle: FontStyle.italic,
        height: 1.4,
        color: color,
      );

  // Monospace Metadata (Space Mono)
  static TextStyle monoLabel({Color color = CinemaTokens.ash}) => TextStyle(
        fontFamily: CinemaTokens.fontMono,
        fontSize: 11.0,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle monoMeta({Color color = CinemaTokens.bone}) => TextStyle(
        fontFamily: CinemaTokens.fontMono,
        fontSize: 13.0,
        letterSpacing: 0.8,
        color: color,
      );

  static TextStyle monoBadge({Color color = CinemaTokens.celluloidBlack}) => TextStyle(
        fontFamily: CinemaTokens.fontMono,
        fontSize: 10.0,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: color,
      );

  static TextStyle odometerNumber({Color color = CinemaTokens.projectorAmber, double size = 32.0}) => TextStyle(
        fontFamily: CinemaTokens.fontMono,
        fontSize: size,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.0,
        color: color,
      );
}
