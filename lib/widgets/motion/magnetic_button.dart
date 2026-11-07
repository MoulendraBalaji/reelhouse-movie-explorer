// ANIMATION: explicit (Magnetic Pointer Follow + Sweep Fill Hover + Press Compression)
// MagneticButton: Button subtly pulls toward cursor within an 80px proximity radius,
// sweeps an amber fill from cursor side, and compresses on tap.

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../theme/motion.dart';

class MagneticButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double magneticRadius;
  final double maxPullDistance;
  final Color baseColor;
  final Color hoverColor;

  const MagneticButton({
    super.key,
    required this.child,
    this.onPressed,
    this.magneticRadius = 80.0,
    this.maxPullDistance = 8.0,
    this.baseColor = CinemaTokens.projectorAmber,
    this.hoverColor = const Color(0xFFFFC04D),
  });

  @override
  State<MagneticButton> createState() => _MagneticButtonState();
}

class _MagneticButtonState extends State<MagneticButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _springController;
  Animation<Offset>? _springOffsetAnim;

  Offset _currentPull = Offset.zero;
  bool _isHovered = false;
  bool _isPressed = false;
  Offset _hoverRelativePos = const Offset(0.5, 0.5);

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

  void _onHover(PointerHoverEvent event, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final delta = event.localPosition - center;
    final dist = delta.distance;

    if (dist < widget.magneticRadius) {
      final pullFactor = (1.0 - (dist / widget.magneticRadius)).clamp(0.0, 1.0);
      final pull = (delta / (dist == 0 ? 1 : dist)) * (widget.maxPullDistance * pullFactor);

      setState(() {
        _currentPull = pull;
        _isHovered = true;
        _hoverRelativePos = Offset(
          event.localPosition.dx / size.width,
          event.localPosition.dy / size.height,
        );
      });
    }
  }

  void _onExit(PointerExitEvent event) {
    final start = _currentPull;
    _springOffsetAnim = Tween<Offset>(begin: start, end: Offset.zero).animate(
      CurvedAnimation(parent: _springController, curve: Curves.easeOutBack),
    );

    _springController.reset();
    _springController.forward();
    _springController.addListener(() {
      if (mounted) {
        setState(() {
          _currentPull = _springOffsetAnim?.value ?? Offset.zero;
        });
      }
    });

    setState(() {
      _isHovered = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (CinemaMotion.isReducedMotion(context)) {
      return GestureDetector(
        onTap: widget.onPressed,
        child: widget.child,
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (e) => _onHover(e, Size(constraints.maxWidth, constraints.maxHeight)),
          onExit: _onExit,
          child: GestureDetector(
            onTap: widget.onPressed,
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            child: Transform.translate(
              offset: _currentPull,
              child: Transform.scale(
                scale: _isPressed ? 0.95 : 1.0,
                child: AnimatedContainer(
                  duration: CinemaMotion.instant,
                  decoration: BoxDecoration(
                    borderRadius: CinemaTokens.borderSharp,
                    gradient: _isHovered
                        ? RadialGradient(
                            center: Alignment(
                              (_hoverRelativePos.dx - 0.5) * 2,
                              (_hoverRelativePos.dy - 0.5) * 2,
                            ),
                            radius: 1.2,
                            colors: [
                              widget.hoverColor,
                              widget.baseColor,
                            ],
                          )
                        : null,
                  ),
                  child: widget.child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
