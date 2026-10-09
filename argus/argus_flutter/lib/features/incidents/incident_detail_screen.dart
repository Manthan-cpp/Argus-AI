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
import '../../core/util/preloaded_scenes.dart';
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
                              Row(
                                children: [
                                  const Icon(Icons.photo_camera_rounded, size: 16, color: ArgusTokens.accent),
                                  const SizedBox(width: 8),
                                  Text('Evidence Snapshot', style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600)),
                                ],
                              ),
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
                          Builder(
                            builder: (context) {
                              final evidenceMap = ref.watch(incidentEvidenceProvider);
                              final staticFrames = ref.watch(cameraStaticFrameProvider);
                              String? snapshotUrl = evidenceMap[widget.incidentId] ?? _detail?.evidenceUrl;
                              if (snapshotUrl == null || snapshotUrl.isEmpty) {
                                snapshotUrl = staticFrames[inc.cameraId];
                              }
                              if (snapshotUrl == null || snapshotUrl.isEmpty) {
                                snapshotUrl = getPreloadedSceneFrame(null);
                              }
                              return _buildEvidenceSnapshot(inc, snapshotUrl);
                            },
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

              // Context-Aware Telemetry Chart & Trigger Diagnostics
              _buildTelemetryCard(inc),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEvidenceSnapshot(Incident inc, String? snapshotUrl) {
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(ArgusTokens.radiusSm),
        border: Border.all(color: Colors.white12),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (snapshotUrl != null && snapshotUrl.isNotEmpty)
            Image.network(
              snapshotUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildSnapshotFallback(inc),
            )
          else
            _buildSnapshotFallback(inc),

          // Top Header HUD Overlay
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white24, width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.videocam_rounded, size: 12, color: Colors.cyanAccent),
                  const SizedBox(width: 6),
                  Text(
                    'CAMERA #${inc.cameraId}',
                    style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),

          // Zoom / Enlarge Button
          Positioned(
            top: 10,
            right: 10,
            child: InkWell(
              onTap: () {
                if (snapshotUrl != null && snapshotUrl.isNotEmpty) {
                  _showEnlargedSnapshot(snapshotUrl, inc);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.fullscreen_rounded, size: 16, color: Colors.white),
              ),
            ),
          ),

          // Bottom Timestamp
          Positioned(
            bottom: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'TRIGGER FRAME · ${inc.openedAt.toLocal().toString().substring(0, 19)}',
                style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.white70),
              ),
            ),
          ),

          // Bottom Privacy Badge
          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: ArgusTokens.accent.withValues(alpha: 0.6), width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_rounded, size: 11, color: ArgusTokens.accent),
                  const SizedBox(width: 5),
                  Text(
                    'HEAD REGION BLURRED',
                    style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.bold, color: ArgusTokens.accent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSnapshotFallback(Incident inc) {
    return Container(
      color: const Color(0xFF070A0F),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shield_outlined, size: 48, color: ArgusTokens.textTertiary),
            const SizedBox(height: 10),
            Text(
              'Evidence Frame · Incident #${inc.id}',
              style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white70),
            ),
            const SizedBox(height: 4),
            Text(
              'Encrypted JPEG · Head-Region Blurred by Pose Heuristics',
              style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
            ),
          ],
        ),
      ),
    );
  }

  void _showEnlargedSnapshot(String url, Incident inc) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 680),
          decoration: BoxDecoration(
            color: const Color(0xFF070A0F),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24, width: 1.5),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: ArgusTokens.bgRaised,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Evidence Inspection · Incident #${inc.id} (Camera #${inc.cameraId})',
                      style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18, color: Colors.white70),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Text('Failed to load image', style: TextStyle(color: Colors.white54)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTelemetryCard(Incident inc) {
    final summaryLower = inc.summary.toLowerCase();
    final isZoneBreach = summaryLower.contains('zone') || summaryLower.contains('entered') || summaryLower.contains('restricted');
    final isFall = summaryLower.contains('fall') || summaryLower.contains('down') || summaryLower.contains('motionless');
    final isCrowd = summaryLower.contains('crowd') || summaryLower.contains('surge') || summaryLower.contains('gathered') || summaryLower.contains('count');

    final String subtitle;
    final String metric1Label;
    final Color metric1Color;
    final String metric2Label;
    final Color metric2Color;
    final List<FlSpot> spots1;
    final List<FlSpot> spots2;

    if (isZoneBreach) {
      subtitle = 'Zone boundary breach probability & target velocity telemetry around trigger event (T = 0s).';
      metric1Label = 'Incursion Confidence (%)';
      metric1Color = ArgusTokens.severityCritical;
      metric2Label = 'Motion Velocity (%)';
      metric2Color = Colors.cyanAccent;
      spots1 = const [
        FlSpot(0, 0),
        FlSpot(2, 0),
        FlSpot(4, 8),
        FlSpot(6, 14),
        FlSpot(7.5, 35),
        FlSpot(8, 96),
        FlSpot(9, 95),
        FlSpot(11, 94),
        FlSpot(13, 98),
        FlSpot(15, 95),
      ];
      spots2 = const [
        FlSpot(0, 38),
        FlSpot(2, 42),
        FlSpot(4, 55),
        FlSpot(6, 68),
        FlSpot(8, 88),
        FlSpot(9, 62),
        FlSpot(11, 48),
        FlSpot(13, 52),
        FlSpot(15, 45),
      ];
    } else if (isFall) {
      subtitle = 'Postural collapse probability & motionless accumulation around impact event (T = 0s).';
      metric1Label = 'Fall Heuristic Score (%)';
      metric1Color = ArgusTokens.severityCritical;
      metric2Label = 'Motionless Accumulation (s)';
      metric2Color = Colors.amberAccent;
      spots1 = const [
        FlSpot(0, 6),
        FlSpot(3, 8),
        FlSpot(6, 15),
        FlSpot(7.5, 52),
        FlSpot(8, 94),
        FlSpot(9, 92),
        FlSpot(11, 88),
        FlSpot(13, 85),
        FlSpot(15, 82),
      ];
      spots2 = const [
        FlSpot(0, 0),
        FlSpot(7, 0),
        FlSpot(8, 12),
        FlSpot(9, 28),
        FlSpot(11, 58),
        FlSpot(13, 82),
        FlSpot(15, 100),
      ];
    } else if (isCrowd) {
      subtitle = 'Area occupancy count vs configured trigger limit around surge event (T = 0s).';
      metric1Label = 'Detected Occupancy (%)';
      metric1Color = Colors.cyanAccent;
      metric2Label = 'Threshold Limit (%)';
      metric2Color = ArgusTokens.severityCritical;
      spots1 = const [
        FlSpot(0, 20),
        FlSpot(3, 30),
        FlSpot(6, 50),
        FlSpot(8, 88),
        FlSpot(10, 95),
        FlSpot(12, 92),
        FlSpot(15, 85),
      ];
      spots2 = const [
        FlSpot(0, 75),
        FlSpot(5, 75),
        FlSpot(8, 75),
        FlSpot(11, 75),
        FlSpot(15, 75),
      ];
    } else {
      subtitle = 'Detection confidence & subject motion activity telemetry around trigger event (T = 0s).';
      metric1Label = 'Detection Confidence (%)';
      metric1Color = ArgusTokens.severityCritical;
      metric2Label = 'Subject Motion (%)';
      metric2Color = Colors.cyanAccent;
      spots1 = const [
        FlSpot(0, 10),
        FlSpot(3, 15),
        FlSpot(6, 25),
        FlSpot(8, 92),
        FlSpot(10, 94),
        FlSpot(12, 90),
        FlSpot(15, 88),
      ];
      spots2 = const [
        FlSpot(0, 35),
        FlSpot(3, 42),
        FlSpot(6, 62),
        FlSpot(8, 86),
        FlSpot(10, 52),
        FlSpot(12, 48),
        FlSpot(15, 42),
      ];
    }

    return Container(
      padding: const EdgeInsets.all(ArgusTokens.space20),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.show_chart_rounded, size: 18, color: ArgusTokens.accent),
                      const SizedBox(width: 8),
                      Text('Telemetry Timeline Around Trigger (±15s)', style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textTertiary)),
                ],
              ),
              // Legend Badges
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _buildLegendItem(metric1Color, metric1Label),
                  _buildLegendItem(metric2Color, metric2Label),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amberAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      'TRIGGER @ 0s',
                      style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 15,
                minY: 0,
                maxY: 100,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 25,
                  verticalInterval: 4,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: Colors.white.withValues(alpha: 0.08),
                    strokeWidth: 1,
                    dashArray: const [4, 4],
                  ),
                  getDrawingVerticalLine: (val) => FlLine(
                    color: Colors.white.withValues(alpha: 0.04),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: 1,
                      getTitlesWidget: (val, meta) {
                        switch (val.toInt()) {
                          case 0:
                            return const Padding(padding: EdgeInsets.only(top: 8), child: Text('-15s', style: TextStyle(color: Colors.white54, fontSize: 10)));
                          case 4:
                            return const Padding(padding: EdgeInsets.only(top: 8), child: Text('-8s', style: TextStyle(color: Colors.white54, fontSize: 10)));
                          case 8:
                            return const Padding(padding: EdgeInsets.only(top: 8), child: Text('TRIGGER (0s)', style: TextStyle(color: Colors.amberAccent, fontSize: 10, fontWeight: FontWeight.bold)));
                          case 11:
                            return const Padding(padding: EdgeInsets.only(top: 8), child: Text('+6s', style: TextStyle(color: Colors.white54, fontSize: 10)));
                          case 15:
                            return const Padding(padding: EdgeInsets.only(top: 8), child: Text('+15s', style: TextStyle(color: Colors.white54, fontSize: 10)));
                          default:
                            return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      interval: 25,
                      getTitlesWidget: (val, meta) {
                        if (val % 25 == 0 && val >= 0 && val <= 100) {
                          return Text('${val.toInt()}%', style: GoogleFonts.jetBrainsMono(color: Colors.white54, fontSize: 10));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.white12, width: 1),
                ),
                extraLinesData: ExtraLinesData(
                  verticalLines: [
                    VerticalLine(
                      x: 8,
                      color: Colors.amberAccent.withValues(alpha: 0.8),
                      strokeWidth: 1.5,
                      dashArray: const [4, 4],
                    ),
                  ],
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots1,
                    isCurved: true,
                    color: metric1Color,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [metric1Color.withValues(alpha: 0.22), Colors.transparent],
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: spots2,
                    isCurved: true,
                    color: metric2Color,
                    barWidth: 2,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [metric2Color.withValues(alpha: 0.12), Colors.transparent],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
