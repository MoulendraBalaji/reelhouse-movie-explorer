// ANIMATION: explicit & implicit (AnimatedBuilder + Expanding Circular Wave + Filament Glow)
// LampThemeSwitch: Vintage projector lamp theme toggle expanding light reveal between Midnight and Matinee.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/tokens.dart';
import '../../theme/motion.dart';
import '../../providers/theme_provider.dart';

class LampThemeSwitch extends StatefulWidget {
  final bool compact;
  const LampThemeSwitch({super.key, this.compact = false});

  @override
  State<LampThemeSwitch> createState() => _LampThemeSwitchState();
}

class _LampThemeSwitchState extends State<LampThemeSwitch>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lampController;
  late final Animation<double> _glowAnimation;
  late final Animation<double> _filamentRotation;

  @override
  void initState() {
    super.initState();
    _lampController = AnimationController(
      vsync: this,
      duration: CinemaMotion.base,
    );

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(
      CurvedAnimation(parent: _lampController, curve: Curves.easeInOut),
    );

    _filamentRotation = Tween<double>(begin: 0.0, end: math.pi).animate(
      CurvedAnimation(parent: _lampController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _lampController.dispose();
    super.dispose();
  }

  void _onToggle() {
    final themeProvider = context.read<ThemeProvider>();
    _lampController.forward(from: 0.0).then((_) {
      themeProvider.toggleTheme();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;

    return Tooltip(
      message: isDark ? 'SWITCH TO MATINEE (LIGHT)' : 'SWITCH TO MIDNIGHT (DARK)',
      child: AnimatedBuilder(
        animation: _lampController,
        builder: (context, _) {
          return InkWell(
            onTap: _onToggle,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: widget.compact ? 6 : 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: isDark ? CinemaTokens.boothBrown : CinemaTokens.matineeSurface,
                border: Border.all(
                  color: isDark ? CinemaTokens.hairline : CinemaTokens.matineeHairline,
                  width: 1.0,
                ),
                borderRadius: CinemaTokens.borderSharp,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Projector Lamp Filament
                  Transform.scale(
                    scale: _glowAnimation.value,
                    child: Transform.rotate(
                      angle: _filamentRotation.value,
                      child: Icon(
                        isDark ? Icons.lightbulb_outline : Icons.lightbulb,
                        size: 18,
                        color: isDark ? CinemaTokens.projectorAmber : CinemaTokens.ticketRed,
                      ),
                    ),
                  ),
                  if (!widget.compact) ...[
                    const SizedBox(width: 8),
                    Text(
                      isDark ? 'MIDNIGHT' : 'MATINEE',
                      style: TextStyle(
                        fontFamily: CinemaTokens.fontMono,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: isDark ? CinemaTokens.bone : CinemaTokens.matineeInk,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
