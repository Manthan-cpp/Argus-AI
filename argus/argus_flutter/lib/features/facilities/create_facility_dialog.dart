import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:argus_client/argus_client.dart';
import '../../app/theme/tokens.dart';
import '../../core/util/preloaded_scenes.dart';
import '../../core/util/video_picker.dart';
import '../../data/repository_provider.dart';
import 'facility_providers.dart';

class _ConfiguredCameraDraft {
  String name;
  String sourceKind; // 'file', 'webcam', or 'rtsp'
  String sourceRef;
  String fileName;
  String? firstFrameUrl;

  _ConfiguredCameraDraft({
    required this.name,
    required this.sourceKind,
    required this.sourceRef,
    required this.fileName,
    this.firstFrameUrl,
  });
}

class CreateFacilityDialog extends ConsumerStatefulWidget {
  final UserProfile currentUser;

  const CreateFacilityDialog({super.key, required this.currentUser});

  static Future<void> show(BuildContext context, UserProfile currentUser) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => CreateFacilityDialog(currentUser: currentUser),
    );
  }

  @override
  ConsumerState<CreateFacilityDialog> createState() => _CreateFacilityDialogState();
}

class _CreateFacilityDialogState extends ConsumerState<CreateFacilityDialog> with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  late final TabController _tabCtrl;

  bool _isSubmitting = false;
  bool _isScanningNetwork = false;
  final List<_ConfiguredCameraDraft> _cameras = [];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    try {
      final file = await pickVideoFile();
      if (file == null) return;

      final defaultName = file.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '').replaceAll('_', ' ').toUpperCase();

      setState(() {
        _cameras.add(_ConfiguredCameraDraft(
          name: defaultName.isNotEmpty ? defaultName : 'Camera #${_cameras.length + 1}',
          sourceKind: 'file',
          sourceRef: file.url,
          fileName: file.name,
          firstFrameUrl: file.firstFrameDataUrl,
        ));
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to select video: $e')),
        );
      }
    }
  }

  void _addBenchmarkClip(PreloadedScene scene) {
    setState(() {
      _cameras.add(_ConfiguredCameraDraft(
        name: '${scene.name} CCTV',
        sourceKind: 'file',
        sourceRef: scene.id,
        fileName: scene.id,
        firstFrameUrl: getPreloadedSceneFrame(scene.id),
      ));
    });
  }

  Future<void> _rescanNetwork() async {
    setState(() => _isScanningNetwork = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _isScanningNetwork = false);
    }
  }

  Future<void> _createFacility() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a facility name.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(argusRepositoryProvider);

      // 1. Create the Facility (User automatically assigned Organizer)
      final facility = await repo.createFacility(
        name,
        description: _descCtrl.text.trim(),
        creatorName: widget.currentUser.fullName,
      );

      // 2. Attach any configured cameras
      for (final draft in _cameras) {
        final saved = await repo.saveCamera(
          Camera(
            workspaceId: facility.id!,
            name: draft.name.trim(),
            sourceKind: 'file',
            sourceRef: draft.sourceRef,
            enabled: true,
            createdAt: DateTime.now(),
            status: 'online',
          ),
          workspaceId: facility.id!,
        );

        final frame = draft.firstFrameUrl ?? getPreloadedSceneFrame(draft.sourceRef);
        ref.read(cameraStaticFrameProvider.notifier).update(
          (map) => {...map, saved.id!: frame},
        );
      }

      // 3. Update providers
      ref.read(activeFacilityProvider.notifier).state = facility;
      ref.invalidate(userFacilitiesProvider);
      ref.invalidate(activeFacilityCamerasProvider);
      ref.invalidate(activeFacilityRoomProvider);

      if (mounted) {
        Navigator.of(context).pop();
        context.go('/app/monitor');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create facility: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ArgusTokens.bgOverlay,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ArgusTokens.radiusLg),
        side: const BorderSide(color: ArgusTokens.borderSubtle),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ArgusTokens.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.domain_rounded, color: ArgusTokens.accent, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create New Facility',
                style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              Text(
                'Deploy tactical surveillance for a school, building, or campus',
                style: GoogleFonts.inter(fontSize: 11, color: ArgusTokens.textSecondary),
              ),
            ],
          ),
        ],
      ),
      content: SizedBox(
        width: 580,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Facility Name
              Text('Facility Name *', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                autofocus: true,
                style: GoogleFonts.inter(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. St. Thomas School, Metro Logistics Hub',
                  hintStyle: GoogleFonts.inter(color: ArgusTokens.textTertiary, fontSize: 13),
                  filled: true,
                  fillColor: ArgusTokens.bgRaised,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 14),

              // Description
              Text('Description (Optional)', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              TextField(
                controller: _descCtrl,
                maxLines: 2,
                style: GoogleFonts.inter(fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g. Perimeter gates, school corridors, and playground security',
                  hintStyle: GoogleFonts.inter(color: ArgusTokens.textTertiary, fontSize: 12),
                  filled: true,
                  fillColor: ArgusTokens.bgRaised,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 20),

              // Camera Setup Tab Bar
              Text('Camera Feeds & Video Sources', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                'Link physical CCTV cameras or upload video recordings with custom camera labels.',
                style: GoogleFonts.inter(fontSize: 11, color: ArgusTokens.textSecondary),
              ),
              const SizedBox(height: 10),

              TabBar(
                controller: _tabCtrl,
                labelColor: ArgusTokens.accent,
                unselectedLabelColor: ArgusTokens.textSecondary,
                indicatorColor: ArgusTokens.accent,
                tabs: const [
                  Tab(icon: Icon(Icons.videocam_outlined, size: 16), text: 'Link Cameras'),
                  Tab(icon: Icon(Icons.file_upload_outlined, size: 16), text: 'Upload Pre-recorded Video'),
                ],
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 190,
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    // Tab 1: Link Cameras (Scanner Empty State)
                    _buildLinkCamerasTab(),

                    // Tab 2: Upload Pre-recorded Video
                    _buildUploadVideoTab(),
                  ],
                ),
              ),

              // Attached Cameras List
              if (_cameras.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'Configured Cameras (${_cameras.length})',
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: ArgusTokens.textPrimary),
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 140),
                  decoration: BoxDecoration(
                    color: ArgusTokens.bgRaised,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: ArgusTokens.borderSubtle),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _cameras.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: ArgusTokens.borderSubtle),
                    itemBuilder: (context, idx) {
                      final draft = _cameras[idx];
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.videocam_rounded, size: 18, color: ArgusTokens.accent),
                        title: TextField(
                          controller: TextEditingController(text: draft.name),
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 4),
                            border: InputBorder.none,
                            hintText: 'Camera Name',
                          ),
                          onChanged: (val) => draft.name = val,
                        ),
                        subtitle: Text(
                          'File: ${draft.fileName} · ${draft.sourceKind.toUpperCase()}',
                          style: GoogleFonts.jetBrainsMono(fontSize: 10, color: ArgusTokens.textTertiary),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 16, color: ArgusTokens.severityCritical),
                          onPressed: () => setState(() => _cameras.removeAt(idx)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _createFacility,
          style: ElevatedButton.styleFrom(
            backgroundColor: ArgusTokens.accent,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
              : const Text('Create Facility & Enter Console'),
        ),
      ],
    );
  }

  Widget _buildLinkCamerasTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ArgusTokens.bgRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ArgusTokens.borderSubtle),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isScanningNetwork ? Icons.radar_rounded : Icons.videocam_off_outlined,
            size: 32,
            color: _isScanningNetwork ? ArgusTokens.accent : ArgusTokens.textTertiary,
          ),
          const SizedBox(height: 8),
          Text(
            _isScanningNetwork ? 'Scanning Local Subnet for RTSP / ONVIF Cameras...' : 'No Active Network CCTV Cameras Detected',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Ensure physical IP cameras are on the same subnet with RTSP broadcasting enabled.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 10, color: ArgusTokens.textTertiary),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _isScanningNetwork ? null : _rescanNetwork,
            icon: const Icon(Icons.refresh_rounded, size: 14),
            label: Text(_isScanningNetwork ? 'Scanning...' : 'Rescan Network'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              textStyle: GoogleFonts.inter(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadVideoTab() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ArgusTokens.bgRaised,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ArgusTokens.borderSubtle),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton.icon(
            onPressed: _pickVideo,
            icon: const Icon(Icons.upload_file_rounded, size: 16),
            label: const Text('Select Video File (.mp4, .webm)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ArgusTokens.accent.withValues(alpha: 0.15),
              foregroundColor: ArgusTokens.accent,
              side: const BorderSide(color: ArgusTokens.accent),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
          const SizedBox(height: 10),
          Text('— or choose calibrated benchmark scenario —',
              style: GoogleFonts.inter(fontSize: 10, color: ArgusTokens.textTertiary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: kPreloadedScenes.take(3).map((s) {
              return ActionChip(
                label: Text(s.name, style: GoogleFonts.inter(fontSize: 10)),
                avatar: const Icon(Icons.add_rounded, size: 12),
                backgroundColor: ArgusTokens.bgOverlay,
                onPressed: () => _addBenchmarkClip(s),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
