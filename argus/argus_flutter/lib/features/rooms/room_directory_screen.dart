import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:argus_client/argus_client.dart';
import '../../app/theme/tokens.dart';
import '../../core/widgets/hover_card.dart';
import '../../core/widgets/pulsing_beacon.dart';
import '../../data/repository_provider.dart';
import 'room_providers.dart';

class RoomDirectoryScreen extends ConsumerStatefulWidget {
  const RoomDirectoryScreen({super.key});

  @override
  ConsumerState<RoomDirectoryScreen> createState() => _RoomDirectoryScreenState();
}

class _RoomDirectoryScreenState extends ConsumerState<RoomDirectoryScreen> {
  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(roomsListProvider);
    final userAsync = ref.watch(currentUserProvider);
    final currentUser = userAsync.valueOrNull;

    return Scaffold(
      backgroundColor: ArgusTokens.bgBase,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(ArgusTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header & Actions
            _buildHeader(context, currentUser),
            const SizedBox(height: ArgusTokens.space24),

            // Room Directory Grid
            roomsAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(48.0),
                  child: CircularProgressIndicator(),
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
                    const Icon(Icons.error_outline_rounded, color: ArgusTokens.severityCritical),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Failed to load dispatch rooms: $err',
                          style: GoogleFonts.inter(color: ArgusTokens.textPrimary)),
                    ),
                    TextButton(
                      onPressed: () => ref.invalidate(roomsListProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (rooms) {
                if (rooms.isEmpty) {
                  return _buildEmptyState(context, currentUser);
                }
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 420,
                    mainAxisExtent: 250,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: rooms.length,
                  itemBuilder: (context, idx) {
                    final room = rooms[idx];
                    return _buildRoomCard(context, room);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProfile? currentUser) {
    final role = (currentUser?.role ?? 'organizer').toUpperCase();

    return Container(
      padding: const EdgeInsets.all(ArgusTokens.space24),
      decoration: BoxDecoration(
        color: ArgusTokens.bgRaised,
        borderRadius: BorderRadius.circular(ArgusTokens.radiusLg),
        border: Border.all(color: ArgusTokens.borderSubtle),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ArgusTokens.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ArgusTokens.accent.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.hub_outlined, color: ArgusTokens.accent, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Operations Dispatch Rooms',
                          style: GoogleFonts.sora(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: ArgusTokens.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Live War Rooms for Guard Dispatch, Cross-Device Collaboration & Sovereign Real-Time Alerts',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: ArgusTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Current user banner
                Row(
                  children: [
                    Text(
                      'Signed in as:',
                      style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textTertiary),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: ArgusTokens.bgOverlay,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ArgusTokens.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            role == 'ORGANIZER'
                                ? Icons.admin_panel_settings_rounded
                                : role == 'SUPERVISOR'
                                    ? Icons.security_rounded
                                    : Icons.shield_rounded,
                            size: 14,
                            color: ArgusTokens.accent,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${currentUser?.fullName ?? 'Operator'} · $role',
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: ArgusTokens.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Actions
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showJoinRoomDialog(context, currentUser),
                icon: const Icon(Icons.pin_outlined, size: 16),
                label: const Text('Join with Code'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ArgusTokens.textPrimary,
                  side: const BorderSide(color: ArgusTokens.borderSubtle),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showCreateRoomDialog(context, currentUser),
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Create New Room'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ArgusTokens.accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, UserProfile? currentUser) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: ArgusTokens.bgRaised,
        borderRadius: BorderRadius.circular(ArgusTokens.radiusLg),
        border: Border.all(color: ArgusTokens.borderSubtle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: ArgusTokens.bgOverlay,
              shape: BoxShape.circle,
              border: Border.all(color: ArgusTokens.borderSubtle),
            ),
            child: const Icon(Icons.meeting_room_outlined, size: 40, color: ArgusTokens.textTertiary),
          ),
          const SizedBox(height: 18),
          Text(
            'No Active Dispatch Rooms',
            style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first operations room to coordinate responders and receive live camera alerts.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 13, color: ArgusTokens.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showCreateRoomDialog(context, currentUser),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Create Dispatch Room'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(BuildContext context, DispatchRoom room) {
    return HoverCard(
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
            // Top Row: Code Pill & Status Beacon
            Row(
              children: [
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: room.code));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Room code ${room.code} copied! Share with guards/supervisors.'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ArgusTokens.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: ArgusTokens.accent.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          room.code,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: ArgusTokens.accent,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.copy_rounded, size: 11, color: ArgusTokens.accent),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                const PulsingBeacon(color: ArgusTokens.success, size: 8),
                const SizedBox(width: 6),
                Text(
                  'LIVE DISPATCH',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: ArgusTokens.success,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Room Title
            Text(
              room.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.sora(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: ArgusTokens.textPrimary,
              ),
            ),
            const SizedBox(height: 4),

            // Description
            Expanded(
              child: Text(
                room.description ?? 'Active tactical operations channel for real-time guard alerting and team coordination.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: ArgusTokens.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Meta Details
            Row(
              children: [
                const Icon(Icons.videocam_outlined, size: 13, color: ArgusTokens.textTertiary),
                const SizedBox(width: 4),
                Text(
                  room.cameraIds.isEmpty ? 'All Cameras' : '${room.cameraIds.length} Cameras',
                  style: GoogleFonts.inter(fontSize: 11, color: ArgusTokens.textSecondary),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.person_outline, size: 13, color: ArgusTokens.textTertiary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'By ${room.createdByName}',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontSize: 11, color: ArgusTokens.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Enter Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/app/rooms/${room.code}'),
                icon: const Icon(Icons.arrow_forward_rounded, size: 15),
                label: const Text('Enter Dispatch Room'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ArgusTokens.bgOverlay,
                  foregroundColor: ArgusTokens.textPrimary,
                  side: const BorderSide(color: ArgusTokens.borderSubtle),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateRoomDialog(BuildContext context, UserProfile? currentUser) async {
    final repo = ref.read(argusRepositoryProvider);
    final cameras = await repo.listCameras();

    if (!context.mounted) return;

    final nameCtrl = TextEditingController(text: 'Terminal Sector Alpha');
    final descCtrl = TextEditingController(text: 'Operations command hub for tactical response and live alerts.');
    final selectedCamIds = <int>{...cameras.map((c) => c.id!)};

    showDialog(
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
              const Icon(Icons.add_circle_outline, color: ArgusTokens.accent),
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
                    'A unique 4-character code (e.g. ARG-7842) will be generated automatically. Team members can join from any device with this code.',
                    style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Text('Room Name', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      hintText: 'e.g. Platform 1 Security Team',
                      filled: true,
                      fillColor: ArgusTokens.bgRaised,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Description (Optional)', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'e.g. Monitoring perimeter gates and fall detection ladder',
                      filled: true,
                      fillColor: ArgusTokens.bgRaised,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Attached Cameras', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(
                    'Alerts from checked cameras will automatically escalate to this room.',
                    style: GoogleFonts.inter(fontSize: 11, color: ArgusTokens.textTertiary),
                  ),
                  const SizedBox(height: 8),
                  if (cameras.isEmpty)
                    Text('No cameras configured yet. Alerts from all future cameras will route here.',
                        style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textSecondary))
                  else
                    Container(
                      constraints: const BoxConstraints(maxHeight: 140),
                      decoration: BoxDecoration(
                        color: ArgusTokens.bgRaised,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ArgusTokens.borderSubtle),
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        children: cameras.map((c) {
                          final isChecked = selectedCamIds.contains(c.id);
                          return CheckboxListTile(
                            dense: true,
                            value: isChecked,
                            title: Text(c.name, style: GoogleFonts.inter(fontSize: 13)),
                            onChanged: (val) {
                              setDlgState(() {
                                if (val == true) {
                                  selectedCamIds.add(c.id!);
                                } else {
                                  selectedCamIds.remove(c.id!);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
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
                final name = nameCtrl.text.trim();
                if (name.isEmpty) return;
                Navigator.pop(ctx);

                try {
                  final room = await repo.createRoom(
                    name,
                    description: descCtrl.text.trim(),
                    cameraIds: selectedCamIds.toList(),
                    creatorName: currentUser?.fullName ?? 'Head Organizer',
                    creatorRole: currentUser?.role ?? 'organizer',
                  );
                  ref.invalidate(roomsListProvider);
                  if (context.mounted) {
                    context.go('/app/rooms/${room.code}');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error creating room: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ArgusTokens.accent,
                foregroundColor: Colors.black,
              ),
              child: const Text('Create & Enter Room'),
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinRoomDialog(BuildContext context, UserProfile? currentUser) {
    final codeCtrl = TextEditingController();
    final nameCtrl = TextEditingController(text: currentUser?.fullName ?? 'Operator 1');
    String selectedRole = currentUser?.role ?? 'member';

    showDialog(
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
              const Icon(Icons.vpn_key_outlined, color: ArgusTokens.accent),
              const SizedBox(width: 10),
              Text('Join Room with Code', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter the 4-part code given by the organizer (e.g. ARG-7842). You will join the live dispatch room immediately.',
                  style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textSecondary),
                ),
                const SizedBox(height: 16),
                Text('Room Code', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: codeCtrl,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  style: GoogleFonts.jetBrainsMono(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                  decoration: InputDecoration(
                    hintText: 'ARG-7842',
                    hintStyle: GoogleFonts.jetBrainsMono(color: ArgusTokens.textTertiary),
                    filled: true,
                    fillColor: ArgusTokens.bgRaised,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 14),
                Text('Your Display Name', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. Officer Vance',
                    filled: true,
                    fillColor: ArgusTokens.bgRaised,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 14),
                Text('Join As Role', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildRoleChip('organizer', 'Organizer', Icons.admin_panel_settings_rounded, selectedRole, (r) {
                      setDlgState(() => selectedRole = r);
                    }),
                    const SizedBox(width: 8),
                    _buildRoleChip('supervisor', 'Supervisor', Icons.security_rounded, selectedRole, (r) {
                      setDlgState(() => selectedRole = r);
                    }),
                    const SizedBox(width: 8),
                    _buildRoleChip('member', 'Member / Guard', Icons.shield_rounded, selectedRole, (r) {
                      setDlgState(() => selectedRole = r);
                    }),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final rawCode = codeCtrl.text.trim();
                final name = nameCtrl.text.trim();
                if (rawCode.isEmpty || name.isEmpty) return;
                final cleanCode = rawCode.startsWith('ARG-') ? rawCode : 'ARG-$rawCode';

                final repo = ref.read(argusRepositoryProvider);
                try {
                  final room = await repo.joinRoom(
                    cleanCode,
                    userName: name,
                    userRole: selectedRole,
                  );

                  if (room == null) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Room "$cleanCode" was not found or is closed.')),
                      );
                    }
                    return;
                  }

                  // Update current user
                  await ref.read(currentUserProvider.notifier).login(name, selectedRole);

                  if (ctx.mounted) Navigator.pop(ctx);
                  ref.invalidate(roomsListProvider);
                  if (context.mounted) {
                    context.go('/app/rooms/${room.code}');
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to join room: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ArgusTokens.accent,
                foregroundColor: Colors.black,
              ),
              child: const Text('Join Room'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleChip(String roleKey, String label, IconData icon, String current, Function(String) onSelect) {
    final isSelected = current == roleKey;
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(roleKey),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? ArgusTokens.accent.withValues(alpha: 0.15) : ArgusTokens.bgRaised,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? ArgusTokens.accent : ArgusTokens.borderSubtle,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 16, color: isSelected ? ArgusTokens.accent : ArgusTokens.textTertiary),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? ArgusTokens.accent : ArgusTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
