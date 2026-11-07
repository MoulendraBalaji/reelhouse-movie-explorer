// SIGNATURE WIDGET: MonoTag
// Uppercase mono genre chips with 1px hairline borders and sharp corners.

import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/app_theme.dart';

class MonoTag extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isSmall;
  final VoidCallback? onTap;

  const MonoTag({
    super.key,
    required this.label,
    this.isSelected = false,
    this.isSmall = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.cinemaColors;
    final textColor = isSelected
        ? Colors.black
        : (onTap != null ? colors.textPrimary : colors.textMuted);
    final bgColor = isSelected ? colors.accentAmber : Colors.transparent;
    final borderColor = isSelected ? colors.accentAmber : colors.borderHairline;

    return InkWell(
      onTap: onTap,
      borderRadius: CinemaTokens.borderSharp,
      child: AnimatedContainer(
        duration: CinemaTokens.borderSharp != BorderRadius.zero
            ? const Duration(milliseconds: 150)
            : Duration.zero,
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 6.0 : 10.0,
          vertical: isSmall ? 2.0 : 5.0,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: CinemaTokens.borderWidth),
          borderRadius: CinemaTokens.borderSharp,
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontFamily: CinemaTokens.fontMono,
            fontSize: isSmall ? 9.5 : 11.0,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 1.2,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
