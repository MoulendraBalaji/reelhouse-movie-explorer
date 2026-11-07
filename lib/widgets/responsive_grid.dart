// CONCEPT: Responsive Layout (MediaQuery + LayoutBuilder Grid)
// Adapts column counts dynamically (2 / 3 / 4-6) with zero overflow across 360px, 768px, 1440px.

import 'package:flutter/material.dart';
import '../core/responsive.dart';
import 'motion/scroll_reveal_stagger.dart';

class ResponsiveGrid extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext context, int index) itemBuilder;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final EdgeInsets padding;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  const ResponsiveGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.childAspectRatio = 0.61, // standard movie poster aspect ratio
    this.crossAxisSpacing = 16.0,
    this.mainAxisSpacing = 20.0,
    this.padding = EdgeInsets.zero,
    this.physics,
    this.shrinkWrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final columns = Responsive.getGridColumnCount(context);
    final width = MediaQuery.of(context).size.width;
    final effectiveRatio = childAspectRatio != 0.61
        ? childAspectRatio
        : (width < 600 ? 0.58 : (width < 1024 ? 0.62 : 0.64));

    return GridView.builder(
      padding: padding,
      physics: physics,
      shrinkWrap: shrinkWrap,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: effectiveRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return ScrollRevealStagger(
          index: index % 12,
          child: itemBuilder(context, index),
        );
      },
    );
  }
}
