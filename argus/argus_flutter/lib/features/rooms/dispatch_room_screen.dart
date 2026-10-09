import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:argus_client/argus_client.dart';
import '../../app/theme/tokens.dart';
import '../../core/widgets/pulsing_beacon.dart';
import '../../data/repository_provider.dart';
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
      final room = await repo.getRoomByCode(widget.code);
      if (mounted) {
        if (room == null) {
          setState(() {
            _error = 'Dispatch room with code "${widget.code}" not found.';
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
    final senderRole = user?.role ?? 'member';

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

  void _triggerSimulatedAlert() async {
    if (_room == null) return;
    final repo = ref.read(argusRepositoryProvider);
    final cameras = await repo.listCameras();
    final cameraName = cameras.isNotEmpty ? cameras.first.name : 'Platform 1';

    // Send a real-time system alert into this room
    final alertMessage =
        'Guards near the $cameraName area, please look into the matter immediately.';

    try {
      await repo.sendRoomMessage(
        _room!.id!,
        alertMessage,
        senderName: 'Argus System',
        senderRole: 'system',
      );
      // Also post with kind system_alert in mock
      _scrollToBottom();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Simulated alert dispatched to room ${_room!.code}!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to simulate alert: $e')),
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

    return Scaffold(
      backgroundColor: ArgusTokens.bgBase,
      body: Column(
        children: [
          // Tactical Header
          _buildTopBar(context, membersAsync.valueOrNull?.length ?? 1),

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
                      _buildInputBar(currentUser),
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
                    child: _buildSideIntelPanel(membersAsync.valueOrNull ?? []),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, int membersCount) {
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
            tooltip: 'Back to Rooms',
            onPressed: () => context.go('/app/rooms'),
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
                  // Code Chip with 1-click copy
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
          // Quick Simulate Alert action button
          OutlinedButton.icon(
            onPressed: _triggerSimulatedAlert,
            icon: const Icon(Icons.warning_amber_rounded, size: 14, color: ArgusTokens.severityMedium),
            label: const Text('Simulate Alert'),
            style: OutlinedButton.styleFrom(
              foregroundColor: ArgusTokens.severityMedium,
              side: BorderSide(color: ArgusTokens.severityMedium.withValues(alpha: 0.4)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
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
    final role = (msg.senderRole ?? 'member').toUpperCase();

    Color roleColor = ArgusTokens.textSecondary;
    if (role == 'ORGANIZER') roleColor = Colors.amberAccent;
    if (role == 'SUPERVISOR') roleColor = Colors.cyanAccent;
    if (role == 'MEMBER') roleColor = ArgusTokens.success;

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

  Widget _buildInputBar(UserProfile? currentUser) {
    final name = currentUser?.fullName ?? 'Operator';
    final role = (currentUser?.role ?? 'member').toUpperCase();

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

  Widget _buildSideIntelPanel(List<RoomMember> members) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(ArgusTokens.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room Code Card
          Container(
            padding: const EdgeInsets.all(ArgusTokens.space12),
            decoration: BoxDecoration(
              color: ArgusTokens.bgOverlay,
              borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
              border: Border.all(color: ArgusTokens.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.vpn_key_outlined, size: 16, color: ArgusTokens.accent),
                    const SizedBox(width: 6),
                    Text(
                      'ROOM CODE',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: ArgusTokens.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _room!.code,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: ArgusTokens.textPrimary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, size: 16, color: ArgusTokens.accent),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _room!.code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Room code ${_room!.code} copied!')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Share this code with guards or supervisors on other devices to join this operations channel.',
                  style: GoogleFonts.inter(fontSize: 11, color: ArgusTokens.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

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
        ],
      ),
    );
  }
}
