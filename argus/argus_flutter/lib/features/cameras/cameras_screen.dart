import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:argus_client/argus_client.dart';
import '../../app/theme/tokens.dart';
import '../../core/util/preloaded_scenes.dart';
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
    String sourceKind = 'webcam'; // 'webcam' or 'file'
    String selectedSceneId = kPreloadedScenes.first.id;
    String? sourceRef;
    String? pickedFileName;
    String? firstFrameUrl;
    bool isCustomFile = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: ArgusTokens.bgOverlay,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Colors.white24, width: 1.2),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ArgusTokens.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.videocam_rounded, color: ArgusTokens.accent, size: 20),
              ),
              const SizedBox(width: 10),
              Text('Connect Camera Feed', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Source Kind Selector (Webcam vs Preloaded Video)
                Text('Feed Source:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: ArgusTokens.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          setDlgState(() {
                            sourceKind = 'webcam';
                            sourceRef = 'local';
                            if (nameCtrl.text.isEmpty || nameCtrl.text.startsWith('Video') || nameCtrl.text.startsWith('Chemical') || nameCtrl.text.startsWith('Staircase')) {
                              nameCtrl.text = 'Webcam Feed ${_cameras.length + 1}';
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                          decoration: BoxDecoration(
                            color: sourceKind == 'webcam' ? ArgusTokens.accent.withValues(alpha: 0.18) : ArgusTokens.bgRaised,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: sourceKind == 'webcam' ? ArgusTokens.accent : Colors.white12,
                              width: sourceKind == 'webcam' ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.videocam_rounded, color: sourceKind == 'webcam' ? ArgusTokens.accent : Colors.white70, size: 24),
                              const SizedBox(height: 6),
                              Text('Webcam', style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                              const SizedBox(height: 2),
                              Text('Live laptop / USB camera', style: GoogleFonts.inter(fontSize: 10, color: ArgusTokens.textTertiary), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () {
                          setDlgState(() {
                            sourceKind = 'file';
                            sourceRef = selectedSceneId;
                            firstFrameUrl = getPreloadedSceneFrame(selectedSceneId);
                            if (nameCtrl.text.isEmpty || nameCtrl.text.startsWith('Webcam')) {
                              nameCtrl.text = kPreloadedScenes.first.name;
                            }
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                          decoration: BoxDecoration(
                            color: sourceKind == 'file' ? ArgusTokens.accent.withValues(alpha: 0.18) : ArgusTokens.bgRaised,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: sourceKind == 'file' ? ArgusTokens.accent : Colors.white12,
                              width: sourceKind == 'file' ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.movie_outlined, color: sourceKind == 'file' ? ArgusTokens.accent : Colors.white70, size: 24),
                              const SizedBox(height: 6),
                              Text('Preloaded Video', style: GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                              const SizedBox(height: 2),
                              Text('Preloaded scenes or MP4 file', style: GoogleFonts.inter(fontSize: 10, color: ArgusTokens.textTertiary), textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 2. Camera Name
                TextField(
                  controller: nameCtrl,
                  style: GoogleFonts.inter(color: ArgusTokens.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Camera Name',
                    hintText: 'e.g. Chemical Lab 01, Staircase East, Front Desk',
                  ),
                ),

                // 3. Preloaded Video Specific Controls
                if (sourceKind == 'file') ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ArgusTokens.bgRaised,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select Video Footage:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                        const SizedBox(height: 10),

                        // Preloaded Scene Dropdown
                        DropdownButtonFormField<String>(
                          initialValue: isCustomFile ? 'custom' : selectedSceneId,
                          dropdownColor: ArgusTokens.bgRaised,
                          style: GoogleFonts.inter(color: ArgusTokens.textPrimary, fontSize: 13),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                            labelText: 'Preloaded Scene Template',
                          ),
                          items: [
                            ...kPreloadedScenes.map((s) => DropdownMenuItem(
                              value: s.id,
                              child: Row(
                                children: [
                                  const Icon(Icons.movie_creation_outlined, size: 16, color: ArgusTokens.accent),
                                  const SizedBox(width: 8),
                                  Text(s.name, style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                            )),
                            const DropdownMenuItem(
                              value: 'custom',
                              child: Row(
                                children: [
                                  Icon(Icons.upload_file_rounded, size: 16, color: Colors.amberAccent),
                                  SizedBox(width: 8),
                                  Text('Custom MP4 File (Browse from Disk)...', style: TextStyle(fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (val) {
                            if (val == null) return;
                            setDlgState(() {
                              if (val == 'custom') {
                                isCustomFile = true;
                              } else {
                                isCustomFile = false;
                                selectedSceneId = val;
                                sourceRef = val;
                                firstFrameUrl = getPreloadedSceneFrame(val);
                                final scene = kPreloadedScenes.firstWhere((s) => s.id == val);
                                nameCtrl.text = scene.name;
                              }
                            });
                          },
                        ),

                        // If Custom File is selected, show browse button
                        if (isCustomFile) ...[
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final file = await pickVideoFile();
                              if (file != null) {
                                setDlgState(() {
                                  sourceRef = file.url;
                                  pickedFileName = file.name;
                                  firstFrameUrl = file.firstFrameDataUrl;
                                  if (nameCtrl.text.isEmpty || nameCtrl.text.startsWith('Video') || nameCtrl.text.startsWith('Chemical')) {
                                    nameCtrl.text = file.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '');
                                  }
                                });
                              }
                            },
                            icon: const Icon(Icons.upload_file_rounded, size: 16),
                            label: Text(pickedFileName != null ? 'File: $pickedFileName' : 'Browse Local MP4 File...'),
                          ),
                          if (pickedFileName != null) ...[
                            const SizedBox(height: 6),
                            Text('Static first frame extracted & ready for zone drawing.', style: GoogleFonts.inter(fontSize: 11, color: Colors.greenAccent)),
                          ],
                        ] else ...[
                          const SizedBox(height: 6),
                          Text(
                            'First frame of this scene will be frozen in the zone editor for precise polygon alignment.',
                            style: GoogleFonts.inter(fontSize: 11, color: ArgusTokens.textTertiary),
                          ),
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
                final name = nameCtrl.text.trim().isNotEmpty
                    ? nameCtrl.text.trim()
                    : (sourceKind == 'webcam' ? 'Webcam #${_cameras.length + 1}' : 'Video Feed #${_cameras.length + 1}');

                final finalSourceRef = sourceRef ??
                    (sourceKind == 'webcam' ? 'local' : (isCustomFile ? 'local' : selectedSceneId));

                final repo = ref.read(argusRepositoryProvider);
                final saved = await repo.saveCamera(Camera(
                  workspaceId: 1,
                  name: name,
                  sourceKind: sourceKind,
                  sourceRef: finalSourceRef,
                  enabled: true,
                  createdAt: DateTime.now(),
                  status: 'online',
                ));

                // Cache static frame for zone editor if video camera
                if (sourceKind == 'file' && saved.id != null) {
                  final frame = firstFrameUrl ?? getPreloadedSceneFrame(finalSourceRef);
                  ref.read(cameraStaticFrameProvider.notifier).update(
                    (map) => {...map, saved.id!: frame},
                  );
                }

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
                                  // Camera Preview Stage Placeholder / Static Scene Thumbnail
                                  Builder(
                                    builder: (context) {
                                      final staticFrames = ref.watch(cameraStaticFrameProvider);
                                      final thumbUrl = staticFrames[cam.id] ??
                                          (cam.sourceKind == 'file' ? getPreloadedSceneFrame(cam.sourceRef) : null);

                                      return Container(
                                        height: 140,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: ArgusTokens.borderSubtle),
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        child: Stack(
                                          fit: StackFit.expand,
                                          children: [
                                            if (thumbUrl != null)
                                              Image.network(
                                                thumbUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Center(
                                                  child: Icon(
                                                    Icons.movie_outlined,
                                                    size: 40,
                                                    color: ArgusTokens.accent.withValues(alpha: 0.4),
                                                  ),
                                                ),
                                              )
                                            else
                                              Center(
                                                child: Icon(
                                                  cam.sourceKind == 'file' ? Icons.movie_outlined : Icons.videocam_rounded,
                                                  size: 40,
                                                  color: ArgusTokens.accent.withValues(alpha: 0.4),
                                                ),
                                              ),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: Colors.black87,
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(color: Colors.white24, width: 0.8),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      cam.sourceKind == 'file' ? Icons.pause_circle_outline_rounded : Icons.fiber_manual_record_rounded,
                                                      size: 10,
                                                      color: cam.sourceKind == 'file' ? Colors.amberAccent : Colors.redAccent,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      cam.sourceKind == 'file' ? 'STATIC FRAME' : 'LIVE FEED',
                                                      style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
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
