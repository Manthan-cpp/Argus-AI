import 'dart:math';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'workspace_endpoint.dart';

class ContactEndpoint extends Endpoint {
  Future<List<Contact>> list(Session session) async {
    final ws = await WorkspaceEndpoint().ensure(session);
    return await Contact.db.find(
      session,
      where: (t) => t.workspaceId.equals(ws.id!),
      orderBy: (t) => t.id,
    );
  }

  Future<Contact> save(Session session, Contact contact) async {
    final ws = await WorkspaceEndpoint().ensure(session);
    final target = contact.copyWith(workspaceId: ws.id!);

    if (target.id == null || target.id == 0) {
      final toInsert = target.copyWith(
        id: null,
        createdAt: DateTime.now(),
        isLinked: false,
      );
      return await Contact.db.insertRow(session, toInsert);
    } else {
      return await Contact.db.updateRow(session, target);
    }
  }

  Future<void> delete(Session session, int id) async {
    await Contact.db.deleteWhere(
      session,
      where: (t) => t.id.equals(id),
    );
  }

  Future<String> createTelegramLinkCode(Session session) async {
    final chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random();
    final code = List.generate(6, (i) => chars[rnd.nextInt(chars.length)]).join();
    return code;
  }
}
