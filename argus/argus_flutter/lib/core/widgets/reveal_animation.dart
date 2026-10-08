import 'package:flutter/material.dart';

/// Fluid reveal animation widget that provides staggered entrance effects
/// for dashboards, metric cards, incident feeds, and hero elements.
class RevealAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset slideOffset;
  final double initialScale;
  final Curve curve;

  const RevealAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 550),
    this.slideOffset = const Offset(0, 18),
    this.initialScale = 0.98,
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<RevealAnimation> createState() => _RevealAnimationState();
}

class _RevealAnimationState extends State<RevealAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    final curved = CurvedAnimation(parent: _controller, curve: widget.curve);

    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
    _slideAnim = Tween<Offset>(begin: widget.slideOffset, end: Offset.zero).animate(curved);
    _scaleAnim = Tween<double>(begin: widget.initialScale, end: 1.0).animate(curved);

    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
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
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnim.value,
          child: Transform.translate(
            offset: _slideAnim.value,
            child: Transform.scale(
              scale: _scaleAnim.value,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}
