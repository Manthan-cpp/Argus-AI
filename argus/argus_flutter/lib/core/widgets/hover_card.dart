import 'package:flutter/material.dart';
import '../../app/theme/tokens.dart';
import 'rainbow_moving_border.dart';

/// Elevated interactive card with smooth hover lift, border glow,
/// and integrated mouse-tracking spotlight.
class HoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? hoverBorderColor;
  final double borderRadius;
  final bool enableGlow;

  const HoverCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(ArgusTokens.space20),
    this.backgroundColor,
    this.borderColor,
    this.hoverBorderColor,
    this.borderRadius = ArgusTokens.radiusMd,
    this.enableGlow = true,
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
          child: RainbowMovingBorder(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            backgroundColor: widget.backgroundColor ?? ArgusTokens.bgRaised,
            baseBorderColor: _isHovered ? Colors.white : (widget.borderColor ?? ArgusTokens.borderSubtle),
            borderWidth: _isHovered ? 1.2 : 1.0,
            isLive: widget.enableGlow && _isHovered,
            padding: widget.padding,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
