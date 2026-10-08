import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:argus_client/argus_client.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/severity_scale.dart';
import '../../core/widgets/hover_card.dart';
import '../../core/widgets/reveal_animation.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/repository_provider.dart';

class IncidentsScreen extends ConsumerStatefulWidget {
  const IncidentsScreen({super.key});

  @override
  ConsumerState<IncidentsScreen> createState() => _IncidentsScreenState();
}

class _IncidentsScreenState extends ConsumerState<IncidentsScreen> {
  List<Incident> _incidents = [];
  bool _isLoading = true;
  String _selectedStatusFilter = 'ALL';
  String _selectedSeverityFilter = 'ALL';

  @override
  void initState() {
    super.initState();
    _loadIncidents();
  }

  Future<void> _loadIncidents() async {
    final repo = ref.read(argusRepositoryProvider);
    final list = await repo.listIncidents();
    if (mounted) {
      setState(() {
        _incidents = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: ArgusTokens.accent));
    }

    final openCount = _incidents.where((i) => i.status == 'open').length;
    final ackCount = _incidents.where((i) => i.status == 'acknowledged').length;
    final fpCount = _incidents.where((i) => i.status == 'false_positive').length;

    final filtered = _incidents.where((i) {
      if (_selectedStatusFilter != 'ALL' && i.status.toUpperCase() != _selectedStatusFilter) return false;
      if (_selectedSeverityFilter != 'ALL' && i.severity.toUpperCase() != _selectedSeverityFilter) return false;
      return true;
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1240),
          padding: const EdgeInsets.symmetric(horizontal: ArgusTokens.space24, vertical: ArgusTokens.space32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Safety Incidents & Audit',
                style: GoogleFonts.sora(fontSize: 26, fontWeight: FontWeight.w700, color: ArgusTokens.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Audit, acknowledge, and resolve real-time events captured with blurred privacy snapshots.',
                style: GoogleFonts.inter(fontSize: 14, color: ArgusTokens.textSecondary),
              ),
              const SizedBox(height: 24),

              // Stats Strip
              Row(
                children: [
                  _buildStatCard('OPEN INCIDENTS', '$openCount', ArgusTokens.severityCritical, Icons.error_outline_rounded),
                  const SizedBox(width: 12),
                  _buildStatCard('ACKNOWLEDGED', '$ackCount', ArgusTokens.statusAcknowledged, Icons.visibility_outlined),
                  const SizedBox(width: 12),
                  _buildStatCard('MEDIAN ACK TIME', '42s', ArgusTokens.accent, Icons.timer_outlined),
                  const SizedBox(width: 12),
                  _buildStatCard('FALSE POSITIVE RATE', '${((fpCount / (_incidents.isEmpty ? 1 : _incidents.length)) * 100).toInt()}%', ArgusTokens.textSecondary, Icons.tune_rounded),
                ],
              ),
              const SizedBox(height: 24),

              // Filter Controls
              Row(
                children: [
                  _buildFilterChip('ALL STATUS', _selectedStatusFilter == 'ALL', () => setState(() => _selectedStatusFilter = 'ALL')),
                  const SizedBox(width: 8),
                  _buildFilterChip('OPEN', _selectedStatusFilter == 'OPEN', () => setState(() => _selectedStatusFilter = 'OPEN')),
                  const SizedBox(width: 8),
                  _buildFilterChip('ACKNOWLEDGED', _selectedStatusFilter == 'ACKNOWLEDGED', () => setState(() => _selectedStatusFilter = 'ACKNOWLEDGED')),
                  const SizedBox(width: 8),
                  _buildFilterChip('RESOLVED', _selectedStatusFilter == 'RESOLVED', () => setState(() => _selectedStatusFilter = 'RESOLVED')),
                  const Spacer(),
                  _buildFilterChip('CRITICAL ONLY', _selectedSeverityFilter == 'CRITICAL', () {
                    setState(() {
                      _selectedSeverityFilter = _selectedSeverityFilter == 'CRITICAL' ? 'ALL' : 'CRITICAL';
                    });
                  }),
                ],
              ),
              const SizedBox(height: 18),

              // Incidents List
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, idx) {
                  final inc = filtered[idx];
                  final sev = SeverityLevel.fromString(inc.severity);
                  final ageMins = DateTime.now().difference(inc.openedAt).inMinutes;

                  return RevealAnimation(
                    delay: Duration(milliseconds: 50 * idx),
                    child: HoverCard(
                      onTap: () => context.go('/app/incidents/${inc.id}'),
                      padding: const EdgeInsets.all(ArgusTokens.space16),
                      child: Row(
                        children: [
                          // Evidence Thumbnail
                          Container(
                            width: 80,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: ArgusTokens.borderSubtle),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(Icons.image_outlined, size: 24, color: ArgusTokens.textTertiary),
                                Positioned(
                                  bottom: 2,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: Text(
                                      'BLURRED',
                                      style: GoogleFonts.jetBrainsMono(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Summary Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    StatusBadge.fromSeverity(sev),
                                    const SizedBox(width: 8),
                                    StatusBadge.fromStatus(inc.status),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${ageMins}m ago · Camera #${inc.cameraId}',
                                      style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textTertiary),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  inc.summary,
                                  style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
                                ),
                              ],
                            ),
                          ),

                          // Quick Action
                          if (inc.status == 'open')
                            ElevatedButton(
                              onPressed: () async {
                                final repo = ref.read(argusRepositoryProvider);
                                await repo.acknowledge(inc.id!);
                                _loadIncidents();
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              ),
                              child: const Text('Acknowledge'),
                            )
                          else
                            const Icon(Icons.chevron_right_rounded, color: ArgusTokens.textTertiary),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(ArgusTokens.space16),
        decoration: BoxDecoration(
          color: ArgusTokens.bgRaised,
          borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
          border: Border.all(color: ArgusTokens.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: ArgusTokens.textTertiary),
                ),
                Icon(icon, size: 16, color: color),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.jetBrainsMono(fontSize: 22, fontWeight: FontWeight.w700, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ArgusTokens.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? ArgusTokens.accent.withValues(alpha: 0.15) : ArgusTokens.bgOverlay,
          borderRadius: BorderRadius.circular(ArgusTokens.radiusSm),
          border: Border.all(
            color: isSelected ? ArgusTokens.accent.withValues(alpha: 0.6) : ArgusTokens.borderSubtle,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? ArgusTokens.accent : ArgusTokens.textSecondary,
          ),
        ),
      ),
    );
  }
}
