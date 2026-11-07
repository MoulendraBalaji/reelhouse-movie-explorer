import 'package:flutter/material.dart';
import 'tokens.dart';
import 'text_styles.dart';

/// ThemeExtension to expose cinema-specific color tokens cleanly across widgets.
class CinemaColors extends ThemeExtension<CinemaColors> {
  final Color bg;
  final Color surface;
  final Color surfaceElevated;
  final Color accentAmber;
  final Color accentRed;
  final Color textPrimary;
  final Color textMuted;
  final Color borderHairline;
  final bool isDark;

  const CinemaColors({
    required this.bg,
    required this.surface,
    required this.surfaceElevated,
    required this.accentAmber,
    required this.accentRed,
    required this.textPrimary,
    required this.textMuted,
    required this.borderHairline,
    required this.isDark,
  });

  @override
  CinemaColors copyWith({
    Color? bg,
    Color? surface,
    Color? surfaceElevated,
    Color? accentAmber,
    Color? accentRed,
    Color? textPrimary,
    Color? textMuted,
    Color? borderHairline,
    bool? isDark,
  }) {
    return CinemaColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      accentAmber: accentAmber ?? this.accentAmber,
      accentRed: accentRed ?? this.accentRed,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      borderHairline: borderHairline ?? this.borderHairline,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  CinemaColors lerp(ThemeExtension<CinemaColors>? other, double t) {
    if (other is! CinemaColors) return this;
    return CinemaColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      accentAmber: Color.lerp(accentAmber, other.accentAmber, t)!,
      accentRed: Color.lerp(accentRed, other.accentRed, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      borderHairline: Color.lerp(borderHairline, other.borderHairline, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }

  static const CinemaColors midnight = CinemaColors(
    bg: CinemaTokens.celluloidBlack,
    surface: CinemaTokens.boothBrown,
    surfaceElevated: CinemaTokens.boothBrownElevated,
    accentAmber: CinemaTokens.projectorAmber,
    accentRed: CinemaTokens.ticketRed,
    textPrimary: CinemaTokens.bone,
    textMuted: CinemaTokens.ash,
    borderHairline: CinemaTokens.hairline,
    isDark: true,
  );

  static const CinemaColors matinee = CinemaColors(
    bg: CinemaTokens.matineeBg,
    surface: CinemaTokens.matineeSurface,
    surfaceElevated: CinemaTokens.matineeSurfaceElevated,
    accentAmber: CinemaTokens.matineeAmber,
    accentRed: CinemaTokens.matineeRed,
    textPrimary: CinemaTokens.matineeInk,
    textMuted: CinemaTokens.matineeMuted,
    borderHairline: CinemaTokens.matineeHairline,
    isDark: false,
  );
}

/// Factory class for REELHOUSE Cinema themes.
class CinemaTheme {
  CinemaTheme._();

  static ThemeData get midnightTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: CinemaTokens.celluloidBlack,
      canvasColor: CinemaTokens.boothBrown,
      cardColor: CinemaTokens.boothBrown,
      primaryColor: CinemaTokens.projectorAmber,
      colorScheme: const ColorScheme.dark(
        primary: CinemaTokens.projectorAmber,
        secondary: CinemaTokens.ticketRed,
        surface: CinemaTokens.boothBrown,
        error: CinemaTokens.ticketRed,
        onPrimary: CinemaTokens.celluloidBlack,
        onSecondary: CinemaTokens.bone,
        onSurface: CinemaTokens.bone,
        onError: CinemaTokens.bone,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: CinemaTokens.celluloidBlack,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(bottom: CinemaTokens.borderSideDark),
        iconTheme: IconThemeData(color: CinemaTokens.projectorAmber),
      ),
      dividerTheme: const DividerThemeData(
        color: CinemaTokens.hairline,
        thickness: CinemaTokens.borderWidth,
        space: 1,
      ),
      cardTheme: const CardThemeData(
        color: CinemaTokens.boothBrown,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: CinemaTokens.borderSharp,
          side: CinemaTokens.borderSideDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CinemaTokens.projectorAmber,
          foregroundColor: CinemaTokens.celluloidBlack,
          elevation: 0,
          textStyle: CinemaText.monoLabel(color: CinemaTokens.celluloidBlack),
          shape: const RoundedRectangleBorder(
            borderRadius: CinemaTokens.borderSharp,
            side: CinemaTokens.borderSideAmber,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CinemaTokens.bone,
          side: CinemaTokens.borderSideDark,
          textStyle: CinemaText.monoLabel(color: CinemaTokens.bone),
          shape: const RoundedRectangleBorder(
            borderRadius: CinemaTokens.borderSharp,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CinemaTokens.projectorAmber,
          textStyle: CinemaText.monoLabel(color: CinemaTokens.projectorAmber),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: CinemaTokens.boothBrown,
        border: OutlineInputBorder(
          borderRadius: CinemaTokens.borderSharp,
          borderSide: CinemaTokens.borderSideDark,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: CinemaTokens.borderSharp,
          borderSide: CinemaTokens.borderSideDark,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: CinemaTokens.borderSharp,
          borderSide: CinemaTokens.borderSideAmber,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: CinemaTokens.borderSharp,
          borderSide: CinemaTokens.borderSideRed,
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: CinemaTokens.borderSharp,
          borderSide: CinemaTokens.borderSideRed,
        ),
        labelStyle: TextStyle(color: CinemaTokens.ash, fontFamily: CinemaTokens.fontMono),
        hintStyle: TextStyle(color: CinemaTokens.ash, fontFamily: CinemaTokens.fontMono),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: CinemaTokens.boothBrown,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: CinemaTokens.borderSharp,
          side: CinemaTokens.borderSideDark,
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: CinemaTokens.projectorAmber,
        unselectedLabelColor: CinemaTokens.ash,
        indicatorColor: CinemaTokens.projectorAmber,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: CinemaTokens.projectorAmber,
        inactiveTrackColor: CinemaTokens.hairline,
        thumbColor: CinemaTokens.projectorAmber,
        overlayColor: Color(0x33FFB020),
      ),
      extensions: const [CinemaColors.midnight],
    );
  }

  static ThemeData get matineeTheme {
    final base = ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: CinemaTokens.matineeBg,
      canvasColor: CinemaTokens.matineeSurface,
      cardColor: CinemaTokens.matineeSurface,
      primaryColor: CinemaTokens.matineeAmber,
      colorScheme: const ColorScheme.light(
        primary: CinemaTokens.matineeAmber,
        secondary: CinemaTokens.matineeRed,
        surface: CinemaTokens.matineeSurface,
        error: CinemaTokens.matineeRed,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: CinemaTokens.matineeInk,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: CinemaTokens.matineeBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(bottom: CinemaTokens.borderSideLight),
        iconTheme: IconThemeData(color: CinemaTokens.matineeInk),
      ),
      dividerTheme: const DividerThemeData(
        color: CinemaTokens.matineeHairline,
        thickness: CinemaTokens.borderWidth,
        space: 1,
      ),
      cardTheme: const CardThemeData(
        color: CinemaTokens.matineeSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: CinemaTokens.borderSharp,
          side: CinemaTokens.borderSideLight,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: CinemaTokens.matineeAmber,
          foregroundColor: Colors.white,
          elevation: 0,
          textStyle: CinemaText.monoLabel(color: Colors.white),
          shape: const RoundedRectangleBorder(
            borderRadius: CinemaTokens.borderSharp,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: CinemaTokens.matineeInk,
          side: CinemaTokens.borderSideLight,
          textStyle: CinemaText.monoLabel(color: CinemaTokens.matineeInk),
          shape: const RoundedRectangleBorder(
            borderRadius: CinemaTokens.borderSharp,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: CinemaTokens.matineeAmber,
          textStyle: CinemaText.monoLabel(color: CinemaTokens.matineeAmber),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: CinemaTokens.matineeSurface,
        border: OutlineInputBorder(
          borderRadius: CinemaTokens.borderSharp,
          borderSide: CinemaTokens.borderSideLight,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: CinemaTokens.borderSharp,
          borderSide: CinemaTokens.borderSideLight,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: CinemaTokens.borderSharp,
          borderSide: BorderSide(color: CinemaTokens.matineeAmber, width: CinemaTokens.borderWidth),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: CinemaTokens.borderSharp,
          borderSide: BorderSide(color: CinemaTokens.matineeRed, width: CinemaTokens.borderWidth),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: CinemaTokens.borderSharp,
          borderSide: BorderSide(color: CinemaTokens.matineeRed, width: CinemaTokens.borderWidth),
        ),
        labelStyle: TextStyle(color: CinemaTokens.matineeMuted, fontFamily: CinemaTokens.fontMono),
        hintStyle: TextStyle(color: CinemaTokens.matineeMuted, fontFamily: CinemaTokens.fontMono),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: CinemaTokens.matineeSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: CinemaTokens.borderSharp,
          side: CinemaTokens.borderSideLight,
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: CinemaTokens.matineeInk,
        unselectedLabelColor: CinemaTokens.matineeMuted,
        indicatorColor: CinemaTokens.matineeAmber,
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: CinemaTokens.matineeAmber,
        inactiveTrackColor: CinemaTokens.matineeHairline,
        thumbColor: CinemaTokens.matineeAmber,
        overlayColor: Color(0x33D97706),
      ),
      extensions: const [CinemaColors.matinee],
    );
  }
}

extension CinemaColorsExtension on BuildContext {
  CinemaColors get cinemaColors =>
      Theme.of(this).extension<CinemaColors>() ?? CinemaColors.midnight;
}
