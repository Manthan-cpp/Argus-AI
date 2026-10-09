import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/severity_scale.dart';
import '../../app/theme/tokens.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final bool isGlowing;
  final bool outlined;

  const StatusBadge({
    super.key,
    required this.label,
    this.icon,
    required this.color,
    this.isGlowing = false,
    this.outlined = false,
  });

  factory StatusBadge.fromSeverity(SeverityLevel severity) {
    return StatusBadge(
      label: severity.label,
      icon: severity.icon,
      color: severity.color,
      isGlowing: severity == SeverityLevel.critical || severity == SeverityLevel.high,
    );
  }

  factory StatusBadge.fromStatus(String status) {
    Color c;
    IconData ic;
    switch (status.toLowerCase()) {
      case 'open':
        c = ArgusTokens.statusOpen;
        ic = Icons.fiber_manual_record_rounded;
        break;
      case 'acknowledged':
        c = ArgusTokens.statusAcknowledged;
        ic = Icons.visibility_outlined;
        break;
      case 'resolved':
        c = ArgusTokens.statusResolved;
        ic = Icons.check_circle_outline_rounded;
        break;
      case 'false_positive':
      default:
        c = ArgusTokens.statusFalsePositive;
        ic = Icons.cancel_outlined;
        break;
    }

    return StatusBadge(
      label: status.toUpperCase().replaceAll('_', ' '),
      icon: ic,
      color: c,
    );
  }


  factory StatusBadge.replay() {
    return const StatusBadge(
      label: 'REPLAY CLIP',
      icon: Icons.replay_rounded,
      color: Color(0xFFA78BFA), // Lavender
    );
  }

  factory StatusBadge.live() {
    return const StatusBadge(
      label: 'LIVE CAM',
      icon: Icons.videocam_rounded,
      color: ArgusTokens.accent,
      isGlowing: true,
    );
  }

  factory StatusBadge.videoFile() {
    return const StatusBadge(
      label: 'VIDEO FILE',
      icon: Icons.movie_outlined,
      color: Color(0xFF38BDF8),
    );
  }

  factory StatusBadge.custom({
    required String label,
    IconData? icon,
    required Color color,
    bool isGlowing = false,
    bool outlined = false,
  }) {
    return StatusBadge(
      label: label,
      icon: icon,
      color: color,
      isGlowing: isGlowing,
      outlined: outlined,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ArgusTokens.radiusSm),
        border: Border.all(
          color: color.withValues(alpha: outlined ? 0.8 : 0.35),
          width: 1,
        ),
        boxShadow: isGlowing
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.25),
                  blurRadius: 8,
                  spreadRadius: 0,
                )
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
