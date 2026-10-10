import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:argus_client/argus_client.dart';
import '../../app/theme/tokens.dart';
import '../../core/widgets/auth_required_barrier.dart';
import '../../core/widgets/hover_card.dart';
import '../../core/widgets/pulsing_beacon.dart';
import '../../data/repository_provider.dart';
import '../facilities/facility_providers.dart';
import 'room_providers.dart';

/// The Room Directory screen displays all operational Dispatch Rooms created
/// within the active Facility. Organizers and Supervisors can create dedicated
/// rooms bound to specific facility cameras to receive routed incident alerts.
/// Guards can view and participate in all rooms with invite codes concealed.
class RoomDirectoryScreen extends ConsumerStatefulWidget {
  const RoomDirectoryScreen({super.key});

  @override
  ConsumerState<RoomDirectoryScreen> createState() => _RoomDirectoryScreenState();
}

class _RoomDirectoryScreenState extends ConsumerState<RoomDirectoryScreen> {
  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final currentUser = userAsync.valueOrNull;

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: ArgusTokens.bgBase,
        body: AuthRequiredBarrier(
          description: 'You must be signed in to access Facility Operations Rooms.',
        ),
      );
    }

    final activeFacility = ref.watch(activeFacilityProvider);

    // If no active facility is currently selected, guide user to hub
    if (activeFacility == null) {
      return Scaffold(
        backgroundColor: ArgusTokens.bgBase,
        body: Center(
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
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ArgusTokens.accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                    border: Border.all(color: ArgusTokens.accent.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.hub_rounded, size: 36, color: ArgusTokens.accent),
                ),
                const SizedBox(height: 20),
                Text(
                  'No Active Facility Selected',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.sora(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: ArgusTokens.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Please select or join a Facility from the Facilities Hub to access and manage tactical dispatch rooms.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: ArgusTokens.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.go('/'),
                  icon: const Icon(Icons.domain_rounded, size: 18),
                  label: const Text('Go to Facilities Hub'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ArgusTokens.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final facilityRole = ref.watch(activeFacilityRoleProvider).toLowerCase();
    final canCreateRoom = facilityRole == 'organizer' || facilityRole == 'supervisor';

    final roomsAsync = ref.watch(activeFacilityRoomsProvider);
    final camerasAsync = ref.watch(activeFacilityCamerasProvider);
    final cameras = camerasAsync.valueOrNull ?? <Camera>[];

    return Scaffold(
      backgroundColor: ArgusTokens.bgBase,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ArgusTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Facility Title & Actions
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            activeFacility.name,
                            style: GoogleFonts.sora(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: ArgusTokens.textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: ArgusTokens.bgRaised,
                              borderRadius: BorderRadius.circular(ArgusTokens.radiusSm),
                              border: Border.all(color: ArgusTokens.borderSubtle),
                            ),
                            child: Text(
                              facilityRole.toUpperCase(),
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: ArgusTokens.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tactical Dispatch Rooms & Guard Incident Routing',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: ArgusTokens.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (canCreateRoom)
                  ElevatedButton.icon(
                    onPressed: () => _showCreateRoomDialog(context, activeFacility, cameras, currentUser.fullName, facilityRole),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Create Room'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ArgusTokens.accent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: ArgusTokens.space24),

            // Content Area
            roomsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PulsingBeacon(color: ArgusTokens.accent, size: 14),
                      SizedBox(height: 16),
                      Text(
                        'Loading facility dispatch rooms...',
                        style: TextStyle(color: ArgusTokens.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
              error: (err, _) => Container(
                padding: const EdgeInsets.all(ArgusTokens.space24),
                decoration: BoxDecoration(
                  color: ArgusTokens.bgRaised,
                  borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
                  border: Border.all(color: ArgusTokens.severityCritical.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: ArgusTokens.severityCritical, size: 28),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Error loading dispatch rooms: $err',
                        style: GoogleFonts.inter(color: ArgusTokens.textPrimary, fontSize: 13),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(activeFacilityRoomsProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (rooms) {
                if (rooms.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(ArgusTokens.space32),
                    decoration: BoxDecoration(
                      color: ArgusTokens.bgRaised,
                      borderRadius: BorderRadius.circular(ArgusTokens.radiusLg),
                      border: Border.all(color: ArgusTokens.borderSubtle),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: ArgusTokens.bgOverlay,
                            shape: BoxShape.circle,
                            border: Border.all(color: ArgusTokens.borderSubtle),
                          ),
                          child: const Icon(Icons.forum_outlined, size: 36, color: ArgusTokens.textTertiary),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No Dispatch Rooms in this Facility',
                          style: GoogleFonts.sora(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ArgusTokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: Text(
                            canCreateRoom
                                ? 'Create dedicated dispatch rooms by assigning specific cameras. Alerts from those cameras will be immediately routed to guards in the room.'
                                : 'No dispatch rooms have been set up by the facility organizer or supervisor yet.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: ArgusTokens.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                        if (canCreateRoom) ...[
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => _showCreateRoomDialog(
                              context,
                              activeFacility,
                              cameras,
                              currentUser.fullName,
                              facilityRole,
                            ),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Create First Room'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: ArgusTokens.accent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                // Render Grid of Rooms
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = constraints.maxWidth > 900
                        ? 3
                        : (constraints.maxWidth > 580 ? 2 : 1);

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.25,
                      ),
                      itemCount: rooms.length,
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        return _buildRoomCard(
                          context,
                          room,
                          canCreateRoom,
                          facilityRole,
                          currentUser.fullName,
                          cameras,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(
    BuildContext context,
    DispatchRoom room,
    bool canManage,
    String facilityRole,
    String currentUserName,
    List<Camera> allCameras,
  ) {
    // Resolve attached camera labels
    final attachedCams = allCameras.where((c) => room.cameraIds.contains(c.id)).toList();
    final displayCode = (canManage ? (room.organizerCode ?? room.supervisorCode ?? room.code) : null);

    return HoverCard(
      padding: const EdgeInsets.all(ArgusTokens.space20),
      borderRadius: ArgusTokens.radiusLg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Name & Code / Actions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      room.name,
                      style: GoogleFonts.sora(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ArgusTokens.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Created by ${room.createdByName}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: ArgusTokens.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (displayCode != null && displayCode.isNotEmpty) ...[
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: displayCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Room code $displayCode copied to clipboard!'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: ArgusTokens.bgOverlay,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: ArgusTokens.borderSubtle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          displayCode,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: ArgusTokens.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.copy_rounded, size: 10, color: ArgusTokens.textTertiary),
                      ],
                    ),
                  ),
                ),
              ],
              if (canManage) ...[
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 18, color: ArgusTokens.textSecondary),
                  color: ArgusTokens.bgOverlay,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: ArgusTokens.borderSubtle),
                  ),
                  onSelected: (action) {
                    if (action == 'edit') {
                      _showEditRoomDialog(context, room, allCameras, currentUserName);
                    } else if (action == 'delete') {
                      _confirmDeleteRoom(context, room, currentUserName);
                    }
                  },
                  itemBuilder: (ctx) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined, size: 16, color: ArgusTokens.textSecondary),
                          const SizedBox(width: 8),
                          Text('Edit Room', style: GoogleFonts.inter(fontSize: 13, color: ArgusTokens.textPrimary)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_outline_rounded, size: 16, color: ArgusTokens.severityCritical),
                          const SizedBox(width: 8),
                          Text('Delete Room', style: GoogleFonts.inter(fontSize: 13, color: ArgusTokens.severityCritical)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),

          const SizedBox(height: 10),
          // Description
          if (room.description != null && room.description!.isNotEmpty)
            Expanded(
              child: Text(
                room.description!,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: ArgusTokens.textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const Spacer(),

          // Camera Feeds Attached
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.videocam_outlined, size: 14, color: ArgusTokens.textTertiary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  room.cameraIds.isEmpty
                      ? 'All Facility Cameras'
                      : (attachedCams.isEmpty
                          ? '${room.cameraIds.length} Camera Feed(s)'
                          : attachedCams.map((c) => c.name).join(', ')),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: ArgusTokens.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          // Bottom CTA: Enter Dispatch Room
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.go('/app/rooms/${room.id}');
              },
              icon: const Icon(Icons.meeting_room_rounded, size: 16),
              label: const Text('Enter Dispatch Room'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ArgusTokens.bgOverlay,
                foregroundColor: ArgusTokens.textPrimary,
                side: const BorderSide(color: ArgusTokens.borderSubtle),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showCreateRoomDialog(
    BuildContext context,
    Workspace facility,
    List<Camera> cameras,
    String creatorName,
    String creatorRole,
  ) async {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final selectedCamIds = <int>{};

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: ArgusTokens.bgOverlay,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ArgusTokens.radiusLg),
            side: const BorderSide(color: ArgusTokens.borderSubtle),
          ),
          title: Row(
            children: [
              const Icon(Icons.add_circle_outline_rounded, color: ArgusTokens.accent),
              const SizedBox(width: 10),
              Text(
                'Create Dispatch Room',
                style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Setup a tactical operations room for "${facility.name}". Only alerts from attached cameras will be routed to this room.',
                    style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: 16),

                  // Room Name
                  Text('Room Name *', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. ICU Safety Dispatch, Main Gate Patrol',
                      filled: true,
                      fillColor: ArgusTokens.bgRaised,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Description
                  Text('Description', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Operational scope and response instructions...',
                      filled: true,
                      fillColor: ArgusTokens.bgRaised,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Attached Cameras
                  Row(
                    children: [
                      Text('Route Alerts From Cameras', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      if (cameras.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            setDlgState(() {
                              if (selectedCamIds.length == cameras.length) {
                                selectedCamIds.clear();
                              } else {
                                selectedCamIds.addAll(cameras.map((c) => c.id!).whereType<int>());
                              }
                            });
                          },
                          child: Text(
                            selectedCamIds.length == cameras.length ? 'Clear All' : 'Select All',
                            style: GoogleFonts.inter(fontSize: 11, color: ArgusTokens.accent),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (cameras.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ArgusTokens.bgRaised,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ArgusTokens.borderSubtle),
                      ),
                      child: Text(
                        'No cameras linked to this facility yet. You can attach camera feeds after linking or onboarding them.',
                        style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textTertiary),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: cameras.map((c) {
                        final isSelected = selectedCamIds.contains(c.id);
                        return FilterChip(
                          label: Text(c.name, style: GoogleFonts.inter(fontSize: 12)),
                          selected: isSelected,
                          selectedColor: ArgusTokens.accent.withValues(alpha: 0.2),
                          checkmarkColor: ArgusTokens.accent,
                          backgroundColor: ArgusTokens.bgRaised,
                          onSelected: (selected) {
                            setDlgState(() {
                              if (selected) {
                                selectedCamIds.add(c.id!);
                              } else {
                                selectedCamIds.remove(c.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;

                try {
                  final repo = ref.read(argusRepositoryProvider);
                  await repo.createRoom(
                    name,
                    description: descCtrl.text.trim(),
                    cameraIds: selectedCamIds.toList(),
                    workspaceId: facility.id,
                    creatorName: creatorName,
                    creatorRole: creatorRole,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  ref.invalidate(activeFacilityRoomsProvider);
                  ref.invalidate(roomsListProvider);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Dispatch Room created successfully.')),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Failed to create room: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ArgusTokens.accent,
                foregroundColor: Colors.black,
              ),
              child: const Text('Create Room'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditRoomDialog(
    BuildContext context,
    DispatchRoom room,
    List<Camera> cameras,
    String userName,
  ) async {
    final nameCtrl = TextEditingController(text: room.name);
    final descCtrl = TextEditingController(text: room.description ?? '');
    final selectedCamIds = <int>{...room.cameraIds};

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: ArgusTokens.bgOverlay,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ArgusTokens.radiusLg),
            side: const BorderSide(color: ArgusTokens.borderSubtle),
          ),
          title: Row(
            children: [
              const Icon(Icons.edit_note_rounded, color: ArgusTokens.accent),
              const SizedBox(width: 10),
              Text(
                'Edit Dispatch Room',
                style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Modify room configuration and attached camera feeds.',
                    style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  Text('Room Name *', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: ArgusTokens.bgRaised,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text('Description', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: ArgusTokens.bgRaised,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text('Route Alerts From Cameras', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  if (cameras.isEmpty)
                    Text('No cameras configured.',
                        style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textTertiary))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: cameras.map((c) {
                        final isSelected = selectedCamIds.contains(c.id);
                        return FilterChip(
                          label: Text(c.name, style: GoogleFonts.inter(fontSize: 12)),
                          selected: isSelected,
                          selectedColor: ArgusTokens.accent.withValues(alpha: 0.2),
                          checkmarkColor: ArgusTokens.accent,
                          backgroundColor: ArgusTokens.bgRaised,
                          onSelected: (selected) {
                            setDlgState(() {
                              if (selected) {
                                selectedCamIds.add(c.id!);
                              } else {
                                selectedCamIds.remove(c.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final newName = nameCtrl.text.trim();
                if (newName.isEmpty) return;

                try {
                  final repo = ref.read(argusRepositoryProvider);
                  await repo.updateRoom(
                    room.id!,
                    userName: userName,
                    name: newName,
                    description: descCtrl.text.trim(),
                    cameraIds: selectedCamIds.toList(),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  ref.invalidate(activeFacilityRoomsProvider);
                  ref.invalidate(roomsListProvider);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Room updated successfully.')),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Failed to update room: $e')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ArgusTokens.accent,
                foregroundColor: Colors.black,
              ),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteRoom(
    BuildContext context,
    DispatchRoom room,
    String userName,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ArgusTokens.bgOverlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ArgusTokens.radiusLg),
          side: const BorderSide(color: ArgusTokens.borderSubtle),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: ArgusTokens.severityCritical),
            const SizedBox(width: 10),
            Text('Delete Dispatch Room', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${room.name}"? This action cannot be undone and will remove all message history for this room.',
          style: GoogleFonts.inter(fontSize: 13, color: ArgusTokens.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: ArgusTokens.severityCritical),
            child: const Text('Delete Room'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final repo = ref.read(argusRepositoryProvider);
        await repo.deleteRoom(room.id!, userName: userName);
        ref.invalidate(activeFacilityRoomsProvider);
        ref.invalidate(roomsListProvider);
        messenger.showSnackBar(
          const SnackBar(content: Text('Dispatch Room deleted.')),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(content: Text('Failed to delete room: $e')),
        );
      }
    }
  }
}
