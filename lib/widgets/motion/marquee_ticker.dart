// ANIMATION: explicit (AnimationController + Seamless Infinite Loop + Hover Deceleration)
// MarqueeTicker: Seamless infinite projection marquee strip with hover-to-slow velocity easing.

import 'package:flutter/material.dart';
import '../../theme/tokens.dart';
import '../../theme/app_theme.dart';
import '../../theme/text_styles.dart';

class MarqueeTicker extends StatefulWidget {
  final List<String> items;
  final double height;
  final double normalSpeed; // pixels per second

  const MarqueeTicker({
    super.key,
    required this.items,
    this.height = 36.0,
    this.normalSpeed = 50.0,
  });

  @override
  State<MarqueeTicker> createState() => _MarqueeTickerState();
}

class _MarqueeTickerState extends State<MarqueeTicker>
    with SingleTickerProviderStateMixin {
  late final ScrollController _scrollController;
  late final AnimationController _tickerController;

  double _currentSpeedMultiplier = 1.0;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _tickerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _tickerController.addListener(() {
      if (mounted && _scrollController.hasClients) {
        final targetMultiplier = _isHovered ? 0.22 : 1.0; // Ease, don't stop
        _currentSpeedMultiplier += (targetMultiplier - _currentSpeedMultiplier) * 0.1;

        final delta = (widget.normalSpeed * _currentSpeedMultiplier) / 60.0;
        final maxScroll = _scrollController.position.maxScrollExtent;
        final current = _scrollController.offset;

        if (maxScroll > 0) {
          if (current + delta >= maxScroll) {
            _scrollController.jumpTo(0.0);
          } else {
            _scrollController.jumpTo(current + delta);
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _tickerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    // Repeat items to ensure seamless endless ribbon
    final repeatedItems = [...widget.items, ...widget.items, ...widget.items, ...widget.items];

    final colors = context.cinemaColors;

    return RepaintBoundary(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: colors.surfaceElevated,
            border: Border.symmetric(
              horizontal: BorderSide(color: colors.borderHairline, width: 1.0),
            ),
          ),
          child: Row(
            children: [
              // Marquee Ticker Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                height: double.infinity,
                color: colors.accentAmber,
                alignment: Alignment.center,
                child: Text(
                  'DISPATCH',
                  style: CinemaText.monoBadge(color: Colors.black),
                ),
              ),

              // Scrolling Ribbon
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: repeatedItems.length,
                  itemBuilder: (context, index) {
                    final item = repeatedItems[index];
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item.toUpperCase(),
                          style: TextStyle(
                            fontFamily: CinemaTokens.fontDisplay,
                            fontSize: 16,
                            letterSpacing: 2.0,
                            color: colors.textPrimary,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Icon(
                            Icons.circle,
                            size: 4,
                            color: colors.accentAmber.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
