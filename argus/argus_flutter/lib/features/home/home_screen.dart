import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/tokens.dart';
import '../../core/copy/strings.dart';
import '../../core/widgets/hover_card.dart';
import '../../core/widgets/rainbow_moving_border.dart';
import '../../core/widgets/reveal_animation.dart';
import '../../data/repository_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _isSeeding = false;

  final List<_ScenarioCardData> _scenarios = [
    _ScenarioCardData(
      id: 'S1',
      title: 'After-hours Lab Entry',
      tag: 'ZONE + TIME',
      sentence: 'If anyone enters the lab after 8 pm, take a snapshot and alert the supervisor.',
      icon: Icons.meeting_room_outlined,
      color: ArgusTokens.accent,
      badgeColor: ArgusTokens.accent,
    ),
    _ScenarioCardData(
      id: 'S2',
      title: 'Stairway Fall & Motionless',
      tag: 'FALL + MOTIONLESS',
      sentence: 'If someone falls near the staircase and stays down for 15s, alert security and escalate.',
      icon: Icons.personal_injury_outlined,
      color: ArgusTokens.severityCritical,
      badgeColor: ArgusTokens.severityCritical,
    ),
    _ScenarioCardData(
      id: 'S3',
      title: 'Hazard Zone Intrusion',
      tag: 'DWELL TIME',
      sentence: 'If a person stays in the red zone for more than 5 seconds, create a high-severity incident.',
      icon: Icons.warning_amber_rounded,
      color: ArgusTokens.severityHigh,
      badgeColor: ArgusTokens.severityHigh,
    ),
    _ScenarioCardData(
      id: 'S4',
      title: 'PPE Helmet Non-compliance',
      tag: 'STRETCH · CLOUD VERIFIED',
      sentence: "If a person in the work zone isn't wearing a helmet, save evidence and alert site manager.",
      icon: Icons.construction_outlined,
      color: ArgusTokens.severityMedium,
      badgeColor: ArgusTokens.severityMedium,
    ),
  ];

  Future<void> _handleOpenDemo() async {
    setState(() => _isSeeding = true);
    final repo = ref.read(argusRepositoryProvider);
    await repo.seedDemo();
    if (mounted) {
      setState(() => _isSeeding = false);
      context.go('/app/monitor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1280),
          padding: const EdgeInsets.symmetric(horizontal: ArgusTokens.space24, vertical: ArgusTokens.space32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Section with Glow & Reveal
              _buildHeroSection(),

              const SizedBox(height: ArgusTokens.space48),

              // 2. Demo Scenarios Section
              _buildScenariosSection(),

              const SizedBox(height: ArgusTokens.space48),

              // 3. Privacy & Architectural Pillars
              _buildPrivacyPillars(),

              const SizedBox(height: ArgusTokens.space48),

              // 4. Honest Limits & Footer
              _buildLimitsAndFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return RevealAnimation(
      duration: const Duration(milliseconds: 650),
      child: RainbowMovingBorder(
        borderRadius: BorderRadius.circular(ArgusTokens.radiusLg),
        borderWidth: 1.5,
        baseBorderColor: ArgusTokens.borderStrong,
        backgroundColor: ArgusTokens.bgRaised,
        padding: const EdgeInsets.all(ArgusTokens.space32),
        isLive: true,
        duration: const Duration(seconds: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              // Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: ArgusTokens.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: ArgusTokens.accent.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, size: 14, color: ArgusTokens.accent),
                    const SizedBox(width: 6),
                    Text(
                      'SERVERPOD 4 HACKATHON ENTRY',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ArgusTokens.accent,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Main Headline
              Text(
                'Describe a safety rule.\nArgus watches, documents, and escalates.',
                style: GoogleFonts.sora(
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                  height: 1.15,
                  letterSpacing: -0.8,
                  color: ArgusTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Subtitle
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Text(
                  ArgusStrings.appTagline,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    height: 1.5,
                    color: ArgusTokens.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Action Buttons
              Wrap(
                spacing: 14,
                runSpacing: 14,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _isSeeding ? null : _handleOpenDemo,
                    icon: _isSeeding
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: ArgusTokens.accentInk),
                          )
                        : const Icon(Icons.play_arrow_rounded, size: 20),
                    label: Text(_isSeeding ? 'Seeding Demo...' : 'Open the Live Demo'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.go('/app/rules'),
                    icon: const Icon(Icons.edit_note_rounded, size: 18),
                    label: const Text('Compose a Rule'),
                  ),
                  TextButton.icon(
                    onPressed: () => context.go('/about'),
                    icon: const Icon(Icons.menu_book_rounded, size: 16, color: ArgusTokens.textSecondary),
                    label: Text(
                      'Methodology & Ethics',
                      style: GoogleFonts.inter(color: ArgusTokens.textSecondary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildScenariosSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 12,
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Demo Scenarios (S1–S4)',
                  style: GoogleFonts.sora(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: ArgusTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Four real repeatable benchmark tests with simulated and camera feeds.',
                  style: GoogleFonts.inter(fontSize: 14, color: ArgusTokens.textSecondary),
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: () => context.go('/app/lab'),
              icon: const Icon(Icons.analytics_outlined, size: 16),
              label: const Text('Detector Lab Metrics'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth > 900
                ? (constraints.maxWidth - 48) / 4
                : constraints.maxWidth > 600
                    ? (constraints.maxWidth - 16) / 2
                    : constraints.maxWidth;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _scenarios.map((s) {
                return SizedBox(
                  width: cardWidth,
                  child: RevealAnimation(
                    delay: Duration(milliseconds: 100 * _scenarios.indexOf(s)),
                    child: HoverCard(
                      onTap: () => context.go('/app/monitor'),
                      padding: const EdgeInsets.all(ArgusTokens.space20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: s.color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: s.color.withValues(alpha: 0.3)),
                                ),
                                child: Icon(s.icon, size: 18, color: s.color),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: s.badgeColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  s.id,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: s.badgeColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            s.title,
                            style: GoogleFonts.sora(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: ArgusTokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '"${s.sentence}"',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              height: 1.4,
                              fontStyle: FontStyle.italic,
                              color: ArgusTokens.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  'Simulate & Monitor',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: ArgusTokens.accent,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.arrow_forward_rounded, size: 14, color: ArgusTokens.accent),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPrivacyPillars() {
    final pillars = [
      _PillarData(
        title: 'On-Device WASM Inference',
        desc: 'People and body poses are computed entirely in the browser using MediaPipe. Video streams never leave the client.',
        icon: Icons.memory_rounded,
      ),
      _PillarData(
        title: 'Head-Blurred Evidence',
        desc: 'Stored snapshots automatically blur head and facial regions. Zero facial recognition or biometric identification.',
        icon: Icons.blur_on_rounded,
      ),
      _PillarData(
        title: 'Serverpod Decision Core',
        desc: 'Geometric facts feed Serverpod state machines in Postgres, managing multi-tier escalation and real-time streaming.',
        icon: Icons.hub_rounded,
      ),
      _PillarData(
        title: 'Opt-in Cloud Verification',
        desc: 'Gemini multimodal verification operates on small ephemeral crops only with explicit supervisory consent.',
        icon: Icons.shield_rounded,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(ArgusTokens.space24),
      decoration: BoxDecoration(
        color: ArgusTokens.bgRaised,
        borderRadius: BorderRadius.circular(ArgusTokens.radiusLg),
        border: Border.all(color: ArgusTokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy by Design & Architecture',
            style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth > 800 ? (constraints.maxWidth - 48) / 4 : constraints.maxWidth;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: pillars.map((p) {
                  return SizedBox(
                    width: w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(p.icon, color: ArgusTokens.accent, size: 22),
                        const SizedBox(height: 10),
                        Text(
                          p.title,
                          style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          p.desc,
                          style: GoogleFonts.inter(fontSize: 12, height: 1.4, color: ArgusTokens.textSecondary),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLimitsAndFooter() {
    return Container(
      padding: const EdgeInsets.all(ArgusTokens.space20),
      decoration: BoxDecoration(
        color: ArgusTokens.bgOverlay,
        borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
        border: Border.all(color: ArgusTokens.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 20, color: ArgusTokens.textSecondary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Honest Limits & Assistive Alerting Notice',
                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Argus is an assistive alerting tool, not a certified life-safety system. Detection heuristics are probabilistic and dependent on camera lighting and perspective. Incident logs undergo automated retention sweep after 7 days.',
                  style: GoogleFonts.inter(fontSize: 12, height: 1.45, color: ArgusTokens.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScenarioCardData {
  final String id;
  final String title;
  final String tag;
  final String sentence;
  final IconData icon;
  final Color color;
  final Color badgeColor;

  _ScenarioCardData({
    required this.id,
    required this.title,
    required this.tag,
    required this.sentence,
    required this.icon,
    required this.color,
    required this.badgeColor,
  });
}

class _PillarData {
  final String title;
  final String desc;
  final IconData icon;

  _PillarData({required this.title, required this.desc, required this.icon});
}
