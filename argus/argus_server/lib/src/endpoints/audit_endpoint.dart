import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'workspace_endpoint.dart';

class AuditEndpoint extends Endpoint {
  Future<List<AuditEntry>> list(Session session, {int limit = 100}) async {
    final ws = await WorkspaceEndpoint().ensure(session);
    final entries = await AuditEntry.db.find(
      session,
      where: (t) => t.workspaceId.equals(ws.id!),
      orderBy: (t) => t.id,
      limit: limit,
    );
    return entries.reversed.toList();
  }
}
