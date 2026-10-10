import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class RoomMessageEndpoint extends Endpoint {
  static String channel(int roomId) => 'dispatch_room_$roomId';

  Stream<RoomMessage> watch(Session session, int roomId) async* {
    final stream = session.messages.createStream<RoomMessage>(channel(roomId));
    await for (final msg in stream) {
      yield msg;
    }
  }

  Future<RoomMessage> sendMessage(
    Session session,
    int roomId,
    String content, {
    String? senderName,
    String? senderRole,
    int? senderId,
  }) async {
    final cleanSenderName = (senderName != null && senderName.trim().isNotEmpty)
        ? senderName.trim()
        : 'Anonymous';

    String effectiveRole = (senderRole != null && senderRole.trim().isNotEmpty)
        ? senderRole.trim().toLowerCase()
        : 'guard';

    // Query room membership to ensure exact role tag
    final member = await RoomMember.db.findFirstRow(
      session,
      where: (t) =>
          t.roomId.equals(roomId) &
          (t.userName.equals(cleanSenderName) |
              (senderId != null ? t.userId.equals(senderId) : Constant.bool(false))),
    );

    if (member != null) {
      effectiveRole = member.userRole.toLowerCase();
    } else {
      final room = await DispatchRoom.db.findById(session, roomId);
      if (room != null) {
        final ws = await Workspace.db.findById(session, room.workspaceId);
        final wsMember = await WorkspaceMember.db.findFirstRow(
          session,
          where: (t) =>
              t.workspaceId.equals(room.workspaceId) &
              t.userName.equals(cleanSenderName),
        );
        if (room.createdByName.toLowerCase() == cleanSenderName.toLowerCase() ||
            (ws != null && ws.ownerUserId.toLowerCase() == cleanSenderName.toLowerCase())) {
          effectiveRole = 'organizer';
        } else if (wsMember != null) {
          effectiveRole = wsMember.userRole.toLowerCase();
        }
      }
    }

    final msg = RoomMessage(
      roomId: roomId,
      senderId: senderId,
      senderName: cleanSenderName,
      senderRole: effectiveRole,
      kind: 'chat',
      content: content.trim(),
      createdAt: DateTime.now(),
    );

    final saved = await RoomMessage.db.insertRow(session, msg);
    await session.messages.postMessage(channel(roomId), saved);
    return saved;
  }

  Future<List<RoomMessage>> listMessages(
    Session session,
    int roomId, {
    int? limit,
  }) async {
    final msgs = await RoomMessage.db.find(
      session,
      where: (t) => t.roomId.equals(roomId),
      orderBy: (t) => t.id,
      limit: limit ?? 100,
    );
    return msgs;
  }

  Future<RoomMessage> postAlert(
    Session session,
    int roomId, {
    required String content,
    required String cameraName,
    required String severity,
    int? incidentId,
  }) async {
    final msg = RoomMessage(
      roomId: roomId,
      senderId: null,
      senderName: 'Argus System',
      senderRole: 'system',
      kind: 'system_alert',
      content: content,
      cameraName: cameraName,
      severity: severity,
      incidentId: incidentId,
      createdAt: DateTime.now(),
    );

    final saved = await RoomMessage.db.insertRow(session, msg);
    await session.messages.postMessage(channel(roomId), saved);
    return saved;
  }
}
