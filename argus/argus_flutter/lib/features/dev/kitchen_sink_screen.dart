import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/severity_scale.dart';
import '../../core/widgets/hover_card.dart';
import '../../core/widgets/pulsing_beacon.dart';
import '../../core/widgets/status_badge.dart';

class KitchenSinkScreen extends StatelessWidget {
  const KitchenSinkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000),
          padding: const EdgeInsets.all(ArgusTokens.space32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Developer Kitchen Sink', style: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Visual validation gallery for tokens, badges, hover effects, and responsive cards.', style: GoogleFonts.inter(color: ArgusTokens.textSecondary)),
              const SizedBox(height: 24),

              Text('Severity Badges', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  StatusBadge.fromSeverity(SeverityLevel.low),
                  StatusBadge.fromSeverity(SeverityLevel.medium),
                  StatusBadge.fromSeverity(SeverityLevel.high),
                  StatusBadge.fromSeverity(SeverityLevel.critical),
                  StatusBadge.fromStatus('open'),
                  StatusBadge.fromStatus('acknowledged'),
                  StatusBadge.fromStatus('resolved'),
                  StatusBadge.fromStatus('false_positive'),
                  StatusBadge.mock(),
                  StatusBadge.live(),
                  StatusBadge.replay(),
                ],
              ),
              const SizedBox(height: 32),

              Text('Interactive Pulsing Beacons', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              const Row(
                children: [
                  PulsingBeacon(color: ArgusTokens.accent, size: 8),
                  SizedBox(width: 24),
                  PulsingBeacon(color: ArgusTokens.success, size: 8),
                  SizedBox(width: 24),
                  PulsingBeacon(color: ArgusTokens.severityCritical, size: 8),
                  SizedBox(width: 24),
                  PulsingBeacon(color: ArgusTokens.severityMedium, size: 8),
                ],
              ),
              const SizedBox(height: 32),

              Text('Mouse Hover & Glow Spotlight Card', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              HoverCard(
                onTap: () {},
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hover Spotlight Card', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Text('Move your mouse over this card to observe the spring-interpolated radiant spotlight effect.', style: GoogleFonts.inter(color: ArgusTokens.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
