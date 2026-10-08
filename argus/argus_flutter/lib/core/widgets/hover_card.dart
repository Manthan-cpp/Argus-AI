import 'package:flutter/material.dart';
import '../../app/theme/tokens.dart';
import 'mouse_glow_tracker.dart';

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
    final border = Border.all(
      color: _isHovered
          ? (widget.hoverBorderColor ?? ArgusTokens.accent.withValues(alpha: 0.6))
          : (widget.borderColor ?? ArgusTokens.borderSubtle),
      width: _isHovered ? 1.2 : 1.0,
    );

    final cardContent = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0, _isHovered ? -3 : 0, 0),
      padding: widget.padding,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? ArgusTokens.bgRaised,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: border,
        boxShadow: _isHovered
            ? [
                BoxShadow(
                  color: ArgusTokens.accent.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                )
              ]
            : const [],
      ),
      child: widget.child,
    );

    final inner = widget.enableGlow
        ? MouseGlowTracker(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            child: cardContent,
          )
        : cardContent;

    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: inner,
      ),
    );
  }
}
