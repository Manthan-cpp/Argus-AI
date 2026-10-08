import 'package:flutter/material.dart';
import '../../app/theme/tokens.dart';
import 'rainbow_moving_border.dart';

/// Interactive container that activates a live moving thin rainbow spectral border
/// upon mouse hover or focus, over a crisp white base boundary.
class MouseGlowTracker extends StatefulWidget {
  final Widget child;
  final BorderRadius? borderRadius;
  final double borderWidth;
  final bool alwaysLive;
  final Color backgroundColor;

  const MouseGlowTracker({
    super.key,
    required this.child,
    this.borderRadius,
    this.borderWidth = 1.2,
    this.alwaysLive = false,
    this.backgroundColor = ArgusTokens.bgRaised,
    // Deprecated legacy params kept for callsite backward-compatibility
    Color? glowColor,
    double? radius,
    double? opacity,
    bool? enableTilt,
  });

  @override
  State<MouseGlowTracker> createState() => _MouseGlowTrackerState();
}

class _MouseGlowTrackerState extends State<MouseGlowTracker> {
  bool _isHovered = false;

  void _onEnter(PointerEvent event) {
    if (!_isHovered) {
      setState(() => _isHovered = true);
    }
  }

  void _onExit(PointerEvent event) {
    if (_isHovered) {
      setState(() => _isHovered = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.borderRadius ?? BorderRadius.circular(ArgusTokens.radiusMd);
    final isLive = widget.alwaysLive || _isHovered;

    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      child: RainbowMovingBorder(
        borderRadius: r,
        borderWidth: widget.borderWidth,
        backgroundColor: widget.backgroundColor,
        baseBorderColor: isLive ? Colors.white : ArgusTokens.borderSubtle,
        isLive: isLive,
        duration: const Duration(seconds: 4),
        child: widget.child,
      ),
    );
  }
}
