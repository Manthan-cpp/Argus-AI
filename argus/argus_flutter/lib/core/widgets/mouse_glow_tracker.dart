import 'package:flutter/material.dart';
import '../../app/theme/tokens.dart';

/// Interactive mouse-tracking container that renders a soft radiant spotlight
/// following the cursor across cards, dashboard headers, and hero stages.
class MouseGlowTracker extends StatefulWidget {
  final Widget child;
  final Color glowColor;
  final double radius;
  final double opacity;
  final BorderRadius? borderRadius;
  final bool enableTilt;

  const MouseGlowTracker({
    super.key,
    required this.child,
    this.glowColor = ArgusTokens.accent,
    this.radius = 320.0,
    this.opacity = 0.12,
    this.borderRadius,
    this.enableTilt = false,
  });

  @override
  State<MouseGlowTracker> createState() => _MouseGlowTrackerState();
}

class _MouseGlowTrackerState extends State<MouseGlowTracker>
    with SingleTickerProviderStateMixin {
  Offset _mousePos = const Offset(-1000, -1000);
  bool _isHovered = false;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onHover(PointerEvent event) {
    setState(() {
      _mousePos = event.localPosition;
      if (!_isHovered) {
        _isHovered = true;
        _animController.forward();
      }
    });
  }

  void _onExit(PointerEvent event) {
    setState(() {
      _isHovered = false;
      _animController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _onHover,
      onExit: _onExit,
      child: ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(ArgusTokens.radiusMd),
        child: Stack(
          children: [
            widget.child,
            if (_isHovered)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _animController,
                    builder: (context, _) {
                      return CustomPaint(
                        painter: _SpotlightPainter(
                          center: _mousePos,
                          radius: widget.radius,
                          color: widget.glowColor,
                          opacity: widget.opacity * _animController.value,
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final Color color;
  final double opacity;

  _SpotlightPainter({
    required this.center,
    required this.radius,
    required this.color,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0.001) return;

    final paint = Paint()
      ..shader = RadialGradient(
        center: Alignment(
          (center.dx / size.width) * 2 - 1,
          (center.dy / size.height) * 2 - 1,
        ),
        radius: radius / (size.shortestSide > 0 ? size.shortestSide : 100),
        colors: [
          color.withValues(alpha: opacity),
          color.withValues(alpha: opacity * 0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.center != center ||
        oldDelegate.opacity != opacity ||
        oldDelegate.color != color;
  }
}
