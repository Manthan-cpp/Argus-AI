import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class HealthEndpoint extends Endpoint {
  Future<HealthInfo> ping(Session session) async {
    // Run quick DB probe
    final count = await Workspace.db.count(session);

    return HealthInfo(
      version: '4.0.4',
      engineVersion: '1.0.0-prod',
      geminiState: 'available',
      quotaNote: 'Operational (Embedded PostgreSQL + MediaPipe WASM)',
      queueDepth: count > 0 ? 0 : 1,
    );
  }
}
