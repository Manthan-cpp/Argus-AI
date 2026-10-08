import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:argus_client/argus_client.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/severity_scale.dart';
import '../../core/widgets/rainbow_moving_border.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/repository_provider.dart';

class IncidentDetailScreen extends ConsumerStatefulWidget {
  final int incidentId;

  const IncidentDetailScreen({super.key, required this.incidentId});

  @override
  ConsumerState<IncidentDetailScreen> createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends ConsumerState<IncidentDetailScreen> {
  IncidentDetail? _detail;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final repo = ref.read(argusRepositoryProvider);
    try {
      final d = await repo.getIncident(widget.incidentId);
      if (mounted) setState(() { _detail = d; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAction(String action) async {
    final repo = ref.read(argusRepositoryProvider);
    if (action == 'ack') {
      await repo.acknowledge(widget.incidentId);
    } else if (action == 'resolve') {
      await repo.resolve(widget.incidentId);
    } else if (action == 'false_positive') {
      await repo.markFalsePositive(widget.incidentId);
    }
    _loadDetail();
  }

  Future<void> _confirmDelete() async {
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
              'Delete Incident #${widget.incidentId}?',
              style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
            ),
          ],
        ),
        content: Text(
          'This will permanently delete this incident and its history from Argus.',
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

    if (confirmed == true && mounted) {
      final repo = ref.read(argusRepositoryProvider);
      await repo.deleteIncident(widget.incidentId);
      if (mounted) context.go('/app/incidents');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: ArgusTokens.accent));
    }

    if (_detail == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, size: 40, color: ArgusTokens.textTertiary),
            const SizedBox(height: 12),
            Text('Incident #${widget.incidentId} not found.', style: GoogleFonts.sora(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: () => context.go('/app/incidents'), child: const Text('Back to Incidents')),
          ],
        ),
      );
    }

    final inc = _detail!.incident;
    final sev = SeverityLevel.fromString(inc.severity);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1100),
          padding: const EdgeInsets.symmetric(horizontal: ArgusTokens.space24, vertical: ArgusTokens.space32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back Breadcrumb & Actions
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, size: 20, color: ArgusTokens.textSecondary),
                    onPressed: () => context.go('/app/incidents'),
                  ),
                  const SizedBox(width: 8),
                  Text('Incident #${inc.id}', style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 12),
                  StatusBadge.fromSeverity(sev),
                  const SizedBox(width: 8),
                  StatusBadge.fromStatus(inc.status),
                  const Spacer(),
                  if (inc.status == 'open') ...[
                    ElevatedButton.icon(
                      onPressed: () => _handleAction('ack'),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Acknowledge'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (inc.status != 'resolved') ...[
                    OutlinedButton.icon(
                      onPressed: () => _handleAction('resolve'),
                      icon: const Icon(Icons.done_all_rounded, size: 16),
                      label: const Text('Resolve'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (inc.status != 'false_positive') ...[
                    TextButton.icon(
                      onPressed: () => _handleAction('false_positive'),
                      icon: const Icon(Icons.flag_outlined, size: 16, color: ArgusTokens.severityCritical),
                      label: Text('False Positive', style: GoogleFonts.inter(color: ArgusTokens.severityCritical)),
                    ),
                    const SizedBox(width: 8),
                  ],
                  OutlinedButton.icon(
                    onPressed: _confirmDelete,
                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: ArgusTokens.severityCritical),
                    label: Text('Delete', style: GoogleFonts.inter(color: ArgusTokens.severityCritical)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: ArgusTokens.severityCritical.withValues(alpha: 0.4)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Summary Card
              inc.status == 'open'
                  ? RainbowMovingBorder(
                      borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
                      borderWidth: 1.5,
                      baseBorderColor: Colors.white,
                      backgroundColor: ArgusTokens.bgRaised,
                      padding: const EdgeInsets.all(ArgusTokens.space20),
                      isLive: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(inc.summary, style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text(
                            'Opened: ${inc.openedAt.toLocal().toString().substring(0, 19)} · Camera #${inc.cameraId} · Assigned: ${inc.assignedTo ?? "Unassigned"}',
                            style: GoogleFonts.inter(fontSize: 13, color: ArgusTokens.textTertiary),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.all(ArgusTokens.space20),
                      decoration: BoxDecoration(
                        color: ArgusTokens.bgRaised,
                        borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
                        border: Border.all(color: ArgusTokens.borderSubtle),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(inc.summary, style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text(
                            'Opened: ${inc.openedAt.toLocal().toString().substring(0, 19)} · Camera #${inc.cameraId} · Assigned: ${inc.assignedTo ?? "Unassigned"}',
                            style: GoogleFonts.inter(fontSize: 13, color: ArgusTokens.textTertiary),
                          ),
                        ],
                      ),
                    ),
              const SizedBox(height: 20),

              // Split View: Evidence & Verification Card
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Blurred Evidence Snapshot
                  Expanded(
                    flex: 5,
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
                              Text('Evidence Snapshot', style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: ArgusTokens.borderSubtle),
                                ),
                                child: Text('HEAD BLURRED', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: ArgusTokens.accent)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 240,
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(ArgusTokens.radiusSm),
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(Icons.shield_outlined, size: 64, color: ArgusTokens.textTertiary),
                                Positioned(
                                  bottom: 12,
                                  child: Text(
                                    'Encrypted JPEG · Head-Region Blurred by Pose Heuristics',
                                    style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Right: Verification & Cloud Status
                  Expanded(
                    flex: 5,
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
                            children: [
                              const Icon(Icons.auto_awesome_rounded, size: 16, color: ArgusTokens.accent),
                              const SizedBox(width: 8),
                              Text('Multimodal Verification', style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ArgusTokens.bgOverlay,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Status: ${inc.verification.status.toUpperCase()}', style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.bold, color: ArgusTokens.accent)),
                                const SizedBox(height: 6),
                                Text(
                                  inc.verification.reason ?? 'No cloud verification was requested for this rule trigger. Evaluated on-device.',
                                  style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text('Event Timeline Audit', style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          for (final ev in _detail!.events) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ev.at.toLocal().toString().substring(11, 19),
                                    style: GoogleFonts.jetBrainsMono(fontSize: 10, color: ArgusTokens.textTertiary),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${ev.kind.toUpperCase()}: ${ev.detail}',
                                      style: GoogleFonts.inter(fontSize: 11, color: ArgusTokens.textPrimary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Signal Telemetry Chart (fl_chart)
              Container(
                padding: const EdgeInsets.all(ArgusTokens.space20),
                decoration: BoxDecoration(
                  color: ArgusTokens.bgRaised,
                  borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
                  border: Border.all(color: ArgusTokens.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Telemetry Around Trigger Event (±15s)', style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text('Fall score, motionless accumulation, and person counts.', style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textTertiary)),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 160,
                      child: LineChart(
                        LineChartData(
                          gridData: const FlGridData(show: false),
                          titlesData: const FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 0.1),
                                FlSpot(3, 0.1),
                                FlSpot(6, 0.85),
                                FlSpot(9, 0.92),
                                FlSpot(12, 0.90),
                                FlSpot(15, 0.88),
                              ],
                              isCurved: true,
                              color: ArgusTokens.severityCritical,
                              barWidth: 3,
                              dotData: const FlDotData(show: false),
                            ),
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 0.0),
                                FlSpot(5, 0.0),
                                FlSpot(7, 0.4),
                                FlSpot(10, 0.7),
                                FlSpot(13, 1.0),
                                FlSpot(15, 1.0),
                              ],
                              isCurved: true,
                              color: ArgusTokens.accent,
                              barWidth: 2,
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                        ),
                      ),
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
