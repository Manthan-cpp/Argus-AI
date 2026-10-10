import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:argus_client/argus_client.dart';
import '../../app/theme/tokens.dart';
import '../../core/widgets/auth_required_barrier.dart';
import '../../core/widgets/hover_card.dart';
import '../facilities/create_facility_dialog.dart';
import '../facilities/facility_providers.dart';
import '../facilities/join_facility_dialog.dart';
import '../rooms/room_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final currentUser = userAsync.valueOrNull;

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: ArgusTokens.bgBase,
        body: AuthRequiredBarrier(
          description:
              'Sign in or register an account to manage your security facilities, CCTV cameras, and tactical dispatch stations.',
        ),
      );
    }

    final facilitiesAsync = ref.watch(userFacilitiesProvider);

    return Scaffold(
      backgroundColor: ArgusTokens.bgBase,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ArgusTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header & Hub Controls
            _buildHeader(context, currentUser),
            const SizedBox(height: ArgusTokens.space24),

            // Facilities Section Header
            Row(
              children: [
                const Icon(Icons.apartment_rounded, size: 18, color: ArgusTokens.accent),
                const SizedBox(width: 8),
                Text(
                  'Secured Facilities',
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: ArgusTokens.textPrimary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Select a facility console to manage cameras, rules, and dispatch',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: ArgusTokens.textTertiary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: ArgusTokens.space12),

            // Facilities Grid / Empty State
            facilitiesAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Container(
                padding: const EdgeInsets.all(ArgusTokens.space24),
                decoration: BoxDecoration(
                  color: ArgusTokens.bgRaised,
                  borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
                  border: Border.all(color: ArgusTokens.severityCritical.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: ArgusTokens.severityCritical),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Failed to load facilities: $err',
                          style: GoogleFonts.inter(color: ArgusTokens.textPrimary)),
                    ),
                    TextButton(
                      onPressed: () => ref.invalidate(userFacilitiesProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (facilities) {
                if (facilities.isEmpty) {
                  return _buildEmptyState(context, currentUser);
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 440,
                    mainAxisExtent: 290,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: facilities.length,
                  itemBuilder: (context, idx) {
                    final fac = facilities[idx];
                    return _buildFacilityCard(context, fac, currentUser);
                  },
                );
              },
            ),

            const SizedBox(height: ArgusTokens.space32),

            // How Argus Works / Step-by-Step Production Guide
            _buildOperationalGuide(context),
            const SizedBox(height: ArgusTokens.space24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProfile currentUser) {
    return Container(
      padding: const EdgeInsets.all(ArgusTokens.space24),
      decoration: BoxDecoration(
        color: ArgusTokens.bgRaised,
        borderRadius: BorderRadius.circular(ArgusTokens.radiusLg),
        border: Border.all(color: ArgusTokens.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ArgusTokens.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ArgusTokens.accent.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.home_filled, color: ArgusTokens.accent, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Home — Facility Operations Command',
                            style: GoogleFonts.sora(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: ArgusTokens.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Select or deploy a security facility to command CCTV cameras, AI rules, and dispatch',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: ArgusTokens.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Signed in as:',
                      style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textTertiary),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: ArgusTokens.bgOverlay,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ArgusTokens.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.person_rounded, size: 14, color: ArgusTokens.accent),
                          const SizedBox(width: 6),
                          Text(
                            currentUser.fullName,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: ArgusTokens.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () => JoinFacilityDialog.show(context, currentUser),
                icon: const Icon(Icons.vpn_key_rounded, size: 16),
                label: const Text('Join Facility'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ArgusTokens.textPrimary,
                  side: const BorderSide(color: ArgusTokens.borderSubtle),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => CreateFacilityDialog.show(context, currentUser),
                icon: const Icon(Icons.add_business_rounded, size: 18),
                label: const Text('Create Facility'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ArgusTokens.accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, UserProfile currentUser) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: ArgusTokens.bgRaised,
        borderRadius: BorderRadius.circular(ArgusTokens.radiusLg),
        border: Border.all(color: ArgusTokens.borderSubtle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ArgusTokens.bgOverlay,
              shape: BoxShape.circle,
              border: Border.all(color: ArgusTokens.borderSubtle),
            ),
            child: const Icon(Icons.apartment_outlined, size: 40, color: ArgusTokens.textTertiary),
          ),
          const SizedBox(height: 18),
          Text(
            'No Active Facilities in Your Account',
            style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'You haven\'t created or joined any facilities yet. Create a facility for your school, campus, or facility, or join with an invite code.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: ArgusTokens.textSecondary),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () => JoinFacilityDialog.show(context, currentUser),
                icon: const Icon(Icons.vpn_key_rounded, size: 16),
                label: const Text('Join Facility with Code'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ArgusTokens.textPrimary,
                  side: const BorderSide(color: ArgusTokens.borderSubtle),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => CreateFacilityDialog.show(context, currentUser),
                icon: const Icon(Icons.add_business_rounded, size: 18),
                label: const Text('Create New Facility'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ArgusTokens.accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityCard(BuildContext context, Workspace fac, UserProfile currentUser) {
    final isOwner = fac.ownerUserId.toLowerCase() == currentUser.fullName.toLowerCase();
    final isOrganizer = isOwner || fac.organizerCode.isNotEmpty;
    final isSupervisor = !isOrganizer && fac.supervisorCode.isNotEmpty;

    String roleLabel = 'GUARD';
    if (isOrganizer) {
      roleLabel = 'ORGANIZER';
    } else if (isSupervisor) {
      roleLabel = 'SUPERVISOR';
    }

    return HoverCard(
      padding: const EdgeInsets.all(ArgusTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Role Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0x1AFFFFFF),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: const Color(0x33FFFFFF)),
                ),
                child: Text(
                  roleLabel,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE2E8F0),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Facility Name
          Text(
            fac.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.sora(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: ArgusTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 4),

          // Description
          Text(
            fac.description ?? 'Secured physical facility with automated vision AI surveillance.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: ArgusTokens.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),

          // Invite Codes / Access Chips
          if (isOrganizer) ...[
            Text('Invite Codes:', style: GoogleFonts.jetBrainsMono(fontSize: 9, color: ArgusTokens.textTertiary)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildCodeChip(context, 'ORG', fac.organizerCode),
                _buildCodeChip(context, 'SUP', fac.supervisorCode),
                _buildCodeChip(context, 'GRD', fac.guardCode),
              ],
            ),
          ] else if (isSupervisor) ...[
            Text('Invite Codes:', style: GoogleFonts.jetBrainsMono(fontSize: 9, color: ArgusTokens.textTertiary)),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildCodeChip(context, 'SUP', fac.supervisorCode),
                _buildCodeChip(context, 'GRD', fac.guardCode),
              ],
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0x12FFFFFF),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: const Color(0x26FFFFFF)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_rounded, size: 12, color: ArgusTokens.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'GUARD ACCESS CLEARANCE',
                    style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.w600, color: ArgusTokens.textSecondary),
                  ),
                ],
              ),
            ),
          ],

          const Spacer(),

          // Enter Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ref.read(activeFacilityProvider.notifier).state = fac;
                context.go('/app/monitor');
              },
              icon: const Icon(Icons.arrow_forward_rounded, size: 15),
              label: const Text('Enter Facility Console'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ArgusTokens.accent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 10),
                textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodeChip(BuildContext context, String label, String code) {
    const chipColor = Color(0xFFCBD5E1);
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: code));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label Code "$code" copied to clipboard!'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0x12FFFFFF),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0x26FFFFFF)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: $code',
              style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.w700, color: chipColor),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.copy_rounded, size: 10, color: chipColor),
          ],
        ),
      ),
    );
  }

  Widget _buildOperationalGuide(BuildContext context) {
    const steps = [
      _WorkflowStep(
        stepNumber: '01',
        title: 'Deploy or Join Facility',
        icon: Icons.domain_rounded,
        description:
            'Create a sovereign facility workspace (e.g. school campus, hospital, or commercial site). Invite team members with role-based codes (Organizer, Supervisor, or Guard) that enforce cryptographic permission boundaries.',
      ),
      _WorkflowStep(
        stepNumber: '02',
        title: 'Connect CCTV & Video Feeds',
        icon: Icons.videocam_rounded,
        description:
            'Link live network cameras or upload pre-recorded surveillance videos. Configure custom polygon detection zones directly on camera frames to monitor doors, restricted perimeters, and transit paths.',
      ),
      _WorkflowStep(
        stepNumber: '03',
        title: 'Author Vision AI Rules',
        icon: Icons.psychology_alt_rounded,
        description:
            'Formulate sovereign edge vision rules in plain text (e.g., "If someone falls and stays down for more than 2 seconds, alert supervisor"). The deterministic grammar engine evaluates signals in real-time.',
      ),
      _WorkflowStep(
        stepNumber: '04',
        title: 'Monitor & Tactical Dispatch',
        icon: Icons.hub_rounded,
        description:
            'Triggered incidents instantly ping dedicated tactical dispatch rooms. Review high-resolution visual evidence, chat in real-time with on-duty guards, and resolve alerts with full audit integrity.',
      ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(ArgusTokens.space24),
      decoration: BoxDecoration(
        color: ArgusTokens.bgRaised,
        borderRadius: BorderRadius.circular(ArgusTokens.radiusLg),
        border: Border.all(color: ArgusTokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ArgusTokens.bgOverlay,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ArgusTokens.borderSubtle),
                ),
                child: const Icon(Icons.explore_rounded, color: ArgusTokens.textPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Operational Architecture & Getting Started',
                      style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ArgusTokens.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'How to operate your sovereign facility surveillance and dispatch workflow',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: ArgusTokens.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              final crossAxisCount = isWide ? 4 : (constraints.maxWidth >= 540 ? 2 : 1);

              if (crossAxisCount == 4) {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (int i = 0; i < steps.length; i++) ...[
                        if (i > 0) const SizedBox(width: 16),
                        Expanded(child: _buildStepCard(steps[i])),
                      ],
                    ],
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  mainAxisExtent: 220,
                ),
                itemCount: steps.length,
                itemBuilder: (context, i) => _buildStepCard(steps[i]),
              );
            },
          ),
          const SizedBox(height: 20),
          // System Guarantees & Features Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: ArgusTokens.bgOverlay,
              borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
              border: Border.all(color: ArgusTokens.borderSubtle),
            ),
            child: Wrap(
              spacing: 24,
              runSpacing: 10,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _buildSecurityPill(Icons.security_rounded, '100% On-Premise Sovereign Privacy'),
                _buildSecurityPill(Icons.lock_outline_rounded, 'Multi-Tenant Role-Isolated Channels'),
                _buildSecurityPill(Icons.timer_outlined, '30s Intelligent Alert Deduplication'),
                _buildSecurityPill(Icons.shield_outlined, 'Deterministic AI Vision Execution'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(_WorkflowStep step) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ArgusTokens.bgOverlay,
        borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
        border: Border.all(color: ArgusTokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: ArgusTokens.bgRaised,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: ArgusTokens.borderSubtle),
                ),
                child: Text(
                  'STEP ${step.stepNumber}',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: ArgusTokens.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              Icon(step.icon, size: 18, color: ArgusTokens.accent),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            step.title,
            style: GoogleFonts.sora(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ArgusTokens.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            step.description,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: ArgusTokens.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityPill(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: ArgusTokens.accent),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: ArgusTokens.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _WorkflowStep {
  final String stepNumber;
  final String title;
  final IconData icon;
  final String description;

  const _WorkflowStep({
    required this.stepNumber,
    required this.title,
    required this.icon,
    required this.description,
  });
}
