import 'package:flutter/material.dart';

/// Design tokens for REELHOUSE cinema aesthetic.
/// Old single-screen projection booth theme: sharp corners, hairline borders, celluloid tones.
class CinemaTokens {
  CinemaTokens._();

  // Core Palette (Midnight / Dark)
  static const Color celluloidBlack = Color(0xFF0C0A09); // Deep Celluloid Noir Background
  static const Color boothBrown = Color(0xFF161310);     // Warm Booth Charcoal Surface
  static const Color boothBrownElevated = Color(0xFF221C16); // Elevated Card Surface
  static const Color projectorAmber = Color(0xFFF5A623);  // Warm Projector Gold Primary Accent
  static const Color projectorAmberDim = Color(0x66F5A623);
  static const Color ticketRed = Color(0xFFE63946);        // Cinema Crimson Secondary
  static const Color bone = Color(0xFFF5EFE6);             // Crisp Bone White Text
  static const Color ash = Color(0xFF9E9282);              // Warm Ash Muted Text
  static const Color hairline = Color(0xFF2E271F);         // Subtle Framing Hairline Border

  // Matinee (Light Mode) Palette - Archival Gallery Aesthetic
  static const Color matineeBg = Color(0xFFF8F6F1);        // Warm Gallery Canvas Background
  static const Color matineeSurface = Color(0xFFFFFFFF);   // Crisp Paper White Card Surface
  static const Color matineeSurfaceElevated = Color(0xFFF0EAE1); // Warm Alabaster Card Detail
  static const Color matineeAmber = Color(0xFFD97706);     // High-contrast Amber Ochre
  static const Color matineeRed = Color(0xFFDC2626);       // Cinema Red for Light Mode
  static const Color matineeInk = Color(0xFF181512);       // Deep Print Noir Text
  static const Color matineeMuted = Color(0xFF6B6255);     // Slate Charcoal Muted Text
  static const Color matineeHairline = Color(0xFFE2DACD);  // Delicate Paper Hairline Border

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
