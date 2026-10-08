import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:argus_client/argus_client.dart';
import '../../app/theme/tokens.dart';
import '../../core/util/video_picker.dart';
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
    String? sourceRef;
    String? pickedFileName;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: ArgusTokens.bgOverlay,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white, width: 1),
          ),
          title: Row(
            children: [
              const Icon(Icons.videocam_outlined, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text('Connect Camera Feed', style: GoogleFonts.sora(fontSize: 16, color: Colors.white)),
            ],
          ),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameCtrl,
                  style: GoogleFonts.inter(color: ArgusTokens.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Camera Name',
                    hintText: 'e.g. Office Front Desk, Gate 3, Cash Counter',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: sourceKind,
                  dropdownColor: ArgusTokens.bgRaised,
                  style: GoogleFonts.inter(color: ArgusTokens.textPrimary),
                  decoration: const InputDecoration(labelText: 'Feed Source'),
                  items: const [
                    DropdownMenuItem(value: 'webcam', child: Text('Local USB / Laptop Webcam')),
                    DropdownMenuItem(value: 'file', child: Text('Pre-Recorded Video File (MP4 / WebM)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDlgState(() => sourceKind = val);
                  },
                ),
                if (sourceKind == 'file') ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ArgusTokens.bgRaised,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select Local Video File:', style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textSecondary)),
                        const SizedBox(height: 8),
                        OutlinedButton.icon(
                          onPressed: () async {
                            final file = await pickVideoFile();
                            if (file != null) {
                              setDlgState(() {
                                sourceRef = file.url;
                                pickedFileName = file.name;
                                if (nameCtrl.text.isEmpty) {
                                  nameCtrl.text = file.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
                                }
                              });
                            }
                          },
                          icon: const Icon(Icons.upload_file_rounded, size: 16),
                          label: Text(pickedFileName != null ? 'Selected: $pickedFileName' : 'Browse MP4 File...'),
                        ),
                        if (pickedFileName != null) ...[
                          const SizedBox(height: 6),
                          Text('Ready to stream directly on-device.', style: GoogleFonts.inter(fontSize: 11, color: Colors.greenAccent)),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: ArgusTokens.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                final repo = ref.read(argusRepositoryProvider);
                await repo.saveCamera(Camera(
                  workspaceId: 1,
                  name: nameCtrl.text.trim(),
                  sourceKind: sourceKind,
                  sourceRef: sourceRef ?? 'local',
                  enabled: true,
                  createdAt: DateTime.now(),
                  status: 'online',
                ));
                if (ctx.mounted) Navigator.pop(ctx);
                if (mounted) _loadCameras();
              },
              child: const Text('Add Camera'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteCameraDialog(Camera cam) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: ArgusTokens.bgOverlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white, width: 1),
        ),
        title: Text('Delete Camera', style: GoogleFonts.sora(fontSize: 16, color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${cam.name}" and all its configured zones?',
          style: GoogleFonts.inter(color: ArgusTokens.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(c);
              await ref.read(argusRepositoryProvider).deleteCamera(cam.id!);
              _loadCameras();
            },
            child: const Text('Delete Camera'),
          ),
        ],
      ),
    );
  }

  void _showWipeDataDialog() {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: ArgusTokens.bgOverlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white, width: 1),
        ),
        title: Text('Clear All Workspace Data', style: GoogleFonts.sora(fontSize: 16, color: Colors.white)),
        content: Text(
          'This will purge all cameras, zones, rules, and incidents to give you a 100% clean slate.',
          style: GoogleFonts.inter(color: ArgusTokens.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(c);
              await ref.read(argusRepositoryProvider).deleteWorkspaceData();
              _loadCameras();
            },
            child: const Text('Wipe Clean'),
          ),
        ],
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
                        'Configure live webcams, pre-recorded CCTV video files, or network streams.',
                        style: GoogleFonts.inter(fontSize: 14, color: ArgusTokens.textSecondary),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (_cameras.isNotEmpty) ...[
                        OutlinedButton.icon(
                          onPressed: _showWipeDataDialog,
                          icon: const Icon(Icons.delete_sweep_outlined, size: 16, color: Colors.redAccent),
                          label: const Text('Wipe All Data', style: TextStyle(color: Colors.redAccent)),
                        ),
                        const SizedBox(width: 12),
                      ],
                      ElevatedButton.icon(
                        onPressed: _showAddCameraDialog,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Camera'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Empty State
              if (_cameras.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 56),
                  decoration: BoxDecoration(
                    color: ArgusTokens.bgOverlay,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.videocam_outlined, size: 56, color: Colors.white),
                      const SizedBox(height: 16),
                      Text('No Cameras Connected', style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                      const SizedBox(height: 8),
                      Text(
                        'Connect your physical webcam or upload a pre-recorded CCTV MP4 video file to start monitoring.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 14, color: ArgusTokens.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _showAddCameraDialog,
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text('Add Your First Camera Feed'),
                      ),
                    ],
                  ),
                )
              else
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
                                      child: Icon(
                                        cam.sourceKind == 'file' ? Icons.movie_outlined : Icons.videocam_rounded,
                                        size: 40,
                                        color: ArgusTokens.accent.withValues(alpha: 0.4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          cam.name,
                                          style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      cam.sourceKind == 'file'
                                          ? StatusBadge.videoFile()
                                          : StatusBadge.live(),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Source: ${cam.sourceKind.toUpperCase()} · ID #${cam.id}',
                                    style: GoogleFonts.jetBrainsMono(fontSize: 11, color: ArgusTokens.textTertiary),
                                  ),
                                  const SizedBox(height: 16),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: () => context.go('/app/cameras/${cam.id}/zones'),
                                        icon: const Icon(Icons.draw_outlined, size: 14),
                                        label: const Text('Edit Zones (Polygon)'),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: ArgusTokens.textTertiary),
                                        tooltip: 'Delete Camera',
                                        onPressed: () => _showDeleteCameraDialog(cam),
                                      ),
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
          ),
        ),
      ),
    );
  }
}
