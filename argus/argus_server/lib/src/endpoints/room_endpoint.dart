import 'dart:math';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'workspace_endpoint.dart';

class RoomEndpoint extends Endpoint {
  static final _random = Random();

  static String _generateRoomCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final code = List.generate(4, (_) => chars[_random.nextInt(chars.length)]).join();
    return 'ARG-$code';
  }

  Future<DispatchRoom> createRoom(
    Session session,
    String name, {
    String? description,
    List<int>? cameraIds,
    String? creatorName,
    String? creatorRole,
  }) async {
    final ws = await WorkspaceEndpoint().ensure(session);

    // Generate unique room code
    String code = _generateRoomCode();
    for (int i = 0; i < 10; i++) {
      final existing = await DispatchRoom.db.findFirstRow(
        session,
        where: (t) => t.code.equals(code),
      );
      if (existing == null) break;
      code = _generateRoomCode();
    }

    final effectiveCreatorName = (creatorName != null && creatorName.trim().isNotEmpty)
        ? creatorName.trim()
        : 'Organizer';
    final effectiveCreatorRole = (creatorRole != null && creatorRole.trim().isNotEmpty)
        ? creatorRole.trim().toLowerCase()
        : 'organizer';

    // Ensure creator user exists in db
    final userEmail = '${effectiveCreatorName.toLowerCase().replaceAll(' ', '.')}@argus.ai';
    var user = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.workspaceId.equals(ws.id!) & t.email.equals(userEmail),
    );
    user ??= await UserProfile.db.insertRow(
      session,
      UserProfile(
        workspaceId: ws.id!,
        fullName: effectiveCreatorName,
        email: userEmail,
        role: effectiveCreatorRole,
        createdAt: DateTime.now(),
      ),
    );

    final newRoom = DispatchRoom(
      workspaceId: ws.id!,
      name: name.trim(),
      code: code,
      description: description?.trim(),
      createdById: user.id ?? 1,
      createdByName: effectiveCreatorName,
      createdAt: DateTime.now(),
      cameraIds: cameraIds ?? <int>[],
      isActive: true,
    );

    final savedRoom = await DispatchRoom.db.insertRow(session, newRoom);

    // Add creator as member of the room
    await RoomMember.db.insertRow(
      session,
      RoomMember(
        roomId: savedRoom.id!,
        userId: user.id ?? 1,
        userName: effectiveCreatorName,
        userRole: effectiveCreatorRole,
        joinedAt: DateTime.now(),
      ),
    );

    // Post an initial system announcement message
    final initialMsg = RoomMessage(
      roomId: savedRoom.id!,
      senderId: null,
      senderName: 'Argus System',
      senderRole: 'system',
      kind: 'action_log',
      content: 'Dispatch Room "${savedRoom.name}" created by $effectiveCreatorName ($effectiveCreatorRole). Code: $code',
      createdAt: DateTime.now(),
    );
    await RoomMessage.db.insertRow(session, initialMsg);

    return savedRoom;
  }

  Future<DispatchRoom?> joinRoom(
    Session session,
    String code, {
    required String userName,
    required String userRole,
    String? userEmail,
  }) async {
    final cleanCode = code.trim().toUpperCase();
    final room = await DispatchRoom.db.findFirstRow(
      session,
      where: (t) => t.code.equals(cleanCode) & t.isActive.equals(true),
    );

    if (room == null) {
      return null;
    }

    final ws = await WorkspaceEndpoint().ensure(session);
    final email = (userEmail != null && userEmail.isNotEmpty)
        ? userEmail
        : '${userName.toLowerCase().replaceAll(' ', '.')}@argus.ai';

    var user = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.workspaceId.equals(ws.id!) & t.email.equals(email),
    );

    if (user == null) {
      user = await UserProfile.db.insertRow(
        session,
        UserProfile(
          workspaceId: ws.id!,
          fullName: userName.trim(),
          email: email,
          role: userRole.trim().toLowerCase(),
          createdAt: DateTime.now(),
        ),
      );
    } else {
      user = await UserProfile.db.updateRow(
        session,
        user.copyWith(fullName: userName.trim(), role: userRole.trim().toLowerCase()),
      );
    }

    // Check if user is already a member
    final existingMember = await RoomMember.db.findFirstRow(
      session,
      where: (t) => t.roomId.equals(room.id!) & t.userId.equals(user!.id!),
    );

    if (existingMember == null) {
      final newMember = RoomMember(
        roomId: room.id!,
        userId: user.id!,
        userName: user.fullName,
        userRole: user.role,
        joinedAt: DateTime.now(),
      );
      await RoomMember.db.insertRow(session, newMember);

      // Post broadcast event to the room stream
      final joinMsg = RoomMessage(
        roomId: room.id!,
        senderId: user.id,
        senderName: user.fullName,
        senderRole: user.role,
        kind: 'action_log',
        content: '${user.fullName} joined the dispatch room as ${user.role.toUpperCase()}.',
        createdAt: DateTime.now(),
      );
      final savedMsg = await RoomMessage.db.insertRow(session, joinMsg);
      await session.messages.postMessage('dispatch_room_${room.id}', savedMsg);
    }

    return room;
  }

  Future<List<DispatchRoom>> listRooms(Session session) async {
    final ws = await WorkspaceEndpoint().ensure(session);
    final rooms = await DispatchRoom.db.find(
      session,
      where: (t) => t.workspaceId.equals(ws.id!) & t.isActive.equals(true),
      orderBy: (t) => t.id,
    );
    return rooms.reversed.toList();
  }

  Future<DispatchRoom?> getRoomByCode(Session session, String code) async {
    final cleanCode = code.trim().toUpperCase();
    return await DispatchRoom.db.findFirstRow(
      session,
      where: (t) => t.code.equals(cleanCode),
    );
  }

  Future<List<RoomMember>> listMembers(Session session, int roomId) async {
    return await RoomMember.db.find(
      session,
      where: (t) => t.roomId.equals(roomId),
      orderBy: (t) => t.joinedAt,
    );
  }
}
