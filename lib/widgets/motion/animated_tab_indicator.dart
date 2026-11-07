// ANIMATION: explicit & implicit (AnimatedPositioned + AnimatedSwitcher + Slide-Fade Transition)
// AnimatedTabIndicator: Cinema tab indicator with smooth sliding amber highlight and slide-fade content switching.

import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../theme/app_theme.dart';
import '../../theme/motion.dart';

class CinemaAnimatedTabs extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const CinemaAnimatedTabs({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.cinemaColors;

    return Container(
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.borderHairline),
        borderRadius: CinemaTokens.borderSharp,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = (constraints.maxWidth - 6) / tabs.length;

          return Stack(
            children: [
              // Sliding Amber Indicator Box
              AnimatedPositioned(
                duration: CinemaMotion.quick,
                curve: Curves.easeOutCubic,
                left: selectedIndex * tabWidth,
                top: 0,
                bottom: 0,
                width: tabWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.accentAmber,
                    borderRadius: CinemaTokens.borderSharp,
                    boxShadow: [
                      BoxShadow(
                        color: colors.accentAmber.withValues(alpha: 0.25),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),

              // Tab text buttons
              Row(
                children: [
                  for (int i = 0; i < tabs.length; i++)
                    Expanded(
                      child: InkWell(
                        onTap: () => onTabSelected(i),
                        child: Center(
                          child: Text(
                            tabs[i],
                            style: TextStyle(
                              fontFamily: CinemaTokens.fontMono,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              color: selectedIndex == i
                                  ? Colors.black
                                  : colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Slide-fade transition builder for AnimatedSwitcher
Widget cinemaSlideFadeTransition(Widget child, Animation<double> animation) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0.05, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
    child: FadeTransition(
      opacity: animation,
      child: child,
    ),
  );
}
