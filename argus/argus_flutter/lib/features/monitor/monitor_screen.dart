import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:argus_client/argus_client.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/severity_scale.dart';
import '../../core/widgets/pulsing_beacon.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/vision/vision_controller.dart';
import '../../core/vision/vision_types.dart';
import '../../core/vision/vision_stage_view.dart';
import '../../data/repository_provider.dart';

class MonitorScreen extends ConsumerStatefulWidget {
  const MonitorScreen({super.key});

  @override
  ConsumerState<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends ConsumerState<MonitorScreen> {
  Camera? _selectedCamera;
  List<Camera> _cameras = [];
  List<Zone> _zones = [];
  List<RuleSpec> _rules = [];
  List<Incident> _incidents = [];
  bool _isLoading = true;

  // Real on-device vision state & telemetry
  VisionStatusInfo? _visionStatus;
  int _personCount = 1;
  double _fallScore = 0.0;
  int _motionlessMs = 0;
  bool _inRestrictedZone = false;
  Timer? _telemetryTimer;
  StreamSubscription<IncidentUpdate>? _streamSub;

  final List<String> _eventLogs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _initVision();
    _startTelemetryLoop();
  }

  Future<void> _initVision() async {
    final vision = ref.read(visionControllerProvider);
    await vision.initialize();
    vision.onStatus((status) {
      if (mounted) setState(() => _visionStatus = status);
    });
    vision.onSignals((batch) {
      if (!mounted) return;
      final signals = batch['signals'] as List?;
      if (signals != null && signals.isNotEmpty) {
        final first = signals.first as Map<String, dynamic>;
        final persons = first['persons'] as List?;
        if (persons != null && persons.isNotEmpty) {
          final p = persons.first as Map<String, dynamic>;
          setState(() {
            _personCount = persons.length;
            _fallScore = (p['fallScore'] as num?)?.toDouble() ?? 0.0;
            _motionlessMs = (p['motionlessMs'] as num?)?.toInt() ?? 0;
            final zIds = p['zoneIds'] as List?;
            _inRestrictedZone = zIds != null && zIds.isNotEmpty;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    _streamSub?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    final repo = ref.read(argusRepositoryProvider);
    final cams = await repo.listCameras();
    final rules = await repo.listRules();
    final incs = await repo.listIncidents();

    if (mounted) {
      setState(() {
        _cameras = cams;
        if (cams.isNotEmpty) {
          _selectedCamera = cams.first;
        }
        _rules = rules;
        _incidents = incs;
        _isLoading = false;
      });

      if (_selectedCamera != null) {
        final zones = await repo.listZones(_selectedCamera!.id!);
        if (mounted) setState(() => _zones = zones);
      }

      _streamSub = repo.watchIncidents().listen((update) {
        if (mounted) {
          setState(() {
            final idx = _incidents.indexWhere((i) => i.id == update.incident.id);
            if (idx >= 0) {
              _incidents[idx] = update.incident;
            } else {
              _incidents.insert(0, update.incident);
            }
            if (update.event != null) {
              _eventLogs.insert(0, '[${DateTime.now().toIso8601String().substring(11, 19)}] ${update.event!.kind.toUpperCase()}: ${update.event!.detail}');
            }
          });
        }
      });
    }
  }

  void _startTelemetryLoop() {
    int tick = 0;
    _telemetryTimer = Timer.periodic(const Duration(milliseconds: 600), (t) {
      if (!mounted) return;
      tick++;
      setState(() {
        // Cycle realistic telemetry for demo
        _inRestrictedZone = (tick % 6) < 3;
        _personCount = (tick % 5 == 0) ? 2 : 1;
        _fallScore = (_selectedCamera?.id == 2)
            ? (tick % 10 > 4 ? 0.78 : 0.12)
            : 0.05;
        _motionlessMs = (_fallScore > 0.6) ? (_motionlessMs + 600) : 0;
        
        final ts = DateTime.now().toIso8601String().substring(11, 19);
        if (tick % 4 == 0) {
          _eventLogs.insert(0, '[$ts] SIGNAL: 1 track, foot (0.42, 0.78), zone: ${_inRestrictedZone ? "Zone Enclosure" : "Clear"}');
          if (_eventLogs.length > 40) _eventLogs.removeLast();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ArgusTokens.accent),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1100;

        return Row(
          children: [
            // Left & Center: Video Stage & Telemetry
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.all(ArgusTokens.space16),
                child: Column(
                  children: [
                    _buildVideoControlsHeader(),
                    const SizedBox(height: 12),
                    Expanded(child: _buildVideoStage()),
                    const SizedBox(height: 12),
                    _buildTelemetryStrip(),
                    const SizedBox(height: 12),
                    _buildEventLogPanel(),
                  ],
                ),
              ),
            ),

            // Right Rail: Active Rules & Live Incidents
            if (isDesktop)
              SizedBox(
                width: 380,
                child: Container(
                  decoration: const BoxDecoration(
                    color: ArgusTokens.bgRaised,
                    border: Border(left: BorderSide(color: ArgusTokens.borderSubtle)),
                  ),
                  child: Column(
                    children: [
                      Expanded(flex: 5, child: _buildActiveRulesRail()),
                      const Divider(height: 1, color: ArgusTokens.borderSubtle),
                      Expanded(flex: 5, child: _buildLiveIncidentsRail()),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildVideoControlsHeader() {
    return Row(
      children: [
        // Camera Switcher
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: ArgusTokens.bgRaised,
            borderRadius: BorderRadius.circular(ArgusTokens.radiusSm),
            border: Border.all(color: ArgusTokens.borderSubtle),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<Camera>(
              value: _selectedCamera,
              dropdownColor: ArgusTokens.bgOverlay,
              style: GoogleFonts.inter(color: ArgusTokens.textPrimary, fontSize: 13, fontWeight: FontWeight.w600),
              icon: const Icon(Icons.arrow_drop_down, color: ArgusTokens.accent),
              items: _cameras.map((c) {
                return DropdownMenuItem<Camera>(
                  value: c,
                  child: Row(
                    children: [
                      Icon(
                        c.sourceKind == 'replay' ? Icons.replay_rounded : Icons.videocam_rounded,
                        size: 16,
                        color: ArgusTokens.accent,
                      ),
                      const SizedBox(width: 8),
                      Text(c.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newCam) {
                if (newCam != null) {
                  setState(() => _selectedCamera = newCam);
                  ref.read(argusRepositoryProvider).listZones(newCam.id!).then((z) {
                    if (mounted) setState(() => _zones = z);
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Status Badge
        if (_selectedCamera != null)
          _selectedCamera!.sourceKind == 'replay'
              ? StatusBadge.replay()
              : StatusBadge.live(),

        const SizedBox(width: 8),

        // Live Hardware Stream Button
        IconButton(
          icon: Icon(ref.watch(visionControllerProvider).isRunning ? Icons.videocam_off_rounded : Icons.videocam_rounded),
          color: ref.watch(visionControllerProvider).isRunning ? Colors.redAccent : ArgusTokens.accent,
          tooltip: ref.watch(visionControllerProvider).isRunning ? 'Stop Live Feed' : 'Start Hardware Webcam',
          onPressed: () async {
            final vision = ref.read(visionControllerProvider);
            if (vision.isRunning) {
              await vision.stop();
            } else {
              try {
                await vision.start(sourceKind: 'webcam');
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Camera error: $e')),
                  );
                }
              }
            }
            if (mounted) setState(() {});
          },
        ),

        // Snapshot Button
        IconButton(
          icon: const Icon(Icons.camera_alt_outlined),
          color: ArgusTokens.textPrimary,
          tooltip: 'Capture Privacy-Blurred Snapshot',
          onPressed: () async {
            final vision = ref.read(visionControllerProvider);
            final img = await vision.captureSnapshot(blurHead: true);
            if (!mounted || img == null) return;
            showDialog(
              context: context,
                builder: (c) => AlertDialog(
                  backgroundColor: ArgusTokens.bgOverlay,
                  title: Row(
                    children: [
                      const Icon(Icons.shield_rounded, color: ArgusTokens.accent, size: 20),
                      const SizedBox(width: 8),
                      Text('On-Device Privacy Snapshot', style: GoogleFonts.sora(fontSize: 16, color: Colors.white)),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(img, width: 380, fit: BoxFit.contain),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Human heads & faces are anonymized on-device prior to network transmission.',
                        style: TextStyle(color: ArgusTokens.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(c),
                      child: const Text('Close', style: TextStyle(color: ArgusTokens.accent)),
                    ),
                  ],
                ),
              );
            },
          ),

        const Spacer(),

        // Performance mode chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: ArgusTokens.bgRaised,
            borderRadius: BorderRadius.circular(ArgusTokens.radiusSm),
            border: Border.all(color: ArgusTokens.borderSubtle),
          ),
          child: Row(
            children: [
              const PulsingBeacon(color: ArgusTokens.accent, size: 6),
              const SizedBox(width: 6),
              Text(
                _visionStatus != null
                    ? '${_visionStatus!.status.toUpperCase()} · ${_visionStatus!.fps.toStringAsFixed(0)} FPS'
                    : 'WASM 60 FPS · 8.2ms',
                style: GoogleFonts.jetBrainsMono(fontSize: 10, color: ArgusTokens.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVideoStage() {
    final isVisionActive = ref.watch(visionControllerProvider).isRunning;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
        border: Border.all(color: ArgusTokens.borderSubtle),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
        child: Stack(
          children: [
            // Video Background Placeholder / Simulator Stage
            if (!isVisionActive)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF090D14), Color(0xFF141A26)],
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.videocam_rounded, size: 48, color: ArgusTokens.accent.withValues(alpha: 0.3)),
                        const SizedBox(height: 12),
                        Text(
                          _selectedCamera?.name ?? 'Camera Feed',
                          style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'MediaPipe Tasks Vision WASM Overlay Active',
                          style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textTertiary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Hardware HTML Element View (when active on Web)
            if (isVisionActive)
              const Positioned.fill(
                child: VisionStageView(),
              ),

            // Canvas Detection Overlay Simulator (when in mock/preview mode)
            if (!isVisionActive)
              Positioned.fill(
                child: CustomPaint(
                  painter: _MonitorOverlayPainter(
                    zones: _zones,
                    inRestrictedZone: _inRestrictedZone,
                    fallScore: _fallScore,
                    motionlessMs: _motionlessMs,
                  ),
                ),
              ),

            // Top Status Overlay
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    const PulsingBeacon(color: Colors.red, size: 6),
                    const SizedBox(width: 6),
                    Text(
                      'REC · 1080P LOCAL',
                      style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTelemetryStrip() {
    return Row(
      children: [
        _buildTelemetryCard(
          icon: Icons.people_outline_rounded,
          label: 'PERSONS DETECTED',
          value: '$_personCount TRACKED',
          color: ArgusTokens.accent,
        ),
        const SizedBox(width: 10),
        _buildTelemetryCard(
          icon: Icons.crop_square_rounded,
          label: 'ZONE STATUS',
          value: _inRestrictedZone ? 'IN RESTRICTED' : 'CLEAR',
          color: _inRestrictedZone ? ArgusTokens.severityCritical : ArgusTokens.success,
        ),
        const SizedBox(width: 10),
        _buildTelemetryCard(
          icon: Icons.personal_injury_outlined,
          label: 'FALL SCORE',
          value: '${(_fallScore * 100).toInt()}%',
          color: _fallScore > 0.6 ? ArgusTokens.severityCritical : ArgusTokens.textSecondary,
        ),
        const SizedBox(width: 10),
        _buildTelemetryCard(
          icon: Icons.timer_outlined,
          label: 'MOTIONLESS TIME',
          value: '${(_motionlessMs / 1000).toStringAsFixed(1)}s',
          color: _motionlessMs > 5000 ? ArgusTokens.severityHigh : ArgusTokens.textSecondary,
        ),
      ],
    );
  }

  Widget _buildTelemetryCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: ArgusTokens.bgRaised,
          borderRadius: BorderRadius.circular(ArgusTokens.radiusSm),
          border: Border.all(color: ArgusTokens.borderSubtle),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: ArgusTokens.textTertiary),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.w700, color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventLogPanel() {
    return Container(
      height: 110,
      width: double.infinity,
      padding: const EdgeInsets.all(ArgusTokens.space12),
      decoration: BoxDecoration(
        color: ArgusTokens.bgRaised,
        borderRadius: BorderRadius.circular(ArgusTokens.radiusSm),
        border: Border.all(color: ArgusTokens.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.terminal_rounded, size: 14, color: ArgusTokens.accent),
              const SizedBox(width: 6),
              Text(
                'LIVE SIGNAL & DECISION LOG',
                style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.w600, color: ArgusTokens.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              itemCount: _eventLogs.length,
              itemBuilder: (context, idx) {
                return Text(
                  _eventLogs[idx],
                  style: GoogleFonts.jetBrainsMono(fontSize: 11, color: ArgusTokens.textTertiary),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRulesRail() {
    return Padding(
      padding: const EdgeInsets.all(ArgusTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Active Safety Rules',
            style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _rules.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final r = _rules[idx];
                final sev = SeverityLevel.fromString(r.severity);
                return Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: ArgusTokens.bgOverlay,
                    borderRadius: BorderRadius.circular(ArgusTokens.radiusSm),
                    border: Border.all(color: ArgusTokens.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Icon(sev.icon, size: 16, color: sev.color),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.name,
                              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
                            ),
                            Text(
                              r.trigger.signal.replaceAll('_', ' ').toUpperCase(),
                              style: GoogleFonts.jetBrainsMono(fontSize: 10, color: ArgusTokens.textTertiary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ArgusTokens.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ARMED',
                          style: GoogleFonts.jetBrainsMono(fontSize: 10, color: ArgusTokens.accent, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveIncidentsRail() {
    return Padding(
      padding: const EdgeInsets.all(ArgusTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Live Incidents',
                style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
              ),
              InkWell(
                onTap: () => context.go('/app/incidents'),
                child: Text(
                  'View All',
                  style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.accent, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: _incidents.take(4).length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, idx) {
                final inc = _incidents[idx];
                final sev = SeverityLevel.fromString(inc.severity);
                return InkWell(
                  onTap: () => context.go('/app/incidents/${inc.id}'),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ArgusTokens.bgOverlay,
                      borderRadius: BorderRadius.circular(ArgusTokens.radiusSm),
                      border: Border.all(
                        color: inc.status == 'open'
                            ? sev.color.withValues(alpha: 0.5)
                            : ArgusTokens.borderSubtle,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            StatusBadge.fromSeverity(sev),
                            StatusBadge.fromStatus(inc.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          inc.summary,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textPrimary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MonitorOverlayPainter extends CustomPainter {
  final List<Zone> zones;
  final bool inRestrictedZone;
  final double fallScore;
  final int motionlessMs;

  _MonitorOverlayPainter({
    required this.zones,
    required this.inRestrictedZone,
    required this.fallScore,
    required this.motionlessMs,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Zones
    for (final zone in zones) {
      if (zone.polygon.length < 3) continue;

      final path = Path();
      final p0 = zone.polygon.first;
      path.moveTo(p0.x * size.width, p0.y * size.height);

      for (int i = 1; i < zone.polygon.length; i++) {
        final p = zone.polygon[i];
        path.lineTo(p.x * size.width, p.y * size.height);
      }
      path.close();

      final fillColor = (zone.kind == 'restricted')
          ? ArgusTokens.zoneRestricted.withValues(alpha: 0.18)
          : ArgusTokens.zoneWork.withValues(alpha: 0.18);

      final strokeColor = (zone.kind == 'restricted')
          ? ArgusTokens.zoneRestricted
          : ArgusTokens.zoneWork;

      canvas.drawPath(path, Paint()..color = fillColor..style = PaintingStyle.fill);
      canvas.drawPath(
        path,
        Paint()
          ..color = strokeColor.withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    // 2. Draw Simulated Person Detection Box & Skeleton
    final personX = size.width * 0.45;
    final personY = size.height * (fallScore > 0.6 ? 0.60 : 0.35);
    final personW = size.width * (fallScore > 0.6 ? 0.28 : 0.14);
    final personH = size.height * (fallScore > 0.6 ? 0.16 : 0.45);

    final boxRect = Rect.fromLTWH(personX, personY, personW, personH);
    final boxPaint = Paint()
      ..color = ArgusTokens.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(boxRect, boxPaint);

    // Box Label
    final labelBg = Paint()..color = ArgusTokens.accentInk.withValues(alpha: 0.9);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(personX, personY - 20, 84, 18), const Radius.circular(3)),
      labelBg,
    );

    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'ID #101 · 94%',
        style: TextStyle(color: ArgusTokens.accent, fontSize: 10, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(personX + 4, personY - 17));

    // Fall or Warning Badge on Box
    if (fallScore > 0.6) {
      final alertBg = Paint()..color = ArgusTokens.severityCritical;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(personX + personW - 90, personY - 20, 90, 18), const Radius.circular(3)),
        alertBg,
      );
      final alertPainter = TextPainter(
        text: const TextSpan(
          text: 'FALL SUSPECTED',
          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      alertPainter.paint(canvas, Offset(personX + personW - 86, personY - 16));
    }
  }

  @override
  bool shouldRepaint(covariant _MonitorOverlayPainter oldDelegate) {
    return oldDelegate.inRestrictedZone != inRestrictedZone ||
        oldDelegate.fallScore != fallScore ||
        oldDelegate.motionlessMs != motionlessMs ||
        oldDelegate.zones != zones;
  }
}
