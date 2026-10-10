import 'dart:math';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'workspace_endpoint.dart';

class RoomEndpoint extends Endpoint {
  static final _random = Random();

  static String _generateCode(String prefix) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final suffix = List.generate(4, (_) => chars[_random.nextInt(chars.length)]).join();
    return '$prefix-$suffix';
  }

  Future<DispatchRoom> createRoom(
    Session session,
    String name, {
    String? description,
    List<int>? cameraIds,
    int? workspaceId,
    required String creatorName,
    required String creatorRole,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError('Room name cannot be empty');
    }

    final effectiveCreatorName = creatorName.trim().isNotEmpty
        ? creatorName.trim()
        : 'Organizer';

    final targetWsId = workspaceId ?? (await WorkspaceEndpoint().ensure(session)).id!;

    final ws = await Workspace.db.findById(session, targetWsId);
    final wsMember = await WorkspaceMember.db.findFirstRow(
      session,
      where: (t) => t.workspaceId.equals(targetWsId) & t.userName.equals(effectiveCreatorName),
    );
    final isOwner = ws?.ownerUserId.toLowerCase() == effectiveCreatorName.toLowerCase();
    final effectiveWsRole = wsMember?.userRole.toLowerCase() ??
        (isOwner ? 'organizer' : creatorRole.trim().toLowerCase());

    if (effectiveWsRole != 'organizer' && effectiveWsRole != 'supervisor') {
      throw ArgumentError('Guards cannot create rooms. Creator role must be organizer or supervisor.');
    }

    // Generate unique role codes
    String orgCode = _generateCode('ORG');
    String supCode = _generateCode('SUP');
    String grdCode = _generateCode('GRD');

    for (int i = 0; i < 10; i++) {
      final existing = await DispatchRoom.db.findFirstRow(
        session,
        where: (t) =>
            t.organizerCode.equals(orgCode) |
            t.supervisorCode.equals(supCode) |
            t.guardCode.equals(grdCode),
      );
      if (existing == null) break;
      orgCode = _generateCode('ORG');
      supCode = _generateCode('SUP');
      grdCode = _generateCode('GRD');
    }

    var user = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.workspaceId.equals(targetWsId) & t.fullName.equals(effectiveCreatorName),
    );

    user ??= await UserProfile.db.insertRow(
      session,
      UserProfile(
        workspaceId: targetWsId,
        fullName: effectiveCreatorName,
        role: effectiveWsRole,
        createdAt: DateTime.now(),
      ),
    );

    final newRoom = DispatchRoom(
      workspaceId: targetWsId,
      name: cleanName,
      code: orgCode,
      organizerCode: orgCode,
      supervisorCode: supCode,
      guardCode: grdCode,
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
        userRole: effectiveWsRole,
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
      content:
          'Dispatch Room "${savedRoom.name}" created by $effectiveCreatorName (${effectiveWsRole.toUpperCase()}).',
      createdAt: DateTime.now(),
    );
    await RoomMessage.db.insertRow(session, initialMsg);

    return savedRoom;
  }

  Future<DispatchRoom?> joinRoom(
    Session session,
    String code, {
    required String userName,
  }) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return null;

    final room = await DispatchRoom.db.findFirstRow(
      session,
      where: (t) =>
          t.isActive.equals(true) &
          (t.code.equals(cleanCode) |
              t.organizerCode.equals(cleanCode) |
              t.supervisorCode.equals(cleanCode) |
              t.guardCode.equals(cleanCode)),
    );

    if (room == null) {
      return null;
    }

    // Role is automatically assigned by the join code provided
    String assignedRole = 'guard';
    if (cleanCode == room.organizerCode || cleanCode.startsWith('ORG-')) {
      assignedRole = 'organizer';
    } else if (cleanCode == room.supervisorCode || cleanCode.startsWith('SUP-')) {
      assignedRole = 'supervisor';
    } else if (cleanCode == room.guardCode || cleanCode.startsWith('GRD-')) {
      assignedRole = 'guard';
    }

    final cleanUserName = userName.trim();

    var user = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.workspaceId.equals(room.workspaceId) & t.fullName.equals(cleanUserName),
    );

    user ??= await UserProfile.db.insertRow(
      session,
      UserProfile(
        workspaceId: room.workspaceId,
        fullName: cleanUserName,
        role: assignedRole,
        createdAt: DateTime.now(),
      ),
    );

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
        userRole: assignedRole,
        joinedAt: DateTime.now(),
      );
      await RoomMember.db.insertRow(session, newMember);

      // Post broadcast event to the room stream
      final joinMsg = RoomMessage(
        roomId: room.id!,
        senderId: user.id,
        senderName: user.fullName,
        senderRole: assignedRole,
        kind: 'action_log',
        content: '${user.fullName} joined the dispatch room as ${assignedRole.toUpperCase()}.',
        createdAt: DateTime.now(),
      );
      final savedMsg = await RoomMessage.db.insertRow(session, joinMsg);
      await session.messages.postMessage('dispatch_room_${room.id}', savedMsg);
    } else if (existingMember.userRole != assignedRole) {
      // Update role if joined with different code
      await RoomMember.db.updateRow(
        session,
        existingMember.copyWith(userRole: assignedRole),
      );
    }

    return room;
  }

  Future<bool> deleteRoom(
    Session session,
    int roomId, {
    required String userName,
  }) async {
    final room = await DispatchRoom.db.findById(session, roomId);
    if (room == null) return false;

    // Verify user is not a guard
    final cleanUserName = userName.trim();
    final member = await RoomMember.db.findFirstRow(
      session,
      where: (t) => t.roomId.equals(roomId) & t.userName.equals(cleanUserName),
    );
    final wsMember = await WorkspaceMember.db.findFirstRow(
      session,
      where: (t) => t.workspaceId.equals(room.workspaceId) & t.userName.equals(cleanUserName),
    );
    final ws = await Workspace.db.findById(session, room.workspaceId);
    final isOwner = (ws != null && ws.ownerUserId.toLowerCase() == cleanUserName.toLowerCase()) ||
        room.createdByName.toLowerCase() == cleanUserName.toLowerCase();
    final role = member?.userRole.toLowerCase() ??
        (isOwner ? 'organizer' : (wsMember?.userRole.toLowerCase() ?? 'guard'));

    if (role != 'organizer' && role != 'supervisor') {
      throw StateError('Permission denied: Guards cannot delete rooms.');
    }

    // Notify listeners
    final delMsg = RoomMessage(
      roomId: roomId,
      senderId: null,
      senderName: 'Argus System',
      senderRole: 'system',
      kind: 'action_log',
      content: 'Dispatch Room "${room.name}" was closed and deleted by $cleanUserName.',
      createdAt: DateTime.now(),
    );
    await session.messages.postMessage('dispatch_room_$roomId', delMsg);

    // Clean up room messages and members
    await RoomMessage.db.deleteWhere(session, where: (t) => t.roomId.equals(roomId));
    await RoomMember.db.deleteWhere(session, where: (t) => t.roomId.equals(roomId));
    await DispatchRoom.db.deleteRow(session, room);

    return true;
  }

  Future<DispatchRoom> updateRoom(
    Session session,
    int roomId, {
    required String userName,
    String? name,
    String? description,
    List<int>? cameraIds,
  }) async {
    final cleanUserName = userName.trim();
    if (cleanUserName.isEmpty) {
      throw ArgumentError('User name cannot be empty');
    }

    final room = await DispatchRoom.db.findById(session, roomId);
    if (room == null || !room.isActive) {
      throw StateError('Room not found or inactive');
    }

    // Verify user is organizer or supervisor
    final member = await RoomMember.db.findFirstRow(
      session,
      where: (t) => t.roomId.equals(roomId) & t.userName.equals(cleanUserName),
    );
    final wsMember = await WorkspaceMember.db.findFirstRow(
      session,
      where: (t) => t.workspaceId.equals(room.workspaceId) & t.userName.equals(cleanUserName),
    );
    final ws = await Workspace.db.findById(session, room.workspaceId);
    final isOwner = (ws != null && ws.ownerUserId.toLowerCase() == cleanUserName.toLowerCase()) ||
        room.createdByName.toLowerCase() == cleanUserName.toLowerCase();
    final role = member?.userRole.toLowerCase() ??
        (isOwner ? 'organizer' : (wsMember?.userRole.toLowerCase() ?? 'guard'));

    if (role != 'organizer' && role != 'supervisor') {
      throw StateError('Permission denied: Guards cannot edit room settings.');
    }

    final updated = room.copyWith(
      name: (name != null && name.trim().isNotEmpty) ? name.trim() : room.name,
      description: description != null ? description.trim() : room.description,
      cameraIds: cameraIds ?? room.cameraIds,
    );

    final saved = await DispatchRoom.db.updateRow(session, updated);

    // Announce update to room
    final sysMsg = RoomMessage(
      roomId: roomId,
      senderId: null,
      senderName: 'Argus System',
      senderRole: 'system',
      kind: 'action_log',
      content: 'Dispatch Room configuration updated by $cleanUserName (${role.toUpperCase()}).',
      createdAt: DateTime.now(),
    );
    final savedMsg = await RoomMessage.db.insertRow(session, sysMsg);
    await session.messages.postMessage('dispatch_room_$roomId', savedMsg);

    return saved;
  }

  Future<List<DispatchRoom>> listRooms(
    Session session, {
    int? workspaceId,
    String? userName,
  }) async {
    final cleanName = userName?.trim();
    if (cleanName == null || cleanName.isEmpty) {
      return <DispatchRoom>[];
    }

    final targetWsId = workspaceId ?? (await WorkspaceEndpoint().ensure(session)).id!;

    final ws = await Workspace.db.findById(session, targetWsId);
    final wsMember = await WorkspaceMember.db.findFirstRow(
      session,
      where: (t) => t.workspaceId.equals(targetWsId) & t.userName.equals(cleanName),
    );
    final isWsOwner = ws?.ownerUserId.toLowerCase() == cleanName.toLowerCase();
    final isPartOfFacility = wsMember != null || isWsOwner;

    final user = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.workspaceId.equals(targetWsId) & t.fullName.equals(cleanName),
    );
    final memberships = user != null
        ? await RoomMember.db.find(session, where: (t) => t.userId.equals(user.id!))
        : <RoomMember>[];
    final memberRoomIds = memberships.map((m) => m.roomId).toSet();
    final roomRoles = {for (final m in memberships) m.roomId: m.userRole.toLowerCase()};

    final allRooms = await DispatchRoom.db.find(
      session,
      where: (t) => t.workspaceId.equals(targetWsId) & t.isActive.equals(true),
      orderBy: (t) => t.id,
    );

    final userRooms = allRooms.where((r) {
      if (workspaceId != null) {
        return isPartOfFacility || memberRoomIds.contains(r.id) || r.createdById == user?.id;
      } else {
        return memberRoomIds.contains(r.id) || r.createdById == user?.id || r.createdByName.toLowerCase() == cleanName.toLowerCase();
      }
    }).map((r) {
      final isCreator = r.createdById == user?.id || r.createdByName.toLowerCase() == cleanName.toLowerCase();
      final facilityRole = wsMember?.userRole.toLowerCase() ?? (isWsOwner ? 'organizer' : 'guard');
      final effectiveRole = roomRoles[r.id] ?? (isCreator || isWsOwner ? 'organizer' : facilityRole);

      if (effectiveRole == 'guard') {
        return r.copyWith(
          organizerCode: null,
          supervisorCode: null,
          guardCode: null,
          code: r.id.toString(),
        );
      }
      if (effectiveRole == 'supervisor') {
        return r.copyWith(
          organizerCode: null,
        );
      }
      return r;
    }).toList();

    return userRooms.reversed.toList();
  }

  Future<DispatchRoom?> getRoom(Session session, int roomId, {String? userName}) async {
    final room = await DispatchRoom.db.findById(session, roomId);
    if (room == null || !room.isActive) return null;

    if (userName != null && userName.trim().isNotEmpty) {
      final cleanName = userName.trim();
      final member = await RoomMember.db.findFirstRow(
        session,
        where: (t) => t.roomId.equals(roomId) & t.userName.equals(cleanName),
      );
      final ws = await Workspace.db.findById(session, room.workspaceId);
      final wsMember = await WorkspaceMember.db.findFirstRow(
        session,
        where: (t) => t.workspaceId.equals(room.workspaceId) & t.userName.equals(cleanName),
      );
      final isCreator = room.createdByName.toLowerCase() == cleanName.toLowerCase();
      final isWsOwner = ws?.ownerUserId.toLowerCase() == cleanName.toLowerCase();
      final role = member?.userRole.toLowerCase() ??
          (isCreator || isWsOwner ? 'organizer' : (wsMember?.userRole.toLowerCase() ?? 'guard'));

      if (role == 'guard') {
        return room.copyWith(
          organizerCode: null,
          supervisorCode: null,
          guardCode: null,
          code: room.id.toString(),
        );
      }
      if (role == 'supervisor') {
        return room.copyWith(
          organizerCode: null,
        );
      }
    }
    return room;
  }

  Future<DispatchRoom?> getRoomByCode(Session session, String code) async {
    final cleanCode = code.trim().toUpperCase();
    final asId = int.tryParse(cleanCode);
    if (asId != null) {
      final byId = await DispatchRoom.db.findById(session, asId);
      if (byId != null && byId.isActive) return byId;
    }
    return await DispatchRoom.db.findFirstRow(
      session,
      where: (t) =>
          t.isActive.equals(true) &
          (t.code.equals(cleanCode) |
              t.organizerCode.equals(cleanCode) |
              t.supervisorCode.equals(cleanCode) |
              t.guardCode.equals(cleanCode)),
    );
  }

  Future<DispatchRoom?> getRoomForWorkspace(Session session, int workspaceId, {String? userName}) async {
    final room = await DispatchRoom.db.findFirstRow(
      session,
      where: (t) => t.workspaceId.equals(workspaceId) & t.isActive.equals(true),
    );
    if (room == null) return null;
    return getRoom(session, room.id!, userName: userName);
  }

  Future<List<RoomMember>> listMembers(Session session, int roomId) async {
    return await RoomMember.db.find(
      session,
      where: (t) => t.roomId.equals(roomId),
      orderBy: (t) => t.joinedAt,
    );
  }
}
