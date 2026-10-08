import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/gemini_service.dart';
import 'incident_endpoint.dart';

class EvidenceEndpoint extends Endpoint {
  Future<void> upload(Session session, EvidenceUpload upload) async {
    final incident = await Incident.db.findById(session, upload.incidentId);
    if (incident == null) return;

    final fileKey = 'ev_${upload.incidentId}_${DateTime.now().millisecondsSinceEpoch}';

    // Check if rule requires assistive verification
    final rule = await RuleSpec.db.findById(session, incident.ruleId);
    var verification = incident.verification;

    if (rule?.verify.enabled == true) {
      final crop = upload.verificationCropJpeg ?? upload.snapshotJpegBase64;
      verification = await GeminiService.verifySnapshot(
        session,
        base64Jpeg: crop,
        ruleContext: incident.summary,
      );
    }

    final updated = incident.copyWith(
      evidenceFileKey: fileKey,
      verification: verification,
    );
    await Incident.db.updateRow(session, updated);

    final event = IncidentEvent(
      incidentId: upload.incidentId,
      at: DateTime.now(),
      kind: verification.status == 'verified' ? 'verified' : 'evidence_added',
      detail: 'Privacy-blurred evidence attached. Verification: ${verification.status} (${verification.reason ?? "local telemetry"})',
    );
    await IncidentEvent.db.insertRow(session, event);

    final update = IncidentUpdate(incident: updated, event: event);
    await session.messages.postMessage(
      IncidentEndpoint.incidentChannel,
      update,
    );
  }
}
