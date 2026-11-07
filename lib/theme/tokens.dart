import 'package:flutter/material.dart';

/// Design tokens for REELHOUSE cinema aesthetic.
/// Old single-screen projection booth theme: sharp corners, hairline borders, celluloid tones.
class CinemaTokens {
  CinemaTokens._();

  // Core Palette
  static const Color celluloidBlack = Color(0xFF0E0C0A); // Background (Dark)
  static const Color boothBrown = Color(0xFF1A1611);     // Surface / Card (Dark)
  static const Color boothBrownElevated = Color(0xFF241F18); // Elevated surface
  static const Color projectorAmber = Color(0xFFFFB020);  // Primary Accent / Glow
  static const Color projectorAmberDim = Color(0x66FFB020);
  static const Color ticketRed = Color(0xFFD7263D);        // Secondary / Favorites / Badges
  static const Color bone = Color(0xFFF2E8D5);             // Text (Dark) / Background (Light)
  static const Color ash = Color(0xFF8A8070);              // Muted Text
  static const Color hairline = Color(0xFF3A332A);         // Hairline borders (Dark)

  // Matinee (Light Mode) Palette
  static const Color matineeBg = Color(0xFFF2E8D5);        // Warm paper bg
  static const Color matineeSurface = Color(0xFFE8DEC8);   // Warm paper card
  static const Color matineeInk = Color(0xFF1A1611);       // Dark ink text
  static const Color matineeMuted = Color(0xFF6E6455);     // Muted ink
  static const Color matineeHairline = Color(0xFFD1C4AD);  // Hairline borders (Light)

  // Typography Families
  static const String fontDisplay = 'Bebas Neue';
  static const String fontSerif = 'Fraunces';
  static const String fontMono = 'Space Mono';

  // Shape Language: Sharp corners (0 - 2px)
  static const double radiusNone = 0.0;
  static const double radiusSharp = 2.0;
  static const Radius cornerSharp = Radius.circular(radiusSharp);
  static const BorderRadius borderSharp = BorderRadius.all(cornerSharp);

  // Borders: Hairline 1px
  static const double borderWidth = 1.0;
  static const BorderSide borderSideDark = BorderSide(color: hairline, width: borderWidth);
  static const BorderSide borderSideLight = BorderSide(color: matineeHairline, width: borderWidth);
  static const BorderSide borderSideAmber = BorderSide(color: projectorAmber, width: borderWidth);
  static const BorderSide borderSideRed = BorderSide(color: ticketRed, width: borderWidth);

  // Spacing Scale
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;
  static const double space64 = 64.0;

  // Max content width for desktop layout
  static const double maxContentWidth = 1280.0;
}
