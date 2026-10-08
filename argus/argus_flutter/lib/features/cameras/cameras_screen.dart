import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:argus_client/argus_client.dart';
import '../../app/theme/tokens.dart';
import '../../core/widgets/hover_card.dart';
import '../../core/widgets/reveal_animation.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/repository_provider.dart';

class CamerasScreen extends ConsumerStatefulWidget {
  const CamerasScreen({super.key});

  @override
  ConsumerState<CamerasScreen> createState() => _CamerasScreenState();
}

class _CamerasScreenState extends ConsumerState<CamerasScreen> {
  List<Camera> _cameras = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCameras();
  }

  Future<void> _loadCameras() async {
    final repo = ref.read(argusRepositoryProvider);
    final cams = await repo.listCameras();
    if (mounted) {
      setState(() {
        _cameras = cams;
        _isLoading = false;
      });
    }
  }

  void _showAddCameraDialog() {
    final nameCtrl = TextEditingController();
    String sourceKind = 'webcam';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: ArgusTokens.bgOverlay,
          title: Text('Connect Camera Feed', style: GoogleFonts.sora(fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameCtrl,
                style: GoogleFonts.inter(color: ArgusTokens.textPrimary),
                decoration: const InputDecoration(labelText: 'Camera Name', hintText: 'e.g. Loading Dock #2'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: sourceKind,
                dropdownColor: ArgusTokens.bgRaised,
                style: GoogleFonts.inter(color: ArgusTokens.textPrimary),
                decoration: const InputDecoration(labelText: 'Feed Source'),
                items: const [
                  DropdownMenuItem(value: 'webcam', child: Text('Local USB / Laptop Webcam')),
                  DropdownMenuItem(value: 'file', child: Text('Upload Local MP4 Video File')),
                  DropdownMenuItem(value: 'demo', child: Text('Seeded Benchmark Clip (S1-S4)')),
                  DropdownMenuItem(value: 'replay', child: Text('Replay Mode (Deterministic Telemetry)')),
                ],
                onChanged: (val) {
                  if (val != null) setDlgState(() => sourceKind = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.isEmpty) return;
                final repo = ref.read(argusRepositoryProvider);
                await repo.saveCamera(Camera(
                  workspaceId: 1,
                  name: nameCtrl.text,
                  sourceKind: sourceKind,
                  sourceRef: 'local',
                  enabled: true,
                  createdAt: DateTime.now(),
                  status: 'online',
                ));
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) _loadCameras();
              },
              child: const Text('Save Camera'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: ArgusTokens.accent));
    }

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connected Cameras',
                        style: GoogleFonts.sora(fontSize: 26, fontWeight: FontWeight.w700, color: ArgusTokens.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Local webcam feeds, uploaded MP4s, and deterministic replay benchmarks.',
                        style: GoogleFonts.inter(fontSize: 14, color: ArgusTokens.textSecondary),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: _showAddCameraDialog,
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add Camera'),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Cameras Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final cardWidth = constraints.maxWidth > 900
                      ? (constraints.maxWidth - 32) / 3
                      : constraints.maxWidth > 600
                          ? (constraints.maxWidth - 16) / 2
                          : constraints.maxWidth;

                  return Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: _cameras.map((cam) {
                      return SizedBox(
                        width: cardWidth,
                        child: RevealAnimation(
                          child: HoverCard(
                            onTap: () => context.go('/app/cameras/${cam.id}/zones'),
                            padding: const EdgeInsets.all(ArgusTokens.space20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Camera Preview Stage Placeholder
                                Container(
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: ArgusTokens.borderSubtle),
                                  ),
                                  child: Center(
                                    child: Icon(Icons.videocam_rounded, size: 40, color: ArgusTokens.accent.withValues(alpha: 0.4)),
                                  ),
                                ),
                                const SizedBox(height: 14),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      cam.name,
                                      style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
                                    ),
                                    cam.sourceKind == 'replay'
                                        ? StatusBadge.replay()
                                        : StatusBadge.live(),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Source: ${cam.sourceKind.toUpperCase()} · ID #${cam.id}',
                                  style: GoogleFonts.jetBrainsMono(fontSize: 11, color: ArgusTokens.textTertiary),
                                ),
                                const SizedBox(height: 16),

                                OutlinedButton.icon(
                                  onPressed: () => context.go('/app/cameras/${cam.id}/zones'),
                                  icon: const Icon(Icons.draw_outlined, size: 14),
                                  label: const Text('Edit Zones (Polygon)'),
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
          ),
        ),
      ),
    );
  }
}
