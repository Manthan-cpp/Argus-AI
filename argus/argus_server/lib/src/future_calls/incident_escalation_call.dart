import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../endpoints/incident_endpoint.dart';
import '../services/telegram_service.dart';

class IncidentEscalationCall extends FutureCall<EscalationPayload> {
  Future<void> invoke(Session session, EscalationPayload? payload) async {
    final incidentId = payload?.incidentId;
    if (incidentId == null) return;

    final incident = await Incident.db.findById(session, incidentId);
    if (incident == null) return;

    // Halt escalation if incident is already acknowledged or resolved
    if (incident.status == 'acknowledged' ||
        incident.status == 'resolved' ||
        incident.status == 'false_positive') {
      return;
    }

    // Unacknowledged: Escalate ladder!
    final rule = await RuleSpec.db.findById(session, incident.ruleId);
    final ladder = rule?.escalation ?? [];
    final escalationMsg = ladder.isNotEmpty
        ? ladder.first.message
        : 'Incident unacknowledged after timeout.';

    // Log escalation audit entry
    await AuditEntry.db.insertRow(
      session,
      AuditEntry(
        workspaceId: incident.workspaceId,
        at: DateTime.now(),
        actor: 'ARGUS Escalation Engine',
        action: 'ESCALATION_TIMEOUT',
        targetKind: 'Incident',
        targetId: incidentId,
        detail: 'Escalation triggered for unacknowledged incident #${incident.id} (${incident.severity}). $escalationMsg',
      ),
    );

    // Notify contacts via Telegram
    final contacts = await Contact.db.find(
      session,
      where: (t) => t.workspaceId.equals(incident.workspaceId),
    );

    for (final contact in contacts) {
      if (contact.telegramChatId != null && contact.telegramChatId!.isNotEmpty) {
        await TelegramService.sendMessage(
          session,
          chatId: contact.telegramChatId!,
          message: '🚨 *ARGUS SAFETY ESCALATION*\n\n'
              '*Incident #*${incident.id}\n'
              '*Severity:* ${incident.severity.toUpperCase()}\n'
              '*Summary:* ${incident.summary}\n'
              '*Status:* UNACKNOWLEDGED after timeout\n\n'
              'Immediate supervisor intervention required.',
        );
      }
    }

    // Append escalation event to incident record
    final escalationEvent = IncidentEvent(
      incidentId: incident.id!,
      at: DateTime.now(),
      kind: 'escalated',
      detail: 'Escalated due to unacknowledged timeout: $escalationMsg',
    );
    await IncidentEvent.db.insertRow(session, escalationEvent);

    // Broadcast escalation event to WebSocket
    await session.messages.postMessage(
      IncidentEndpoint.incidentChannel,
      IncidentUpdate(
        incident: incident,
        event: escalationEvent,
      ),
    );
  }
}
