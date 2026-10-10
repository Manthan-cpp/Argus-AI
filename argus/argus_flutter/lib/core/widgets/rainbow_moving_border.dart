import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../app/theme/tokens.dart';

/// A production-grade container with a crisp white border and an animated,
/// live-circulating thin rainbow gradient beam along its perimeter.
///
/// Designed specifically for high-contrast monochrome UI: the card interior
/// remains pitch-black (#000000 / #0A0A0A), while the outer border features
/// a razor-sharp white boundary with a luminous rainbow spectral shimmer.
class RainbowMovingBorder extends StatefulWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final double borderWidth;
  final Color backgroundColor;
  final Color baseBorderColor;
  final List<Color> rainbowColors;
  final Duration duration;
  final bool isLive;
  final EdgeInsetsGeometry padding;

  const RainbowMovingBorder({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(ArgusTokens.radiusMd)),
    this.borderWidth = 1.2,
    this.backgroundColor = ArgusTokens.bgRaised,
    this.baseBorderColor = const Color(0x33FFFFFF), // 20% crisp white
    this.rainbowColors = ArgusTokens.rainbowSpectrum,
    this.duration = const Duration(seconds: 4),
    this.isLive = true,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<RainbowMovingBorder> createState() => _RainbowMovingBorderState();
}

class _RainbowMovingBorderState extends State<RainbowMovingBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    if (widget.isLive) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(RainbowMovingBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLive != oldWidget.isLive) {
      if (widget.isLive) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          foregroundPainter: _RainbowBorderPainter(
            progress: _controller.value,
            borderRadius: widget.borderRadius,
            borderWidth: widget.borderWidth,
            baseBorderColor: widget.baseBorderColor,
            rainbowColors: widget.rainbowColors,
            isLive: widget.isLive,
          ),
          child: ClipRRect(
            borderRadius: widget.borderRadius,
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Container(
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: widget.borderRadius,
              ),
              padding: widget.padding,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

class _RainbowBorderPainter extends CustomPainter {
  final double progress;
  final BorderRadius borderRadius;
  final double borderWidth;
  final Color baseBorderColor;
  final List<Color> rainbowColors;
  final bool isLive;

  _RainbowBorderPainter({
    required this.progress,
    required this.borderRadius,
    required this.borderWidth,
    required this.baseBorderColor,
    required this.rainbowColors,
    required this.isLive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final outerRRect = borderRadius.toRRect(Offset.zero & size);
    final rrect = outerRRect.deflate(borderWidth / 2);

    // 1. Draw solid / subtle crisp white base border
    final basePaint = Paint()
      ..color = baseBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;
    canvas.drawRRect(rrect, basePaint);

    if (!isLive) return;

    // 2. Draw live rotating thin rainbow spectral beam
    final center = Offset(size.width / 2, size.height / 2);

    final sweepGradient = SweepGradient(
      center: Alignment.center,
      colors: rainbowColors,
      transform: GradientRotation(progress * 2 * math.pi),
    );

    final rainbowPaint = Paint()
      ..shader = sweepGradient.createShader(
        Rect.fromCenter(center: center, width: size.width, height: size.height),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth + 0.3
      ..strokeCap = StrokeCap.round;

    canvas.drawRRect(rrect, rainbowPaint);
  }

  @override
  bool shouldRepaint(_RainbowBorderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isLive != isLive ||
        oldDelegate.baseBorderColor != baseBorderColor;
  }
}
