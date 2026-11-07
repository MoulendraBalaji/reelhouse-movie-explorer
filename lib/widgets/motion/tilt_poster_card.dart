// ANIMATION: explicit (Matrix4 3D Perspective Tilt + Moving Specular Glare + Spring Simulation)
// TiltPosterCard: Web pointer 3D tilt following cursor with specular amber glare and physical spring return.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../theme/app_theme.dart';
import '../../theme/motion.dart';
import '../../core/responsive.dart';

class TiltPosterCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double maxTiltAngle;
  final double liftDistance;

  const TiltPosterCard({
    super.key,
    required this.child,
    this.onTap,
    this.maxTiltAngle = 0.14, // in radians (~8 degrees)
    this.liftDistance = 6.0,
  });

  @override
  State<TiltPosterCard> createState() => _TiltPosterCardState();
}

class _TiltPosterCardState extends State<TiltPosterCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _springController;
  final ValueNotifier<Offset> _tiltNotifier = ValueNotifier<Offset>(Offset.zero);
  final ValueNotifier<bool> _hoverNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _pressNotifier = ValueNotifier<bool>(false);

  Animation<Offset>? _springAnim;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: CinemaMotion.base,
    );
    _springController.addListener(() {
      if (_springAnim != null) {
        _tiltNotifier.value = _springAnim!.value;
      }
    });
  }

  @override
  void dispose() {
    _springController.dispose();
    _tiltNotifier.dispose();
    _hoverNotifier.dispose();
    _pressNotifier.dispose();
    super.dispose();
  }

  void _onPointerHover(PointerHoverEvent event, Size size) {
    if (size.width == 0 || size.height == 0) return;

    final normX = ((event.localPosition.dx / size.width) - 0.5) * 2.0;
    final normY = ((event.localPosition.dy / size.height) - 0.5) * 2.0;

    _tiltNotifier.value = Offset(
      normX.clamp(-1.0, 1.0),
      -normY.clamp(-1.0, 1.0),
    );
    if (!_hoverNotifier.value) {
      _hoverNotifier.value = true;
    }
  }

  void _onPointerExit(PointerExitEvent event) {
    final start = _tiltNotifier.value;
    _springAnim = Tween<Offset>(begin: start, end: Offset.zero).animate(
      CurvedAnimation(parent: _springController, curve: Curves.easeOutBack),
    );
    _springController.reset();
    _springController.forward();
    _hoverNotifier.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final isReduced = CinemaMotion.isReducedMotion(context);
    final isMobile = Responsive.isMobile(context);
    final colors = context.cinemaColors;

    if (isReduced || isMobile) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: CinemaTokens.borderSharp,
          child: widget.child,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.hasBoundedWidth && !constraints.maxWidth.isInfinite
            ? constraints.maxWidth
            : 220.0;
        final h = constraints.hasBoundedHeight && !constraints.maxHeight.isInfinite
            ? constraints.maxHeight
            : 360.0;
        final cardSize = Size(w, h);

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (e) => _onPointerHover(e, cardSize),
          onExit: _onPointerExit,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onTap,
            onTapDown: (_) => _pressNotifier.value = true,
            onTapUp: (_) => _pressNotifier.value = false,
            onTapCancel: () => _pressNotifier.value = false,
            child: ValueListenableBuilder<bool>(
              valueListenable: _hoverNotifier,
              builder: (context, isHovered, hoverChild) {
                return ValueListenableBuilder<bool>(
                  valueListenable: _pressNotifier,
                  builder: (context, isPressed, pressChild) {
                    return ValueListenableBuilder<Offset>(
                      valueListenable: _tiltNotifier,
                      builder: (context, tilt, _) {
                        final Matrix4 transform = Matrix4.identity()
                          ..setEntry(3, 2, 0.0010) // 3D depth perspective
                          ..rotateX(tilt.dy * widget.maxTiltAngle)
                          ..rotateY(tilt.dx * widget.maxTiltAngle);

                        if (isHovered) {
                          transform.translateByDouble(0.0, -widget.liftDistance, 0.0, 1.0);
                        }
                        if (isPressed) {
                          transform.scaleByDouble(0.97, 0.97, 1.0, 1.0);
                        }

                        return Transform(
                          transform: transform,
                          alignment: FractionalOffset.center,
                          child: AnimatedContainer(
                            duration: CinemaMotion.instant,
                            decoration: BoxDecoration(
                              borderRadius: CinemaTokens.borderSharp,
                              border: Border.all(
                                color: isHovered
                                    ? colors.accentAmber
                                    : colors.borderHairline,
                                width: isHovered ? 1.5 : 1.0,
                              ),
                              boxShadow: isHovered
                                  ? [
                                      BoxShadow(
                                        color: colors.accentAmber.withValues(alpha: 0.22),
                                        offset: const Offset(0, 8),
                                        blurRadius: 16,
                                      )
                                    ]
                                  : const [],
                            ),
                            child: Stack(
                              clipBehavior: Clip.antiAlias,
                              children: [
                                widget.child,

                                // Specular glare highlight
                                if (isHovered)
                                  Positioned.fill(
                                    child: IgnorePointer(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment(-tilt.dx * 1.5, -tilt.dy * 1.5),
                                            end: Alignment(tilt.dx * 1.5, tilt.dy * 1.5),
                                            colors: [
                                              Colors.transparent,
                                              colors.accentAmber.withValues(alpha: 0.10),
                                              Colors.white.withValues(alpha: 0.06),
                                              Colors.transparent,
                                            ],
                                            stops: const [0.0, 0.45, 0.55, 1.0],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }
}
