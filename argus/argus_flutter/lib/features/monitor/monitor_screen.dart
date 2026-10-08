import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:argus_client/argus_client.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/severity_scale.dart';
import '../../core/widgets/pulsing_beacon.dart';
import '../../core/widgets/rainbow_moving_border.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/vision/vision_controller.dart';
import '../../core/vision/vision_types.dart';
import '../../core/vision/vision_stage_view.dart';
import '../../data/repository_provider.dart';
import '../../core/util/video_picker.dart';

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
  int _personCount = 0;
  double _fallScore = 0.0;
  int _motionlessMs = 0;
  bool _inRestrictedZone = false;
  StreamSubscription<IncidentUpdate>? _streamSub;

  // Signal dispatch throttling to protect backend sockets & threads
  bool _isDispatchingSignals = false;
  int _lastSignalSentMs = 0;
  bool _lastRestrictedState = false;

  final List<String> _eventLogs = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _initVision();
  }

  void _syncZonesToVision() {
    final vision = ref.read(visionControllerProvider);
    final zoneList = _zones.map((z) => {
      'id': z.id,
      'name': z.name,
      'kind': z.kind,
      'color': z.color,
      'polygon': z.polygon.map((p) => {'x': p.x, 'y': p.y}).toList(),
    }).toList();
    vision.setZones(zoneList);
  }

  Future<void> _initVision() async {
    final vision = ref.read(visionControllerProvider);
    await vision.initialize();
    vision.onStatus((status) {
      if (mounted) {
        setState(() {
          _visionStatus = status;
          if (status.status == 'ended' || status.status == 'stopped') {
            _personCount = 0;
            _fallScore = 0.0;
            _motionlessMs = 0;
            _inRestrictedZone = false;
          }
        });
      }
    });
    vision.onSignals((batch) {
      if (!mounted) return;
      final signals = batch['signals'] as List?;
      if (signals != null && signals.isNotEmpty) {
        final first = signals.first as Map<String, dynamic>;
        final persons = first['persons'] as List?;
        if (persons != null && persons.isNotEmpty) {
          final anyRestricted = persons.any((p) {
            final zIds = (p as Map<String, dynamic>)['zoneIds'] as List?;
            return zIds != null && zIds.isNotEmpty;
          });
          double maxFall = 0.0;
          int fallenMotionless = 0;
          int restrictedMotionless = 0;

          for (final pObj in persons) {
            final pMap = pObj as Map<String, dynamic>;
            final f = (pMap['fallScore'] as num?)?.toDouble() ?? 0.0;
            final m = (pMap['motionlessMs'] as num?)?.toInt() ?? 0;
            final zIds = (pMap['zoneIds'] as List? ?? []);

            if (f > maxFall) {
              maxFall = f;
              fallenMotionless = m;
            }
            if (zIds.isNotEmpty && m > restrictedMotionless) {
              restrictedMotionless = m;
            }
          }

          int displayMotionless = 0;
          if (maxFall >= 0.5) {
            displayMotionless = fallenMotionless;
          } else if (anyRestricted) {
            displayMotionless = restrictedMotionless;
          } else {
            // Normal public platform commuters: no incident timer active
            displayMotionless = 0;
          }

          setState(() {
            _personCount = persons.length;
            _fallScore = maxFall;
            _motionlessMs = displayMotionless;
            _inRestrictedZone = anyRestricted;
          });

          final pFirst = persons.first as Map<String, dynamic>;
          final foot = pFirst['footN'] as Map<String, dynamic>?;
          if (foot != null) {
            final fx = (foot['x'] as num?)?.toDouble() ?? 0.0;
            final fy = (foot['y'] as num?)?.toDouble() ?? 0.0;
            final zIds = (pFirst['zoneIds'] as List? ?? []).map((e) => (e as num).toInt()).toList();
            final matched = _zones.where((z) => zIds.contains(z.id)).toList();
            final zoneName = matched.isNotEmpty
                ? matched.first.name
                : (anyRestricted ? (_zones.isNotEmpty ? _zones.first.name : "Restricted Zone") : "Clear");
            final ts = DateTime.now().toIso8601String().substring(11, 19);
            _eventLogs.insert(0, '[$ts] SIGNAL: ${persons.length} track, foot (${fx.toStringAsFixed(2)}, ${fy.toStringAsFixed(2)}), zone: $zoneName');
            if (_eventLogs.length > 40) _eventLogs.removeLast();
          }

          _dispatchSignalBatch(batch);
        } else {
          setState(() {
            _personCount = 0;
            _fallScore = 0.0;
            _motionlessMs = 0;
            _inRestrictedZone = false;
          });
        }
      }
    });
  }

  Future<void> _dispatchSignalBatch(Map<String, dynamic> batch) async {
    if (_isDispatchingSignals) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final stateChanged = _inRestrictedZone != _lastRestrictedState || _fallScore >= 0.5;
    final timeSinceLast = now - _lastSignalSentMs;

    // Send immediately on state change (e.g. entry into restricted zone or fall),
    // or every 2.5 seconds as a steady heartbeat. This prevents TCP socket/thread flooding.
    if (!stateChanged && timeSinceLast < 2500) return;

    _isDispatchingSignals = true;
    _lastSignalSentMs = now;
    _lastRestrictedState = _inRestrictedZone;

    try {
      final camId = _selectedCamera?.id ?? 1;
      final rawSignals = batch['signals'] as List? ?? [];
      final eventList = <SignalEvent>[];

      for (final s in rawSignals) {
        final sMap = s as Map<String, dynamic>;
        final pList = (sMap['persons'] as List? ?? []).map((p) {
          final pMap = p as Map<String, dynamic>;
          final bbox = pMap['bboxN'] as Map<String, dynamic>? ?? {};
          final foot = pMap['footN'] as Map<String, dynamic>? ?? {};
          final zList = (pMap['zoneIds'] as List? ?? []).map((zid) => (zid as num).toInt()).toList();

          return PersonSignal(
            trackId: (pMap['trackId'] as num?)?.toInt() ?? 0,
            bboxN: BBoxN(
              x: (bbox['x'] as num?)?.toDouble() ?? 0.0,
              y: (bbox['y'] as num?)?.toDouble() ?? 0.0,
              w: (bbox['w'] as num?)?.toDouble() ?? 0.0,
              h: (bbox['h'] as num?)?.toDouble() ?? 0.0,
            ),
            footN: PointN(
              x: (foot['x'] as num?)?.toDouble() ?? 0.0,
              y: (foot['y'] as num?)?.toDouble() ?? 0.0,
            ),
            zoneIds: zList,
            torsoAngleDeg: (pMap['torsoAngleDeg'] as num?)?.toDouble(),
            hipDropRatio: (pMap['hipDropRatio'] as num?)?.toDouble(),
            aspect: (pMap['aspect'] as num?)?.toDouble() ?? 1.0,
            motionScore: (pMap['motionScore'] as num?)?.toDouble() ?? 0.0,
            fallScore: (pMap['fallScore'] as num?)?.toDouble() ?? 0.0,
            motionlessMs: (pMap['motionlessMs'] as num?)?.toInt() ?? 0,
            confidence: (pMap['confidence'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList();

        eventList.add(SignalEvent(
          tsMs: (sMap['tsMs'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
          kind: sMap['kind'] as String? ?? 'change',
          personCount: pList.length,
          persons: pList,
        ));
      }

      final signalBatch = SignalBatch(
        cameraId: camId,
        sentAtMs: DateTime.now().millisecondsSinceEpoch,
        seq: (batch['seq'] as num?)?.toInt() ?? 0,
        signals: eventList,
      );

      await ref.read(argusRepositoryProvider).sendSignals(signalBatch);
    } catch (e) {
      debugPrint('[Argus Monitor] Error dispatching signals: $e');
    } finally {
      _isDispatchingSignals = false;
    }
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    try {
      ref.read(visionControllerProvider).stop();
    } catch (_) {}
    super.dispose();
  }

  Future<void> _loadData() async {
    final repo = ref.read(argusRepositoryProvider);
    try {
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
          try {
            final zones = await repo.listZones(_selectedCamera!.id!);
            if (mounted) {
              setState(() => _zones = zones);
              _syncZonesToVision();
            }
          } catch (_) {}
        }

        try {
          _streamSub = repo.watchIncidents().listen(
            (update) {
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
            },
            onError: (err) {
              // Gracefully handle server restarts/drops without unhandled errors
            },
            cancelOnError: false,
          );
        } catch (_) {}
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _startCurrentCameraFeed() async {
    final vision = ref.read(visionControllerProvider);
    if (vision.isRunning) {
      await vision.stop();
    }
    _syncZonesToVision();
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
    try {
      final source = _selectedCamera?.sourceKind ?? 'webcam';
      final url = _selectedCamera?.sourceRef;
      if (source == 'file' && (url == null || url == 'local' || url.trim().isEmpty)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 4),
              backgroundColor: ArgusTokens.bgOverlay,
              content: const Text(
                'No local MP4 file selected for this camera. Click below to load your video.',
                style: TextStyle(color: Colors.white),
              ),
              action: SnackBarAction(
                label: 'BROWSE MP4',
                textColor: Colors.amberAccent,
                onPressed: _pickVideoFileForCurrentCamera,
              ),
            ),
          );
        }
        return;
      }
      await vision.start(
        sourceKind: source,
        sourceUrl: (source == 'file' || source == 'stream') ? url : null,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 4),
            backgroundColor: ArgusTokens.bgOverlay,
            content: Text(
              'Video feed error: $e. If the browser was refreshed, please re-select the MP4 file.',
              style: const TextStyle(color: Colors.white),
            ),
            action: _selectedCamera?.sourceKind == 'file'
                ? SnackBarAction(
                    label: 'RE-SELECT MP4',
                    textColor: Colors.amberAccent,
                    onPressed: _pickVideoFileForCurrentCamera,
                  )
                : null,
          ),
        );
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _pickVideoFileForCurrentCamera() async {
    if (mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
    }
    final file = await pickVideoFile();
    if (file != null && _selectedCamera != null) {
      final updatedCam = _selectedCamera!.copyWith(
        sourceRef: file.url,
      );
      await ref.read(argusRepositoryProvider).saveCamera(updatedCam);
      if (mounted) {
        setState(() {
          _selectedCamera = updatedCam;
          final idx = _cameras.indexWhere((c) => c.id == updatedCam.id);
          if (idx >= 0) _cameras[idx] = updatedCam;
        });
        await _startCurrentCameraFeed();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ArgusTokens.accent),
      );
    }

    if (_cameras.isEmpty) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 540),
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(48),
          decoration: BoxDecoration(
            color: ArgusTokens.bgOverlay,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_outlined, size: 64, color: Colors.white),
              const SizedBox(height: 20),
              Text(
                'No Cameras Configured',
                style: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                'Connect a physical webcam or upload a pre-recorded CCTV video file (MP4/WebM) to begin live AI surveillance.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 14, color: ArgusTokens.textSecondary),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () => context.go('/app/cameras'),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Go to Cameras & Add Feed'),
              ),
            ],
          ),
        ),
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
                    Expanded(
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: _buildVideoStage(),
                        ),
                      ),
                    ),
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
                        c.sourceKind == 'file' ? Icons.movie_outlined : Icons.videocam_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(c.name),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (newCam) async {
                if (newCam != null) {
                  setState(() => _selectedCamera = newCam);
                  final z = await ref.read(argusRepositoryProvider).listZones(newCam.id!);
                  if (mounted) {
                    setState(() => _zones = z);
                    _syncZonesToVision();
                  }
                  await _startCurrentCameraFeed();
                }
              },
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Status Badge
        if (_selectedCamera != null)
          _selectedCamera!.sourceKind == 'file'
              ? StatusBadge.videoFile()
              : StatusBadge.live(),

        const SizedBox(width: 12),

        if (_selectedCamera?.sourceKind == 'file') ...[
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white30),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            icon: const Icon(Icons.replay_rounded, size: 16),
            label: const Text('Replay', style: TextStyle(fontSize: 12)),
            onPressed: () async {
              await _startCurrentCameraFeed();
            },
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.white30),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            icon: const Icon(Icons.file_upload_outlined, size: 16),
            label: const Text('Change MP4', style: TextStyle(fontSize: 12)),
            onPressed: _pickVideoFileForCurrentCamera,
          ),
          const SizedBox(width: 8),
        ],

        // Play / Stop Action Button
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: ref.watch(visionControllerProvider).isRunning
                ? Colors.redAccent.withValues(alpha: 0.15)
                : Colors.white,
            foregroundColor: ref.watch(visionControllerProvider).isRunning
                ? Colors.redAccent
                : Colors.black,
            side: BorderSide(
              color: ref.watch(visionControllerProvider).isRunning
                  ? Colors.redAccent
                  : Colors.white,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          ),
          icon: Icon(
            ref.watch(visionControllerProvider).isRunning
                ? Icons.stop_rounded
                : (_selectedCamera?.sourceKind == 'file' ? Icons.play_arrow_rounded : Icons.videocam_rounded),
            size: 16,
          ),
          label: Text(
            ref.watch(visionControllerProvider).isRunning
                ? 'STOP FEED'
                : (_selectedCamera?.sourceKind == 'file' ? 'PLAY VIDEO' : 'START WEBCAM'),
            style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          onPressed: () async {
            final vision = ref.read(visionControllerProvider);
            if (vision.isRunning) {
              await vision.stop();
              if (mounted) {
                setState(() {
                  _personCount = 0;
                  _fallScore = 0.0;
                  _motionlessMs = 0;
                  _inRestrictedZone = false;
                });
              }
            } else {
              await _startCurrentCameraFeed();
            }
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

    return RainbowMovingBorder(
      borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
      borderWidth: 1.5,
      baseBorderColor: Colors.white,
      backgroundColor: Colors.black,
      isLive: true,
      duration: const Duration(seconds: 4),
      child: Stack(
        children: [
          // Hardware HTML Element View (always mounted so DOM elements exist)
          const Positioned.fill(
            child: VisionStageView(),
          ),

          // Video Background Placeholder / Simulator Stage
          if (!isVisionActive)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.88),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Icon(
                          _selectedCamera?.sourceKind == 'file' ? Icons.movie_outlined : Icons.videocam_outlined,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _selectedCamera?.name ?? 'Camera Feed',
                        style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedCamera?.sourceKind == 'file'
                            ? 'Pre-Recorded CCTV Video Feed · MP4 / WebM'
                            : 'Physical Hardware Webcam Stream',
                        style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                            icon: const Icon(Icons.play_arrow_rounded, size: 20),
                            label: Text(
                              _selectedCamera?.sourceKind == 'file' ? 'START VIDEO PLAYBACK' : 'START WEBCAM FEED',
                              style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            onPressed: _startCurrentCameraFeed,
                          ),
                          if (_selectedCamera?.sourceKind == 'file') ...[
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white70),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              icon: const Icon(Icons.file_upload_outlined, size: 18),
                              label: Text(
                                'CHOOSE / CHANGE MP4',
                                style: GoogleFonts.sora(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              onPressed: _pickVideoFileForCurrentCamera,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
    final relevantRules = _rules.where((r) => r.cameraIds.isEmpty || r.cameraIds.contains(_selectedCamera?.id)).toList();

    return Padding(
      padding: const EdgeInsets.all(ArgusTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Safety Rules',
                style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
              ),
              InkWell(
                onTap: () => context.go('/app/rules'),
                child: Text(
                  'Manage',
                  style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.accent, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: relevantRules.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.rule_folder_outlined, size: 36, color: Colors.white24),
                          const SizedBox(height: 10),
                          Text(
                            'No Rules Attached',
                            style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'No policy attached to ${_selectedCamera?.name ?? "this camera"}.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 11, color: ArgusTokens.textSecondary),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () => context.go('/app/rules'),
                            child: const Text('Add in Rule Studio', style: TextStyle(fontSize: 12, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: relevantRules.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final r = relevantRules[idx];
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
                            InkWell(
                              onTap: () async {
                                final updated = RuleSpec(
                                  id: r.id,
                                  workspaceId: r.workspaceId,
                                  name: r.name,
                                  enabled: !r.enabled,
                                  cameraIds: r.cameraIds,
                                  trigger: r.trigger,
                                  conditions: r.conditions,
                                  severity: r.severity,
                                  verify: r.verify,
                                  actions: r.actions,
                                  cooldownSec: r.cooldownSec,
                                  escalation: r.escalation,
                                  sourceText: r.sourceText,
                                  parsedBy: r.parsedBy,
                                  createdAt: r.createdAt,
                                  version: r.version,
                                );
                                await ref.read(argusRepositoryProvider).saveRule(updated);
                                final newRules = await ref.read(argusRepositoryProvider).listRules();
                                if (mounted) setState(() => _rules = newRules);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: r.enabled ? ArgusTokens.success.withValues(alpha: 0.15) : Colors.white10,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: r.enabled ? ArgusTokens.success : Colors.white24,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  r.enabled ? 'ARMED' : 'PAUSED',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    color: r.enabled ? ArgusTokens.success : Colors.white60,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
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
    final camIncidents = _incidents.where((i) => _selectedCamera == null || i.cameraId == _selectedCamera?.id).toList();

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
            child: camIncidents.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.shield_outlined, size: 36, color: ArgusTokens.accent.withValues(alpha: 0.6)),
                          const SizedBox(height: 10),
                          Text(
                            'Feed Secure',
                            style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'No active alarms on ${_selectedCamera?.name ?? "this camera"}. Telemetry normal.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(fontSize: 11, color: ArgusTokens.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: camIncidents.take(4).length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, idx) {
                      final inc = camIncidents[idx];
                      final sev = SeverityLevel.fromString(inc.severity);
                      final isOpen = inc.status == 'open';
                      final content = Container(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                StatusBadge.fromSeverity(sev),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    StatusBadge.fromStatus(inc.status),
                                    const SizedBox(width: 6),
                                    InkWell(
                                      onTap: () async {
                                        if (inc.id != null) {
                                          await ref.read(argusRepositoryProvider).deleteIncident(inc.id!);
                                          final updated = await ref.read(argusRepositoryProvider).listIncidents();
                                          if (mounted) setState(() => _incidents = updated);
                                        }
                                      },
                                      borderRadius: BorderRadius.circular(4),
                                      child: const Padding(
                                        padding: EdgeInsets.all(2.0),
                                        child: Icon(Icons.close_rounded, size: 14, color: ArgusTokens.textTertiary),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              inc.summary,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textPrimary, fontWeight: FontWeight.w500),
                            ),
                            if (isOpen) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.timer_outlined, size: 12, color: Colors.amberAccent),
                                      const SizedBox(width: 4),
                                      Text(
                                        'ESCALATION ACTIVE',
                                        style: GoogleFonts.jetBrainsMono(fontSize: 9, color: Colors.amberAccent, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    onPressed: () async {
                                      await ref.read(argusRepositoryProvider).acknowledge(inc.id!);
                                      final updated = await ref.read(argusRepositoryProvider).listIncidents();
                                      if (mounted) setState(() => _incidents = updated);
                                    },
                                    child: Text(
                                      'ACKNOWLEDGE',
                                      style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );

                      return InkWell(
                        onTap: () => context.go('/app/incidents/${inc.id}'),
                        child: isOpen
                            ? RainbowMovingBorder(
                                borderRadius: BorderRadius.circular(ArgusTokens.radiusSm),
                                borderWidth: 1.2,
                                baseBorderColor: Colors.white,
                                backgroundColor: ArgusTokens.bgOverlay,
                                isLive: true,
                                child: content,
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  color: ArgusTokens.bgOverlay,
                                  borderRadius: BorderRadius.circular(ArgusTokens.radiusSm),
                                  border: Border.all(color: ArgusTokens.borderSubtle),
                                ),
                                child: content,
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
  }

  @override
  bool shouldRepaint(covariant _MonitorOverlayPainter oldDelegate) {
    return oldDelegate.inRestrictedZone != inRestrictedZone ||
        oldDelegate.fallScore != fallScore ||
        oldDelegate.motionlessMs != motionlessMs ||
        oldDelegate.zones != zones;
  }
}
