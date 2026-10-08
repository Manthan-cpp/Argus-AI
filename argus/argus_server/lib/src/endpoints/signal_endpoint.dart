import 'dart:convert';
import 'package:serverpod/serverpod.dart';
import '../generated/future_calls.dart';
import '../generated/protocol.dart';
import 'incident_endpoint.dart';
import 'workspace_endpoint.dart';

class SignalEndpoint extends Endpoint {
  Future<SignalAck> send(Session session, SignalBatch batch) async {
    final ws = await WorkspaceEndpoint().ensure(session);
    final needEvidence = <int>[];

    // 1. Update camera status (throttled to at most once per 10s to prevent DB lock contention)
    final camera = await Camera.db.findById(session, batch.cameraId);
    if (camera != null) {
      final last = camera.lastSignalAt;
      if (last == null || DateTime.now().difference(last).inSeconds >= 10) {
        await Camera.db.updateRow(
          session,
          camera.copyWith(
            lastSignalAt: DateTime.now(),
            status: 'online',
          ),
        );
      }
    }

    // 2. Load active rules for this workspace and camera
    final rules = await RuleSpec.db.find(
      session,
      where: (t) => t.workspaceId.equals(ws.id!) & t.enabled.equals(true),
    );

    // Filter rules applying to this camera
    final matchingRules = rules.where((r) =>
      r.cameraIds.isEmpty || r.cameraIds.contains(batch.cameraId)
    ).toList();

    if (matchingRules.isEmpty || batch.signals.isEmpty) {
      return SignalAck(
        accepted: true,
        needEvidenceFor: [],
        serverTimeMs: DateTime.now().millisecondsSinceEpoch,
      );
    }

    final latestSignal = batch.signals.last;
    final persons = latestSignal.persons;

    // 3. Evaluate each rule
    for (final rule in matchingRules) {
      bool conditionMet = false;
      PersonSignal? triggerPerson;
      String triggerDetail = '';

      switch (rule.trigger.signal) {
        case 'person_in_zone':
          final targetZoneId = rule.trigger.zoneId;
          for (final p in persons) {
            final matchesZone = (targetZoneId == null || targetZoneId == 0)
                ? p.zoneIds.isNotEmpty
                : (p.zoneIds.contains(targetZoneId) || p.zoneIds.isNotEmpty);
            if (matchesZone) {
              conditionMet = true;
              triggerPerson = p;
              final zoneLabel = (targetZoneId != null && targetZoneId > 0)
                  ? 'Zone #$targetZoneId'
                  : 'Restricted Zone';
              triggerDetail = 'Person (ID ${p.trackId}) entered restricted $zoneLabel';
              break;
            }
          }
          break;

        case 'fall_suspected':
          final requiredFallMs = rule.trigger.minDurationSec * 1000;
          for (final p in persons) {
            if (p.fallScore >= 0.6) {
              if (requiredFallMs > 0) {
                if (p.motionlessMs >= requiredFallMs) {
                  conditionMet = true;
                  triggerPerson = p;
                  triggerDetail = 'Subject fell and remained down for ${(p.motionlessMs / 1000).toStringAsFixed(0)}s (score: ${p.fallScore.toStringAsFixed(2)})';
                  break;
                }
              } else {
                conditionMet = true;
                triggerPerson = p;
                triggerDetail = 'Sudden fall detected (score: ${p.fallScore.toStringAsFixed(2)}, torso: ${p.torsoAngleDeg?.toStringAsFixed(0)}°)';
                break;
              }
            }
          }
          break;

        case 'motionless':
          final requiredMs = rule.trigger.minDurationSec * 1000;
          for (final p in persons) {
            if (p.motionlessMs >= requiredMs) {
              conditionMet = true;
              triggerPerson = p;
              triggerDetail = 'Incapacitated/Motionless subject detected for ${(p.motionlessMs / 1000).toStringAsFixed(0)}s';
              break;
            }
          }
          break;

        case 'person_count':
          final minCount = rule.trigger.minCount ?? 1;
          if (persons.length >= minCount) {
            conditionMet = true;
            triggerDetail = 'Crowd surge: ${persons.length} persons detected (threshold: $minCount)';
          }
          break;
      }

      if (conditionMet) {
        // Deduplicate: check if an incident for this rule & camera is actively open or in cooldown
        final existing = await Incident.db.findFirstRow(
          session,
          where: (t) =>
              t.workspaceId.equals(ws.id!) &
              t.ruleId.equals(rule.id!) &
              t.cameraId.equals(batch.cameraId) &
              (t.status.equals('open') | t.status.equals('acknowledged')),
          orderBy: (t) => t.openedAt.desc(),
        );

        bool isSuppressed = false;
        if (existing != null) {
          if (existing.status == 'open') {
            isSuppressed = true;
          } else if (existing.status == 'acknowledged') {
            final cooldownSeconds = rule.cooldownSec > 0 ? rule.cooldownSec : 60;
            final lastActionTime = existing.ackedAt ?? existing.openedAt;
            final elapsed = DateTime.now().difference(lastActionTime).inSeconds;
            if (elapsed < cooldownSeconds) {
              isSuppressed = true;
            }
          }
        }

        if (!isSuppressed) {
          // Open new incident
          final newIncident = Incident(
            workspaceId: ws.id!,
            cameraId: batch.cameraId,
            ruleId: rule.id!,
            ruleSnapshotJson: json.encode(rule.toJson()),
            severity: rule.severity,
            status: 'open',
            openedAt: DateTime.now(),
            verification: VerificationInfo(
              status: 'not_requested',
              reason: 'Rule conditions satisfied by vision telemetry',
            ),
            summary: '${rule.name}: $triggerDetail',
            signalContextJson: json.encode({
              'trigger': triggerDetail,
              'personCount': persons.length,
              'trackId': triggerPerson?.trackId,
              'fallScore': triggerPerson?.fallScore,
              'motionlessMs': triggerPerson?.motionlessMs,
            }),
          );

          final savedIncident = await Incident.db.insertRow(session, newIncident);

          // Append opened event
          final openEvent = IncidentEvent(
            incidentId: savedIncident.id!,
            at: DateTime.now(),
            kind: 'opened',
            detail: triggerDetail,
          );
          await IncidentEvent.db.insertRow(session, openEvent);

          // Broadcast to live stream
          final update = IncidentUpdate(
            incident: savedIncident,
            event: openEvent,
          );
          await session.messages.postMessage(
            IncidentEndpoint.incidentChannel,
            update,
          );

          needEvidence.add(savedIncident.id!);

          // Schedule future call for multi-stage escalation ladder
          final escalationDelaySec = rule.escalation.isNotEmpty
              ? rule.escalation.first.afterSec
              : 30;
          try {
            await FutureCalls().callWithDelay(
              Duration(seconds: escalationDelaySec),
              identifier: 'escalation_${savedIncident.id}',
            ).incidentEscalationCall.invoke(
              EscalationPayload(incidentId: savedIncident.id!),
            );
          } catch (e) {
            session.log('FutureCall schedule note: $e');
          }

          // Audit log
          await AuditEntry.db.insertRow(
            session,
            AuditEntry(
              workspaceId: ws.id!,
              at: DateTime.now(),
              actor: 'ArgusEngine',
              action: 'INCIDENT_FIRED',
              targetKind: 'Incident',
              targetId: savedIncident.id!,
              detail: 'Fired rule "${rule.name}" on Camera #${batch.cameraId}',
            ),
          );
        }
      }
    }

    return SignalAck(
      accepted: true,
      needEvidenceFor: needEvidence,
      serverTimeMs: DateTime.now().millisecondsSinceEpoch,
    );
  }
}
