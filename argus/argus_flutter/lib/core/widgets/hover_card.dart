import 'package:flutter/material.dart';
import '../../app/theme/tokens.dart';

/// Elevated interactive card with smooth hover lift and crisp moonlit silver border.
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
    const moonlitBorder = Color(0x99CBD5E1); // Soft lunar silver
    const moonlitGlow = Color(0x22CBD5E1);

    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          transform: Matrix4.translationValues(0, _isHovered ? -2 : 0, 0),
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? ArgusTokens.bgRaised,
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: _isHovered
                  ? (widget.hoverBorderColor ?? moonlitBorder)
                  : (widget.borderColor ?? ArgusTokens.borderSubtle),
              width: _isHovered ? 1.5 : 1.0,
            ),
            boxShadow: _isHovered && widget.enableGlow
                ? const [
                    BoxShadow(
                      color: moonlitGlow,
                      blurRadius: 16,
                      spreadRadius: 0,
                    ),
                  ]
                : const [],
          ),
          padding: widget.padding,
          child: widget.child,
        ),
      ),
    );
  }
}
