// ANIMATION: explicit (AnimationController + Mechanical Digit Roll + CustomPainter Progressive Chart)
// OdometerCounter & PaintedChartReveal: Mechanical odometer numbers rolling for stats
// and custom progressive line/bar chart drawing in Profile.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/motion.dart';
import '../../theme/text_styles.dart';

class OdometerCounter extends StatefulWidget {
  final num value;
  final String suffix;
  final double fontSize;
  final Duration duration;

  const OdometerCounter({
    super.key,
    required this.value,
    this.suffix = '',
    this.fontSize = 32.0,
    this.duration = CinemaMotion.cinematic,
  });

  @override
  State<OdometerCounter> createState() => _OdometerCounterState();
}

class _OdometerCounterState extends State<OdometerCounter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _animation = Tween<double>(begin: 0.0, end: widget.value.toDouble()).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant OdometerCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.cinemaColors;

    if (CinemaMotion.isReducedMotion(context)) {
      final text = widget.value is int
          ? '${widget.value}${widget.suffix}'
          : '${widget.value.toStringAsFixed(1)}${widget.suffix}';
      return Text(text, style: CinemaText.odometerNumber(color: colors.accentAmber, size: widget.fontSize));
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, _) {
        final val = _animation.value;
        final formatted = widget.value is int
            ? '${val.toInt()}${widget.suffix}'
            : '${val.toStringAsFixed(1)}${widget.suffix}';

        return Text(
          formatted,
          style: CinemaText.odometerNumber(color: colors.accentAmber, size: widget.fontSize),
        );
      },
    );
  }
}

class ChartDataPoint {
  final String label;
  final double value;

  const ChartDataPoint({required this.label, required this.value});
}

class PaintedChartReveal extends StatefulWidget {
  final List<ChartDataPoint> points;
  final double height;

  const PaintedChartReveal({
    super.key,
    required this.points,
    this.height = 180.0,
  });

  @override
  State<PaintedChartReveal> createState() => _PaintedChartRevealState();
}

class _PaintedChartRevealState extends State<PaintedChartReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _chartController;
  late final Animation<double> _drawProgress;

  @override
  void initState() {
    super.initState();
    _chartController = AnimationController(
      vsync: this,
      duration: CinemaMotion.slow,
    );
    _drawProgress = CurvedAnimation(
      parent: _chartController,
      curve: Curves.easeOutExpo,
    );

    _chartController.forward();
  }

  @override
  void dispose() {
    _chartController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isReduced = CinemaMotion.isReducedMotion(context);
    final colors = context.cinemaColors;

    return RepaintBoundary(
      child: Container(
        height: widget.height,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: AnimatedBuilder(
          animation: _drawProgress,
          builder: (context, _) {
            return CustomPaint(
              size: Size.infinite,
              painter: CinemaChartPainter(
                points: widget.points,
                progress: isReduced ? 1.0 : _drawProgress.value,
                colors: colors,
              ),
            );
          },
        ),
      ),
    );
  }
}

class CinemaChartPainter extends CustomPainter {
  final List<ChartDataPoint> points;
  final double progress;
  final CinemaColors colors;

  CinemaChartPainter({
    required this.points,
    required this.progress,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final bottomPadding = 26.0;
    final chartHeight = size.height - bottomPadding;
    final maxVal = points.map((p) => p.value).reduce(math.max);
    final barWidth = (size.width / (points.length * 1.8)).clamp(16.0, 42.0);
    final totalBarsWidth = points.length * barWidth;
    final spacing = (size.width - totalBarsWidth) / (points.length + 1);

    // Draw baseline hairline
    final baselinePaint = Paint()
      ..color = colors.borderHairline
      ..strokeWidth = 1.0;
    canvas.drawLine(
      Offset(0, chartHeight),
      Offset(size.width, chartHeight),
      baselinePaint,
    );

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final targetBarHeight = (p.value / (maxVal == 0 ? 1 : maxVal)) * (chartHeight * 0.85);
      final currentBarHeight = targetBarHeight * progress;

      final x = spacing + i * (barWidth + spacing);
      final y = chartHeight - currentBarHeight;

      // Cinema pillar bar with amber gradient
      final rect = Rect.fromLTWH(x, y, barWidth, currentBarHeight);
      final barPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            colors.surfaceElevated,
            colors.accentAmber.withValues(alpha: 0.85),
          ],
        ).createShader(rect)
        ..style = PaintingStyle.fill;

      canvas.drawRect(rect, barPaint);

      // Hairline border around bar
      final borderPaint = Paint()
        ..color = colors.accentAmber
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;
      canvas.drawRect(rect, borderPaint);

      // Value label on top of bar
      if (progress > 0.6) {
        textPainter.text = TextSpan(
          text: p.value.toInt().toString(),
          style: CinemaText.monoBadge(color: colors.textPrimary),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x + (barWidth - textPainter.width) / 2, y - textPainter.height - 4),
        );
      }

      // X-axis label
      textPainter.text = TextSpan(
        text: p.label,
        style: CinemaText.monoLabel(color: colors.textMuted),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + (barWidth - textPainter.width) / 2, chartHeight + 6),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CinemaChartPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.colors != colors;
  }
}
