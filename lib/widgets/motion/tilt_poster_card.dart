// ANIMATION: explicit (Matrix4 3D Perspective Tilt + Moving Specular Glare + Spring Simulation)
// TiltPosterCard: Web pointer 3D tilt following cursor with specular amber glare and physical spring return.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../theme/motion.dart';

class TiltPosterCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double maxTiltAngle;
  final double liftDistance;

  const TiltPosterCard({
    super.key,
    required this.child,
    this.onTap,
    this.maxTiltAngle = 0.16, // in radians (~9 degrees)
    this.liftDistance = 6.0,
  });

  @override
  State<TiltPosterCard> createState() => _TiltPosterCardState();
}

class _TiltPosterCardState extends State<TiltPosterCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _springController;
  Animation<double>? _springAnimX;
  Animation<double>? _springAnimY;

  double _tiltX = 0.0; // Rotation around X axis (-1.0 to 1.0)
  double _tiltY = 0.0; // Rotation around Y axis (-1.0 to 1.0)
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _springController = AnimationController(
      vsync: this,
      duration: CinemaMotion.base,
    );
  }

  @override
  void dispose() {
    _springController.dispose();
    super.dispose();
  }

  void _onPointerHover(PointerHoverEvent event, Size size) {
    if (size.width == 0 || size.height == 0) return;

    final normX = ((event.localPosition.dx / size.width) - 0.5) * 2.0;
    final normY = ((event.localPosition.dy / size.height) - 0.5) * 2.0;

    setState(() {
      _tiltX = -normY.clamp(-1.0, 1.0);
      _tiltY = normX.clamp(-1.0, 1.0);
      _isHovered = true;
    });
  }

  void _onPointerExit(PointerExitEvent event) {
    // Spring back smoothly to 0,0
    final startX = _tiltX;
    final startY = _tiltY;

    _springAnimX = Tween<double>(begin: startX, end: 0.0).animate(
      CurvedAnimation(parent: _springController, curve: Curves.easeOutBack),
    );
    _springAnimY = Tween<double>(begin: startY, end: 0.0).animate(
      CurvedAnimation(parent: _springController, curve: Curves.easeOutBack),
    );

    _springController.reset();
    _springController.forward();

    _springController.addListener(() {
      if (mounted) {
        setState(() {
          _tiltX = _springAnimX?.value ?? 0.0;
          _tiltY = _springAnimY?.value ?? 0.0;
        });
      }
    });

    setState(() {
      _isHovered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isReduced = CinemaMotion.isReducedMotion(context);

    if (isReduced) {
      return InkWell(
        onTap: widget.onTap,
        child: widget.child,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardSize = Size(constraints.maxWidth, constraints.maxHeight);

        // Calculate 3D perspective matrix
        final Matrix4 transform = Matrix4.identity()
          ..setEntry(3, 2, 0.0012) // Perspective distortion
          ..rotateX(_tiltX * widget.maxTiltAngle)
          ..rotateY(_tiltY * widget.maxTiltAngle);

        if (_isHovered) {
          transform.translateByDouble(0.0, -widget.liftDistance, 0.0, 1.0);
        }
        if (_isPressed) {
          transform.scaleByDouble(0.97, 0.97, 1.0, 1.0);
        }

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (e) => _onPointerHover(e, cardSize),
          onExit: _onPointerExit,
          child: GestureDetector(
            onTap: widget.onTap,
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            child: Transform(
              transform: transform,
              alignment: FractionalOffset.center,
              child: AnimatedContainer(
                duration: CinemaMotion.instant,
                decoration: BoxDecoration(
                  borderRadius: CinemaTokens.borderSharp,
                  border: Border.all(
                    color: _isHovered
                        ? CinemaTokens.projectorAmber
                        : CinemaTokens.hairline,
                    width: _isHovered ? 1.5 : 1.0,
                  ),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: CinemaTokens.projectorAmber.withValues(alpha: 0.25),
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

                    // Specular Amber Glare Gradient moving across card
                    if (_isHovered && !kIsWeb ? true : _isHovered)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: AnimatedContainer(
                            duration: CinemaMotion.instant,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(-_tiltY * 1.5, -_tiltX * 1.5),
                                end: Alignment(_tiltY * 1.5, _tiltX * 1.5),
                                colors: [
                                  Colors.transparent,
                                  CinemaTokens.projectorAmber.withValues(alpha: 0.12),
                                  Colors.white.withValues(alpha: 0.08),
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
            ),
          ),
        );
      },
    );
  }
}
