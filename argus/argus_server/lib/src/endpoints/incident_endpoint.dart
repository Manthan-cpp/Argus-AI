import 'package:serverpod/serverpod.dart';
import '../generated/future_calls.dart';
import '../generated/protocol.dart';
import 'workspace_endpoint.dart';

class IncidentEndpoint extends Endpoint {
  static const String incidentChannel = 'workspace_incidents';

  Stream<IncidentUpdate> watch(
    Session session, {
    int? sinceIncidentId,
  }) async* {
    final stream = session.messages.createStream<IncidentUpdate>(incidentChannel);
    await for (final update in stream) {
      yield update;
    }
  }

  Future<List<Incident>> list(
    Session session, {
    String? status,
    String? severity,
    int? cameraId,
  }) async {
    final ws = await WorkspaceEndpoint().ensure(session);
    final results = await Incident.db.find(
      session,
      where: (t) {
        var expr = t.workspaceId.equals(ws.id!);
        if (status != null && status.isNotEmpty) {
          expr = expr & t.status.equals(status);
        }
        if (severity != null && severity.isNotEmpty) {
          expr = expr & t.severity.equals(severity);
        }
        if (cameraId != null && cameraId > 0) {
          expr = expr & t.cameraId.equals(cameraId);
        }
        return expr;
      },
      orderBy: (t) => t.id,
      limit: 100,
    );
    return results.reversed.toList();
  }

  Future<IncidentDetail> get(Session session, int id) async {
    final inc = await Incident.db.findById(session, id);
    if (inc == null) {
      throw NotFoundException('Incident #$id not found');
    }

    final events = await IncidentEvent.db.find(
      session,
      where: (t) => t.incidentId.equals(id),
      orderBy: (t) => t.id,
    );

    return IncidentDetail(
      incident: inc,
      events: events,
      evidenceUrl: inc.evidenceFileKey != null
          ? '/evidence/${inc.evidenceFileKey}'
          : null,
    );
  }

  Future<Incident> acknowledge(
    Session session,
    int id, {
    String? note,
  }) async {
    final inc = await Incident.db.findById(session, id);
    if (inc == null) throw NotFoundException('Incident #$id not found');

    final updated = inc.copyWith(
      status: 'acknowledged',
      ackedAt: DateTime.now(),
    );
    final saved = await Incident.db.updateRow(session, updated);

    // Cancel pending escalation timer
    try {
      await FutureCalls().cancel('escalation_$id');
    } catch (_) {}

    final event = IncidentEvent(
      incidentId: id,
      at: DateTime.now(),
      kind: 'acknowledged',
      detail: note ?? 'Acknowledged by Control Room Operator',
    );
    await IncidentEvent.db.insertRow(session, event);

    final update = IncidentUpdate(incident: saved, event: event);
    await session.messages.postMessage(incidentChannel, update);

    await AuditEntry.db.insertRow(
      session,
      AuditEntry(
        workspaceId: inc.workspaceId,
        at: DateTime.now(),
        actor: 'Operator',
        action: 'INCIDENT_ACK',
        targetKind: 'Incident',
        targetId: id,
        detail: 'Acknowledged incident: ${inc.summary}',
      ),
    );

    return saved;
  }

  Future<Incident> resolve(
    Session session,
    int id, {
    String? note,
  }) async {
    final inc = await Incident.db.findById(session, id);
    if (inc == null) throw NotFoundException('Incident #$id not found');

    final updated = inc.copyWith(
      status: 'resolved',
      resolvedAt: DateTime.now(),
    );
    final saved = await Incident.db.updateRow(session, updated);

    // Cancel pending escalation timer
    try {
      await FutureCalls().cancel('escalation_$id');
    } catch (_) {}

    final event = IncidentEvent(
      incidentId: id,
      at: DateTime.now(),
      kind: 'resolved',
      detail: note ?? 'Marked as resolved by Control Room Operator',
    );
    await IncidentEvent.db.insertRow(session, event);

    final update = IncidentUpdate(incident: saved, event: event);
    await session.messages.postMessage(incidentChannel, update);

    await AuditEntry.db.insertRow(
      session,
      AuditEntry(
        workspaceId: inc.workspaceId,
        at: DateTime.now(),
        actor: 'Operator',
        action: 'INCIDENT_RESOLVE',
        targetKind: 'Incident',
        targetId: id,
        detail: 'Resolved incident: ${inc.summary}',
      ),
    );

    return saved;
  }

  Future<Incident> markFalsePositive(
    Session session,
    int id, {
    String? note,
  }) async {
    final inc = await Incident.db.findById(session, id);
    if (inc == null) throw NotFoundException('Incident #$id not found');

    final updated = inc.copyWith(
      status: 'false_positive',
      resolvedAt: DateTime.now(),
    );
    final saved = await Incident.db.updateRow(session, updated);

    // Cancel pending escalation timer
    try {
      await FutureCalls().cancel('escalation_$id');
    } catch (_) {}

    final event = IncidentEvent(
      incidentId: id,
      at: DateTime.now(),
      kind: 'false_positive',
      detail: note ?? 'Classified as false alarm. Forwarded to Detector Lab for model calibration.',
    );
    await IncidentEvent.db.insertRow(session, event);

    final update = IncidentUpdate(incident: saved, event: event);
    await session.messages.postMessage(incidentChannel, update);

    return saved;
  }

  Future<bool> delete(Session session, int id) async {
    final inc = await Incident.db.findById(session, id);
    if (inc == null) return false;

    // 1. Delete associated IncidentEvents first
    await IncidentEvent.db.deleteWhere(session, where: (t) => t.incidentId.equals(id));

    // 2. Cancel pending escalation timer if any
    try {
      await FutureCalls().cancel('escalation_$id');
    } catch (_) {}

    // 3. Delete the incident
    await Incident.db.deleteRow(session, inc);

    // 4. Audit entry
    await AuditEntry.db.insertRow(
      session,
      AuditEntry(
        workspaceId: inc.workspaceId,
        at: DateTime.now(),
        actor: 'Operator',
        action: 'INCIDENT_DELETE',
        targetKind: 'Incident',
        targetId: id,
        detail: 'Deleted incident #${inc.id}: ${inc.summary}',
      ),
    );

    return true;
  }

  Future<bool> deleteAll(Session session) async {
    final ws = await WorkspaceEndpoint().ensure(session);
    final incidents = await Incident.db.find(
      session,
      where: (t) => t.workspaceId.equals(ws.id!),
    );

    for (final inc in incidents) {
      if (inc.id != null) {
        await IncidentEvent.db.deleteWhere(session, where: (t) => t.incidentId.equals(inc.id!));
        try {
          await FutureCalls().cancel('escalation_${inc.id}');
        } catch (_) {}
      }
    }

    await Incident.db.deleteWhere(session, where: (t) => t.workspaceId.equals(ws.id!));

    await AuditEntry.db.insertRow(
      session,
      AuditEntry(
        workspaceId: ws.id!,
        at: DateTime.now(),
        actor: 'Operator',
        action: 'INCIDENT_DELETE_ALL',
        targetKind: 'Incident',
        targetId: 0,
        detail: 'Deleted all incidents (${incidents.length} removed)',
      ),
    );

    return true;
  }
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
  @override
  String toString() => message;
}
