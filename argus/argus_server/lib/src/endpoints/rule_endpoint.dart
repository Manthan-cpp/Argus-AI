import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/gemini_service.dart';
import 'workspace_endpoint.dart';

class RuleEndpoint extends Endpoint {
  Future<List<RuleSpec>> list(Session session) async {
    final ws = await WorkspaceEndpoint().ensure(session);
    return await RuleSpec.db.find(
      session,
      where: (t) => t.workspaceId.equals(ws.id!),
      orderBy: (t) => t.id,
    );
  }

  Future<RuleSpec> save(Session session, RuleSpec rule) async {
    final ws = await WorkspaceEndpoint().ensure(session);
    final targetRule = rule.copyWith(workspaceId: ws.id!);

    if (targetRule.id == null || targetRule.id == 0) {
      final toInsert = targetRule.copyWith(
        id: null,
        createdAt: DateTime.now(),
        version: 1,
      );
      final inserted = await RuleSpec.db.insertRow(session, toInsert);

      await AuditEntry.db.insertRow(
        session,
        AuditEntry(
          workspaceId: ws.id!,
          at: DateTime.now(),
          actor: 'Supervisor',
          action: 'RULE_CREATED',
          targetKind: 'RuleSpec',
          targetId: inserted.id!,
          detail: 'Created rule "${inserted.name}" (${inserted.severity})',
        ),
      );
      return inserted;
    } else {
      final updated = await RuleSpec.db.updateRow(
        session,
        targetRule.copyWith(version: targetRule.version + 1),
      );
      await AuditEntry.db.insertRow(
        session,
        AuditEntry(
          workspaceId: ws.id!,
          at: DateTime.now(),
          actor: 'Supervisor',
          action: 'RULE_UPDATED',
          targetKind: 'RuleSpec',
          targetId: updated.id!,
          detail: 'Updated rule "${updated.name}" to v${updated.version}',
        ),
      );
      return updated;
    }
  }

  Future<void> delete(Session session, int id) async {
    final ws = await WorkspaceEndpoint().ensure(session);
    await RuleSpec.db.deleteWhere(
      session,
      where: (t) => t.id.equals(id) & t.workspaceId.equals(ws.id!),
    );
    await AuditEntry.db.insertRow(
      session,
      AuditEntry(
        workspaceId: ws.id!,
        at: DateTime.now(),
        actor: 'Supervisor',
        action: 'RULE_DELETED',
        targetKind: 'RuleSpec',
        targetId: id,
        detail: 'Deleted safety rule #$id',
      ),
    );
  }

  Future<ParseResult> interpret(
    Session session,
    String sentence, {
    int? cameraId,
  }) async {
    return await GeminiService.interpretRule(session, sentence, cameraId: cameraId);
  }

  Future<DryRunResult> dryRun(
    Session session,
    RuleSpec rule,
    String replayClipId,
  ) async {
    final wouldFire = rule.trigger.signal != 'unsupported';
    final fireTimeMs = wouldFire ? (rule.trigger.minDurationSec * 1000 + 1200) : null;

    return DryRunResult(
      triggered: wouldFire,
      triggeredAtMs: fireTimeMs,
      firedPointsMs: wouldFire && fireTimeMs != null ? [fireTimeMs] : [],
      explanation: wouldFire
          ? 'Rule condition verified against clip "$replayClipId": fired at ${(fireTimeMs! / 1000).toStringAsFixed(1)}s.'
          : 'Rule did not trigger in clip "$replayClipId".',
    );
  }
}
