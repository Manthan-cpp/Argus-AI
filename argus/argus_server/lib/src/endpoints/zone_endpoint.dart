import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class ZoneEndpoint extends Endpoint {
  Future<List<Zone>> list(Session session, int cameraId) async {
    return await Zone.db.find(
      session,
      where: (t) => t.cameraId.equals(cameraId),
      orderBy: (t) => t.id,
    );
  }

  Future<Zone> save(Session session, Zone zone) async {
    if (zone.id == null || zone.id == 0) {
      final toInsert = zone.copyWith(
        id: null,
        createdAt: DateTime.now(),
      );
      return await Zone.db.insertRow(session, toInsert);
    } else {
      return await Zone.db.updateRow(session, zone);
    }
  }

  Future<void> delete(Session session, int id) async {
    await Zone.db.deleteWhere(
      session,
      where: (t) => t.id.equals(id),
    );
  }
}
