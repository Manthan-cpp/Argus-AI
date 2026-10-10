import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:argus_client/argus_client.dart';
import '../../app/theme/tokens.dart';
import '../../core/widgets/auth_required_barrier.dart';
import '../../core/widgets/pulsing_beacon.dart';
import '../../data/repository_provider.dart';
import '../facilities/facility_providers.dart';
import 'room_providers.dart';

class DispatchRoomScreen extends ConsumerStatefulWidget {
  final String code;

  const DispatchRoomScreen({super.key, required this.code});

  @override
  ConsumerState<DispatchRoomScreen> createState() => _DispatchRoomScreenState();
}

class _DispatchRoomScreenState extends ConsumerState<DispatchRoomScreen> {
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  DispatchRoom? _room;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRoom();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRoom() async {
    try {
      final repo = ref.read(argusRepositoryProvider);
      final user = ref.read(currentUserProvider).valueOrNull;
      final numericId = int.tryParse(widget.code);
      DispatchRoom? room;
      if (numericId != null) {
        room = await repo.getRoom(numericId, userName: user?.fullName);
      }
      room ??= await repo.getRoomByCode(widget.code);
      if (room == null) {
        final activeFacility = ref.read(activeFacilityProvider);
        if (activeFacility?.id != null) {
          room = await repo.getRoomForFacility(activeFacility!.id!, userName: user?.fullName);
        }
      }
      if (room == null && user != null) {
        final userRooms = await repo.listRooms(userName: user.fullName);
        if (userRooms.isNotEmpty) {
          room = userRooms.first;
        }
      }

      if (mounted) {
        if (room == null) {
          setState(() {
            _error = 'Dispatch room "${widget.code}" not found.';
            _isLoading = false;
          });
        } else {
          setState(() {
            _room = room;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading room: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _room == null) return;
    _msgCtrl.clear();

    final user = ref.read(currentUserProvider).valueOrNull;
    final senderName = user?.fullName ?? 'Operator';
    final members = ref.read(roomMembersProvider(_room!.id!)).valueOrNull ?? [];
    final currentMember = members
        .where((m) =>
            m.userName.toLowerCase() == (user?.fullName.toLowerCase() ?? '') ||
            (user?.id != null && m.userId == user?.id))
        .firstOrNull;
    final isCreator =
        _room!.createdByName.toLowerCase() == (user?.fullName.toLowerCase() ?? '');
    final facilityRole = ref.read(activeFacilityRoleProvider).toLowerCase();
    final senderRole =
        (currentMember?.userRole ?? (isCreator ? 'organizer' : facilityRole)).toLowerCase();

    try {
      await ref.read(roomMessagesProvider(_room!.id!).notifier).sendMessage(
            text,
            senderName: senderName,
            senderRole: senderRole,
            senderId: user?.id,
          );
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    }
  }

  Future<void> _showEditRoomDialog() async {
    if (_room == null) return;
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final repo = ref.read(argusRepositoryProvider);
    final cameras = await repo.listCameras(workspaceId: _room!.workspaceId);

    if (!mounted) return;

    final nameCtrl = TextEditingController(text: _room!.name);
    final descCtrl = TextEditingController(text: _room!.description ?? '');
    final selectedCamIds = <int>{..._room!.cameraIds};

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
                    'Modify the configuration and connected camera feeds for this room.',
                    style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textSecondary),
                  ),
                  const SizedBox(height: 16),

                  // Room Name
                  Text('Room Name', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
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

                  // Description
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

                  // Attached Cameras
                  Text('Attached Cameras', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
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
                  final updated = await repo.updateRoom(
                    _room!.id!,
                    userName: user.fullName,
                    name: newName,
                    description: descCtrl.text.trim(),
                    cameraIds: selectedCamIds.toList(),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    setState(() => _room = updated);
                    ref.invalidate(roomsListProvider);
                    ref.invalidate(roomMessagesProvider(_room!.id!));
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Room updated successfully.')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    messenger.showSnackBar(
                      SnackBar(content: Text('Failed to update room: $e')),
                    );
                  }
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


  Future<void> _deleteRoom() async {
    if (_room == null) return;
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
            const Icon(Icons.delete_forever_rounded, color: ArgusTokens.severityCritical),
            const SizedBox(width: 10),
            Text('Delete Dispatch Room', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete "${_room!.name}"? All active message streams and responder sessions will be terminated.',
          style: GoogleFonts.inter(fontSize: 13, color: ArgusTokens.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ArgusTokens.severityCritical,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete Room'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final user = ref.read(currentUserProvider).valueOrNull;
      final repo = ref.read(argusRepositoryProvider);
      await repo.deleteRoom(_room!.id!, userName: user?.fullName ?? 'Operator');
      ref.invalidate(roomsListProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dispatch Room "${_room!.name}" deleted.')),
        );
        context.go('/app/rooms');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete room: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: ArgusTokens.bgBase,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _room == null) {
      return Scaffold(
        backgroundColor: ArgusTokens.bgBase,
        appBar: AppBar(
          backgroundColor: ArgusTokens.bgRaised,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/app/rooms'),
          ),
          title: const Text('Room Not Found'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48, color: ArgusTokens.severityCritical),
              const SizedBox(height: 16),
              Text(_error ?? 'Room not found',
                  style: GoogleFonts.inter(color: ArgusTokens.textPrimary, fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/app/rooms'),
                child: const Text('Back to Rooms Directory'),
              ),
            ],
          ),
        ),
      );
    }

    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 950;
    final messagesAsync = ref.watch(roomMessagesProvider(_room!.id!));
    final membersAsync = ref.watch(roomMembersProvider(_room!.id!));
    final userAsync = ref.watch(currentUserProvider);
    final currentUser = userAsync.valueOrNull;

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: ArgusTokens.bgBase,
        appBar: AppBar(
          backgroundColor: ArgusTokens.bgRaised,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/app/rooms'),
          ),
          title: Text(_room?.name ?? 'Dispatch Room'),
        ),
        body: const AuthRequiredBarrier(
          description:
              'You must be signed in to access this dispatch room and participate in communications.',
        ),
      );
    }

    final members = membersAsync.valueOrNull ?? [];
    final currentMember = members
        .where((m) =>
            m.userName.toLowerCase() == currentUser.fullName.toLowerCase() ||
            (currentUser.id != null && m.userId == currentUser.id))
        .firstOrNull;
    final isCreator =
        _room!.createdByName.toLowerCase() == currentUser.fullName.toLowerCase();
    final myRole =
        (currentMember?.userRole ?? (isCreator ? 'organizer' : 'guard')).toLowerCase();

    return Scaffold(
      backgroundColor: ArgusTokens.bgBase,
      body: Column(
        children: [
          // Tactical Header
          _buildTopBar(context, members.length, myRole),

          // Main Room Area (Live Stream + Side Intel Panel)
          Expanded(
            child: Row(
              children: [
                // Live Stream Feed & Input
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // Stream Messages
                      Expanded(
                        child: messagesAsync.when(
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, _) => Center(
                            child: Text('Error loading live stream: $err',
                                style: GoogleFonts.inter(color: ArgusTokens.severityCritical)),
                          ),
                          data: (messages) {
                            if (messages.isEmpty) {
                              return _buildStreamEmptyState();
                            }
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (_scrollCtrl.hasClients) {
                                _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
                              }
                            });
                            return ListView.builder(
                              controller: _scrollCtrl,
                              padding: const EdgeInsets.all(ArgusTokens.space16),
                              itemCount: messages.length,
                              itemBuilder: (context, idx) {
                                final msg = messages[idx];
                                return _buildMessageItem(context, msg, currentUser);
                              },
                            );
                          },
                        ),
                      ),

                      // Input Bar
                      _buildInputBar(currentUser, myRole),
                    ],
                  ),
                ),

                // Side Tactical Panel (Desktop only or Drawer)
                if (isDesktop)
                  Container(
                    width: 310,
                    decoration: const BoxDecoration(
                      color: ArgusTokens.bgRaised,
                      border: Border(left: BorderSide(color: ArgusTokens.borderSubtle)),
                    ),
                    child: _buildSideIntelPanel(members, myRole),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, int membersCount, String myRole) {
    final isGuard = myRole == 'guard';

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: ArgusTokens.space16),
      decoration: const BoxDecoration(
        color: ArgusTokens.bgRaised,
        border: Border(bottom: BorderSide(color: ArgusTokens.borderSubtle)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, size: 20),
            tooltip: 'Back to Dispatch Rooms',
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/app/rooms');
              }
            },
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    _room!.name,
                    style: GoogleFonts.sora(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: ArgusTokens.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!isGuard) ...[
                    // Code Chip with 1-click copy (Organizers & Supervisors only)
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: _room!.code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Room Code ${_room!.code} copied to clipboard!'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: ArgusTokens.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: ArgusTokens.accent.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _room!.code,
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: ArgusTokens.accent,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.copy_rounded, size: 10, color: ArgusTokens.accent),
                          ],
                        ),
                      ),
                    ),
                  ] else ...[
                    // Guard status tag (codes are concealed)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: ArgusTokens.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: ArgusTokens.success.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'GUARD POST',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: ArgusTokens.success,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const PulsingBeacon(color: ArgusTokens.success, size: 6),
                  const SizedBox(width: 6),
                  Text(
                    'LIVE DISPATCH FEED · $membersCount Connected',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: ArgusTokens.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          if (!isGuard) ...[
            OutlinedButton.icon(
              onPressed: _showEditRoomDialog,
              icon: const Icon(Icons.edit_outlined, size: 14, color: ArgusTokens.accent),
              label: const Text('Edit Room'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ArgusTokens.accent,
                side: BorderSide(color: ArgusTokens.accent.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: _deleteRoom,
              icon: const Icon(Icons.delete_outline_rounded, size: 14, color: ArgusTokens.severityCritical),
              label: const Text('Delete Room'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ArgusTokens.severityCritical,
                side: BorderSide(color: ArgusTokens.severityCritical.withValues(alpha: 0.4)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                textStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStreamEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ArgusTokens.bgRaised,
              shape: BoxShape.circle,
              border: Border.all(color: ArgusTokens.borderSubtle),
            ),
            child: const Icon(Icons.forum_outlined, size: 32, color: ArgusTokens.textTertiary),
          ),
          const SizedBox(height: 12),
          Text('Live Dispatch Stream Initialized',
              style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            'Team messages and automated camera alerts will appear here in real time.',
            style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(BuildContext context, RoomMessage msg, UserProfile? currentUser) {
    // 1. System Alert Card
    if (msg.kind == 'system_alert') {
      return _buildSystemAlertCard(context, msg);
    }

    // 2. Action Log
    if (msg.kind == 'action_log') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: ArgusTokens.bgOverlay,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ArgusTokens.borderSubtle),
            ),
            child: Text(
              msg.content,
              style: GoogleFonts.inter(fontSize: 11, color: ArgusTokens.textTertiary),
            ),
          ),
        ),
      );
    }

    // 3. Chat Message
    final isMe = currentUser != null &&
        (msg.senderId == currentUser.id || msg.senderName == currentUser.fullName);
    final rawRole = (msg.senderRole ?? 'guard').toUpperCase();
    final role = rawRole == 'MEMBER' ? 'GUARD' : rawRole;

    Color roleColor = ArgusTokens.textSecondary;
    if (role == 'ORGANIZER') roleColor = Colors.amberAccent;
    if (role == 'SUPERVISOR') roleColor = Colors.cyanAccent;
    if (role == 'GUARD') roleColor = ArgusTokens.success;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 15,
              backgroundColor: ArgusTokens.bgRaised,
              child: Text(
                msg.senderName.isNotEmpty ? msg.senderName[0].toUpperCase() : '?',
                style: GoogleFonts.sora(fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? ArgusTokens.accent.withValues(alpha: 0.12) : ArgusTokens.bgRaised,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isMe
                      ? ArgusTokens.accent.withValues(alpha: 0.35)
                      : ArgusTokens.borderSubtle,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        msg.senderName,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: ArgusTokens.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: roleColor.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          role,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: roleColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${msg.createdAt.hour.toString().padLeft(2, '0')}:${msg.createdAt.minute.toString().padLeft(2, '0')}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          color: ArgusTokens.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    msg.content,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: ArgusTokens.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 15,
              backgroundColor: ArgusTokens.accent.withValues(alpha: 0.2),
              child: Text(
                currentUser.fullName.isNotEmpty ? currentUser.fullName[0].toUpperCase() : 'ME',
                style: GoogleFonts.sora(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: ArgusTokens.accent,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSystemAlertCard(BuildContext context, RoomMessage msg) {
    final cameraName = msg.cameraName ?? 'Platform 1';
    final severity = (msg.severity ?? 'CRITICAL').toUpperCase();

    final isCritical = severity == 'CRITICAL';
    final borderColor = isCritical ? ArgusTokens.severityCritical : ArgusTokens.severityMedium;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(ArgusTokens.space16),
      decoration: BoxDecoration(
        color: ArgusTokens.bgRaised,
        borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withValues(alpha: 0.15),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: borderColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(Icons.security_rounded, color: borderColor, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                'ARGUS SAFETY ESCALATION',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: borderColor,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: borderColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: borderColor.withValues(alpha: 0.5)),
                ),
                child: Text(
                  severity,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: borderColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Location
          Row(
            children: [
              Text(
                'Location:',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ArgusTokens.textSecondary,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Near $cameraName camera',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ArgusTokens.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Actionable Guard Call-to-Action
          Text(
            msg.content,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: ArgusTokens.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final user = ref.read(currentUserProvider).valueOrNull;
                  final name = user?.fullName ?? 'Operator';
                  if (msg.incidentId != null) {
                    final repo = ref.read(argusRepositoryProvider);
                    await repo.acknowledge(msg.incidentId!, note: 'Acknowledged via Dispatch Room ${_room!.code}');
                  }
                  await ref.read(roomMessagesProvider(_room!.id!).notifier).sendMessage(
                        '$name acknowledged alert at $cameraName. Investigating on-ground.',
                        senderName: name,
                        senderRole: user?.role ?? 'member',
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Alert acknowledged & dispatched to room stream.')),
                    );
                  }
                },
                icon: const Icon(Icons.check_circle_outline, size: 14),
                label: const Text('Acknowledge Alert'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ArgusTokens.accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => context.go('/app/monitor'),
                icon: const Icon(Icons.visibility_rounded, size: 14),
                label: const Text('View Live Feed'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ArgusTokens.textPrimary,
                  side: const BorderSide(color: ArgusTokens.borderSubtle),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: GoogleFonts.inter(fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(UserProfile? currentUser, String myRole) {
    final name = currentUser?.fullName ?? 'Operator';
    final role = myRole.toUpperCase();

    return Container(
      padding: const EdgeInsets.all(ArgusTokens.space12),
      decoration: const BoxDecoration(
        color: ArgusTokens.bgRaised,
        border: Border(top: BorderSide(color: ArgusTokens.borderSubtle)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              onSubmitted: (_) => _sendMessage(),
              style: GoogleFonts.inter(fontSize: 13, color: ArgusTokens.textPrimary),
              decoration: InputDecoration(
                hintText: 'Message dispatch room as $name ($role)...',
                hintStyle: GoogleFonts.inter(fontSize: 13, color: ArgusTokens.textTertiary),
                filled: true,
                fillColor: ArgusTokens.bgOverlay,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: ArgusTokens.borderSubtle),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _sendMessage,
            icon: const Icon(Icons.send_rounded, color: ArgusTokens.accent),
            tooltip: 'Send message',
          ),
        ],
      ),
    );
  }

  Widget _buildSideIntelPanel(List<RoomMember> members, String myRole) {
    final isGuard = myRole == 'guard';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(ArgusTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isGuard) ...[
            // Role-specific join codes (Only for Organizer & Supervisor)
            Row(
              children: [
                const Icon(Icons.vpn_key_outlined, size: 16, color: ArgusTokens.accent),
                const SizedBox(width: 6),
                Text(
                  'ROLE INVITE CODES',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: ArgusTokens.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'The code sent to a team member dictates their operational role automatically upon joining.',
              style: GoogleFonts.inter(fontSize: 11, color: ArgusTokens.textTertiary, height: 1.3),
            ),
            const SizedBox(height: 12),

            // Organizer Code Card
            _buildRoleCodeCard(
              roleTitle: 'Organizer Code',
              roleDesc: 'Full authority & room administration',
              code: _room!.organizerCode ?? _room!.code,
              color: Colors.amberAccent,
              icon: Icons.admin_panel_settings_rounded,
            ),

            // Supervisor Code Card
            _buildRoleCodeCard(
              roleTitle: 'Supervisor Code',
              roleDesc: 'Command, live telemetry & alert control',
              code: _room!.supervisorCode ?? _room!.code,
              color: Colors.cyanAccent,
              icon: Icons.security_rounded,
            ),

            // Guard Code Card
            _buildRoleCodeCard(
              roleTitle: 'Guard Code',
              roleDesc: 'Tactical field responder & ground status',
              code: _room!.guardCode ?? _room!.code,
              color: ArgusTokens.success,
              icon: Icons.shield_rounded,
            ),
            const SizedBox(height: 18),
          ] else ...[
            // Guard notice (Codes concealed)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ArgusTokens.bgOverlay,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ArgusTokens.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 18, color: ArgusTokens.success),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Guard clearance active. Invite codes and administrative settings are restricted to Supervisors and Organizers.',
                      style: GoogleFonts.inter(fontSize: 11, color: ArgusTokens.textSecondary, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
          ],

          // Connected Responders Header
          Row(
            children: [
              const Icon(Icons.people_outline_rounded, size: 16, color: ArgusTokens.textSecondary),
              const SizedBox(width: 6),
              Text(
                'CONNECTED TEAM (${members.length})',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: ArgusTokens.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Member List
          for (final m in members) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: ArgusTokens.bgOverlay,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ArgusTokens.borderSubtle),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: ArgusTokens.bgRaised,
                    child: Text(
                      m.userName.isNotEmpty ? m.userName[0].toUpperCase() : '?',
                      style: GoogleFonts.sora(fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      m.userName,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: m.userRole.toLowerCase() == 'organizer'
                          ? Colors.amber.withValues(alpha: 0.15)
                          : m.userRole.toLowerCase() == 'supervisor'
                              ? Colors.cyan.withValues(alpha: 0.15)
                              : ArgusTokens.success.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      m.userRole.toUpperCase(),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: m.userRole.toLowerCase() == 'organizer'
                            ? Colors.amberAccent
                            : m.userRole.toLowerCase() == 'supervisor'
                                ? Colors.cyanAccent
                                : ArgusTokens.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (!isGuard) ...[
            const SizedBox(height: 24),
            const Divider(color: ArgusTokens.borderSubtle),
            const SizedBox(height: 12),

            // Danger Zone: Delete Room inside room (Organizers & Supervisors only)
            Text(
              'ROOM MANAGEMENT',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: ArgusTokens.textTertiary,
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _deleteRoom,
              icon: const Icon(Icons.delete_forever_rounded, size: 16, color: ArgusTokens.severityCritical),
              label: const Text('Delete This Room'),
              style: OutlinedButton.styleFrom(
                foregroundColor: ArgusTokens.severityCritical,
                side: BorderSide(color: ArgusTokens.severityCritical.withValues(alpha: 0.4)),
                minimumSize: const Size.fromHeight(40),
                textStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoleCodeCard({
    required String roleTitle,
    required String roleDesc,
    required String code,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ArgusTokens.bgOverlay,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                roleTitle,
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: color),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$roleTitle ($code) copied to clipboard!')),
                  );
                },
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Text(
                        code,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: ArgusTokens.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.copy_rounded, size: 11, color: color),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            roleDesc,
            style: GoogleFonts.inter(fontSize: 10, color: ArgusTokens.textTertiary),
          ),
        ],
      ),
    );
  }
}
