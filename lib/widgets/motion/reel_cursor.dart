// ANIMATION: explicit (Pointer Follower + Lagging Spring Interpolation + Custom Cursor)
// ReelCursor: Custom web cursor featuring a lagging amber ring that morphs into a "VIEW" badge over film posters.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../theme/motion.dart';

enum CursorMode { normal, view, crosshair }

class ReelCursorScope extends InheritedWidget {
  final ValueNotifier<CursorMode> cursorNotifier;

  const ReelCursorScope({
    super.key,
    required this.cursorNotifier,
    required super.child,
  });

  static void setMode(BuildContext context, CursorMode mode) {
    final scope = context.dependOnInheritedWidgetOfExactType<ReelCursorScope>();
    if (scope != null) {
      scope.cursorNotifier.value = mode;
    }
  }

  @override
  bool updateShouldNotify(ReelCursorScope oldWidget) => false;
}

class ReelCursorHost extends StatefulWidget {
  final Widget child;

  const ReelCursorHost({super.key, required this.child});

  @override
  State<ReelCursorHost> createState() => _ReelCursorHostState();
}

class _ReelCursorHostState extends State<ReelCursorHost>
    with SingleTickerProviderStateMixin {
  final ValueNotifier<CursorMode> _cursorNotifier = ValueNotifier<CursorMode>(CursorMode.normal);
  late final AnimationController _ticker;

  Offset _targetPos = const Offset(-100, -100);
  Offset _currentPos = const Offset(-100, -100);
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
    _ticker.addListener(() {
      // Lagging spring follow physics (lerp factor 0.20)
      if (mounted && _isVisible) {
        setState(() {
          _currentPos += (_targetPos - _currentPos) * 0.24;
        });
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _cursorNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || CinemaMotion.isReducedMotion(context)) {
      return widget.child;
    }

    return ReelCursorScope(
      cursorNotifier: _cursorNotifier,
      child: MouseRegion(
        onHover: (e) {
          _targetPos = e.position;
          if (!_isVisible) setState(() => _isVisible = true);
        },
        onExit: (_) => setState(() => _isVisible = false),
        child: Stack(
          children: [
            widget.child,

            if (_isVisible)
              ValueListenableBuilder<CursorMode>(
                valueListenable: _cursorNotifier,
                builder: (context, mode, _) {
                  double ringSize = 20.0;
                  if (mode == CursorMode.view) ringSize = 54.0;
                  if (mode == CursorMode.crosshair) ringSize = 32.0;

                  return Positioned(
                    left: _currentPos.dx - (ringSize / 2),
                    top: _currentPos.dy - (ringSize / 2),
                    child: IgnorePointer(
                      child: AnimatedContainer(
                        duration: CinemaMotion.quick,
                        curve: Curves.easeOutCubic,
                        width: ringSize,
                        height: ringSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: mode == CursorMode.view
                              ? CinemaTokens.projectorAmber.withValues(alpha: 0.85)
                              : Colors.transparent,
                          border: Border.all(
                            color: CinemaTokens.projectorAmber,
                            width: mode == CursorMode.view ? 2.0 : 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: CinemaTokens.projectorAmber.withValues(alpha: 0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: mode == CursorMode.view
                            ? Center(
                                child: Text(
                                  'VIEW',
                                  style: TextStyle(
                                    fontFamily: CinemaTokens.fontMono,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                    color: CinemaTokens.celluloidBlack,
                                  ),
                                ),
                              )
                            : mode == CursorMode.crosshair
                                ? const Center(
                                    child: Icon(Icons.drag_indicator, size: 14, color: CinemaTokens.projectorAmber),
                                  )
                                : null,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
