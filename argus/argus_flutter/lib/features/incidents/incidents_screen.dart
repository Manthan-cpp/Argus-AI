import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:argus_client/argus_client.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/severity_scale.dart';
import '../../core/widgets/hover_card.dart';
import '../../core/widgets/rainbow_moving_border.dart';
import '../../core/widgets/reveal_animation.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/util/preloaded_scenes.dart';
import '../../data/repository_provider.dart';
import '../facilities/facility_providers.dart';

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
  StreamSubscription<IncidentUpdate>? _streamSub;

  @override
  void initState() {
    super.initState();
    _loadIncidents();
    _subscribeToIncidents();
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    super.dispose();
  }

  void _subscribeToIncidents() {
    final repo = ref.read(argusRepositoryProvider);
    _streamSub?.cancel();
    try {
      _streamSub = repo.watchIncidents().listen(
        (update) {
          if (!mounted) return;
          final activeWs = ref.read(activeFacilityProvider);
          if (activeWs != null && update.incident.workspaceId != activeWs.id) {
            return;
          }
          setState(() {
            final idx = _incidents.indexWhere((i) => i.id == update.incident.id);
            if (idx >= 0) {
              _incidents[idx] = update.incident;
            } else {
              _incidents.insert(0, update.incident);
            }
          });
        },
        onError: (_) {},
        cancelOnError: false,
      );
    } catch (_) {}
  }

  Future<void> _loadIncidents() async {
    final repo = ref.read(argusRepositoryProvider);
    final activeWs = ref.read(activeFacilityProvider);
    try {
      final list = await repo.listIncidents(workspaceId: activeWs?.id);
      if (mounted) {
        setState(() {
          _incidents = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Workspace?>(activeFacilityProvider, (prev, next) {
      if (prev?.id != next?.id) {
        _loadIncidents();
      }
    });

    final activeFacility = ref.watch(activeFacilityProvider);

    if (activeFacility == null) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(ArgusTokens.space32),
          decoration: BoxDecoration(
            color: ArgusTokens.bgRaised,
            borderRadius: BorderRadius.circular(ArgusTokens.radiusLg),
            border: Border.all(color: ArgusTokens.borderSubtle),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield_outlined, size: 48, color: ArgusTokens.textTertiary),
              const SizedBox(height: 16),
              Text(
                'No Active Facility Selected',
                textAlign: TextAlign.center,
                style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700, color: ArgusTokens.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Safety incidents belong to Facilities. Please select or join a Facility from the Operations Hub.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: ArgusTokens.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Return to Facilities Hub'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: ArgusTokens.accent));
    }

    final openCount = _incidents.where((i) => i.status == 'open').length;
    final ackCount = _incidents.where((i) => i.status == 'acknowledged').length;
    final fpCount = _incidents.where((i) => i.status == 'false_positive').length;

    // Calculate real median ack time from acknowledged incidents
    final ackDurations = _incidents
        .where((i) => i.ackedAt != null)
        .map((i) => i.ackedAt!.difference(i.openedAt).inSeconds)
        .where((sec) => sec >= 0)
        .toList()
      ..sort();

    String medianAckStr = '--';
    if (ackDurations.isNotEmpty) {
      final middle = ackDurations.length ~/ 2;
      final medianSec = ackDurations.length.isOdd
          ? ackDurations[middle]
          : ((ackDurations[middle - 1] + ackDurations[middle]) / 2).round();
      if (medianSec < 60) {
        medianAckStr = '${medianSec}s';
      } else {
        medianAckStr = '${(medianSec / 60).toStringAsFixed(1)}m';
      }
    }

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
                'Safety Incidents & Audit · ${activeFacility.name}',
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
                  _buildStatCard('MEDIAN ACK TIME', medianAckStr, ArgusTokens.accent, Icons.timer_outlined),
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
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.delete_sweep_outlined, size: 16, color: ArgusTokens.severityCritical),
                    label: Text(
                      'Clear All',
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: ArgusTokens.severityCritical),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ArgusTokens.severityCritical,
                      side: BorderSide(color: ArgusTokens.severityCritical.withValues(alpha: 0.6)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    onPressed: _incidents.isEmpty ? null : _confirmDeleteAll,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Incidents List / Empty State
              if (filtered.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                  decoration: BoxDecoration(
                    color: ArgusTokens.bgRaised,
                    borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
                    border: Border.all(color: ArgusTokens.borderSubtle),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 48, color: ArgusTokens.accent),
                      const SizedBox(height: 12),
                      Text(
                        'No Incidents Found',
                        style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _incidents.isEmpty
                            ? 'All safety channels clear. No active or historic alerts.'
                            : 'No incidents match the active status or severity filter.',
                        style: GoogleFonts.inter(fontSize: 13, color: ArgusTokens.textSecondary),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final inc = filtered[idx];
                    final sev = SeverityLevel.fromString(inc.severity);
                    final ageMins = DateTime.now().difference(inc.openedAt).inMinutes;

                    final isOpen = inc.status == 'open';

                    final cardContent = Row(
                      children: [
                        // Evidence Thumbnail
                        Builder(
                          builder: (context) {
                            final evidenceMap = ref.watch(incidentEvidenceProvider);
                            final staticFrames = ref.watch(cameraStaticFrameProvider);
                            final thumbUrl = evidenceMap[inc.id] ?? staticFrames[inc.cameraId] ?? getPreloadedSceneFrame(null);

                            return Container(
                              width: 80,
                              height: 60,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: ArgusTokens.borderSubtle),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    thumbUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => const Center(
                                      child: Icon(Icons.image_outlined, size: 24, color: ArgusTokens.textTertiary),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    right: 2,
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
                            );
                          },
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

                        // Quick Actions
                        if (isOpen) ...[
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
                          ),
                          const SizedBox(width: 8),
                        ],
                        OutlinedButton.icon(
                          onPressed: () => _confirmDeleteIncident(inc),
                          icon: const Icon(Icons.delete_outline_rounded, size: 16, color: ArgusTokens.severityCritical),
                          label: Text(
                            'Delete',
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: ArgusTokens.severityCritical),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ArgusTokens.severityCritical,
                            side: BorderSide(color: ArgusTokens.severityCritical.withValues(alpha: 0.6)),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right_rounded, color: ArgusTokens.textTertiary),
                      ],
                    );

                    return RevealAnimation(
                      delay: Duration(milliseconds: 50 * idx),
                      child: isOpen
                          ? InkWell(
                              onTap: () => context.go('/app/incidents/${inc.id}'),
                              borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
                              child: RainbowMovingBorder(
                                borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
                                borderWidth: 1.3,
                                baseBorderColor: Colors.white,
                                backgroundColor: ArgusTokens.bgRaised,
                                isLive: true,
                                padding: const EdgeInsets.all(ArgusTokens.space16),
                                child: cardContent,
                              ),
                            )
                          : HoverCard(
                              onTap: () => context.go('/app/incidents/${inc.id}'),
                              padding: const EdgeInsets.all(ArgusTokens.space16),
                              child: cardContent,
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

  Future<void> _confirmDeleteIncident(Incident inc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ArgusTokens.bgRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
          side: const BorderSide(color: ArgusTokens.borderSubtle),
        ),
        title: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: ArgusTokens.severityCritical, size: 22),
            const SizedBox(width: 8),
            Text(
              'Delete Incident #${inc.id}?',
              style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
            ),
          ],
        ),
        content: Text(
          'This will permanently delete this incident and its audit history from Argus.',
          style: GoogleFonts.inter(fontSize: 13, color: ArgusTokens.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: GoogleFonts.inter(color: ArgusTokens.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ArgusTokens.severityCritical,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && inc.id != null) {
      final repo = ref.read(argusRepositoryProvider);
      await repo.deleteIncident(inc.id!);
      _loadIncidents();
    }
  }

  Future<void> _confirmDeleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ArgusTokens.bgRaised,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
          side: const BorderSide(color: ArgusTokens.borderSubtle),
        ),
        title: Row(
          children: [
            const Icon(Icons.delete_sweep_outlined, color: ArgusTokens.severityCritical, size: 22),
            const SizedBox(width: 8),
            Text(
              'Delete All Incidents?',
              style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
            ),
          ],
        ),
        content: Text(
          'This will permanently remove all ${_incidents.length} safety incidents and associated events from the system.',
          style: GoogleFonts.inter(fontSize: 13, color: ArgusTokens.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: GoogleFonts.inter(color: ArgusTokens.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ArgusTokens.severityCritical,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(argusRepositoryProvider);
      final activeWs = ref.read(activeFacilityProvider);
      await repo.deleteAllIncidents(workspaceId: activeWs?.id);
      _loadIncidents();
    }
  }
}
