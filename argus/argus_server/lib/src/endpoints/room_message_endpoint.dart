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
    final msg = RoomMessage(
      roomId: roomId,
      senderId: senderId,
      senderName: (senderName != null && senderName.isNotEmpty) ? senderName : 'Anonymous',
      senderRole: senderRole ?? 'member',
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
