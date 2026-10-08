import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/tokens.dart';
import '../../core/widgets/reveal_animation.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 960),
          padding: const EdgeInsets.symmetric(horizontal: ArgusTokens.space24, vertical: ArgusTokens.space32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('About Argus & System Limits', style: GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Technical architecture, ethics, assistive alerting scope, and problem statement.', style: GoogleFonts.inter(fontSize: 14, color: ArgusTokens.textSecondary)),
              const SizedBox(height: 28),

              // The Problem & WHO Reference
              RevealAnimation(
                child: Container(
                  padding: const EdgeInsets.all(ArgusTokens.space24),
                  decoration: BoxDecoration(
                    color: ArgusTokens.bgRaised,
                    borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
                    border: Border.all(color: ArgusTokens.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.public_rounded, color: ArgusTokens.accent, size: 20),
                          const SizedBox(width: 10),
                          Text('The Human Problem: WHO Falls Data', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Falls alone are the second leading cause of unintentional injury deaths worldwide (~684,000 fatal falls per year, over 80% in low- and middle-income countries), according to the World Health Organization (WHO).\n\n'
                        'In warehouses, campus laboratories, and care facilities, CCTV cameras observe continuously but lack intelligent comprehension. Argus bridges this gap by enabling supervisors to express safety rules in plain English without cloud surveillance.',
                        style: GoogleFonts.inter(fontSize: 13, height: 1.55, color: ArgusTokens.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // What Argus IS and IS NOT
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(ArgusTokens.space20),
                      decoration: BoxDecoration(
                        color: ArgusTokens.bgRaised,
                        borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
                        border: Border.all(color: ArgusTokens.success.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('What Argus IS', style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700, color: ArgusTokens.success)),
                          const SizedBox(height: 10),
                          Text(
                            '• An assistive alerting workflow tool.\n'
                            '• On-device WASM inference protecting privacy.\n'
                            '• Serverpod reactive state machine evaluating plain English rules.\n'
                            '• Automated escalation via Future Calls.',
                            style: GoogleFonts.inter(fontSize: 13, height: 1.6, color: ArgusTokens.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(ArgusTokens.space20),
                      decoration: BoxDecoration(
                        color: ArgusTokens.bgRaised,
                        borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
                        border: Border.all(color: ArgusTokens.severityCritical.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('What Argus IS NOT', style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w700, color: ArgusTokens.severityCritical)),
                          const SizedBox(height: 10),
                          Text(
                            '• NOT a certified life-safety system.\n'
                            '• ZERO facial recognition or biometric identification.\n'
                            '• NO permanent cloud video recording.\n'
                            '• Does not guarantee 100% detection under all lighting.',
                            style: GoogleFonts.inter(fontSize: 13, height: 1.6, color: ArgusTokens.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // AI Disclosure & Hackathon Note
              Container(
                padding: const EdgeInsets.all(ArgusTokens.space20),
                decoration: BoxDecoration(
                  color: ArgusTokens.bgOverlay,
                  borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
                  border: Border.all(color: ArgusTokens.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI Assistance & Hackathon Disclosure', style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(
                      'This project was built for "Build Something Real: The Serverpod Hackathon".\n'
                      'Code generation, architectural structuring, and test authoring were performed in pairing with Google Antigravity.\n'
                      'Rule interpretation and optional verification leverage Google Gemini API in accordance with terms.',
                      style: GoogleFonts.inter(fontSize: 12, height: 1.5, color: ArgusTokens.textTertiary),
                    ),
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
