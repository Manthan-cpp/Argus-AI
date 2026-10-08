import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class RetentionCleanupCall extends FutureCall<RetentionPayload> {
  Future<void> invoke(Session session, RetentionPayload? payload) async {
    final now = DateTime.now();
    final cutoff = now.subtract(const Duration(days: 30));

    // Delete resolved or false-positive incidents older than 30 days
    final deleted = await Incident.db.deleteWhere(
      session,
      where: (t) =>
          (t.status.equals('resolved') | t.status.equals('false_positive')) &
          (t.openedAt < cutoff),
    );

    if (deleted.isNotEmpty) {
      session.log('Retention cleanup pruned ${deleted.length} archived incidents.');
    }
  }
}
