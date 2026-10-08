import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class WorkspaceEndpoint extends Endpoint {
  static const String defaultOwner = 'org_cctv_admin';

  Future<Workspace> ensure(Session session) async {
    var ws = await Workspace.db.findFirstRow(
      session,
      where: (t) => t.ownerUserId.equals(defaultOwner),
    );

    if (ws != null) return ws;

    final newWs = Workspace(
      ownerUserId: defaultOwner,
      name: 'City Central CCTV Operations',
      createdAt: DateTime.now(),
      settings: WorkspaceSettings(
        cloudVerification: false,
        blurEvidence: true,
        retentionDays: 7,
        timezone: 'UTC',
        telegramLinked: false,
        browserNotifications: true,
      ),
    );

    return await Workspace.db.insertRow(session, newWs);
  }

  Future<WorkspaceSettings> updateSettings(
    Session session,
    WorkspaceSettings settings,
  ) async {
    final ws = await ensure(session);
    final updated = ws.copyWith(settings: settings);
    await Workspace.db.updateRow(session, updated);
    return settings;
  }

  Future<void> deleteWorkspaceData(Session session) async {
    final ws = await ensure(session);
    final wsId = ws.id!;

    // Cascade delete incidents and events
    final incidents = await Incident.db.find(
      session,
      where: (t) => t.workspaceId.equals(wsId),
    );
    for (final inc in incidents) {
      if (inc.id != null) {
        await IncidentEvent.db.deleteWhere(
          session,
          where: (t) => t.incidentId.equals(inc.id!),
        );
      }
    }
    await Incident.db.deleteWhere(
      session,
      where: (t) => t.workspaceId.equals(wsId),
    );

    // Delete rules
    await RuleSpec.db.deleteWhere(
      session,
      where: (t) => t.workspaceId.equals(wsId),
    );

    // Delete cameras and zones
    final cameras = await Camera.db.find(
      session,
      where: (t) => t.workspaceId.equals(wsId),
    );
    for (final cam in cameras) {
      if (cam.id != null) {
        await Zone.db.deleteWhere(
          session,
          where: (t) => t.cameraId.equals(cam.id!),
        );
      }
    }
    await Camera.db.deleteWhere(
      session,
      where: (t) => t.workspaceId.equals(wsId),
    );

    // Record audit entry
    await AuditEntry.db.insertRow(
      session,
      AuditEntry(
        workspaceId: wsId,
        at: DateTime.now(),
        actor: 'Admin',
        action: 'WIPE_DATA',
        targetKind: 'Workspace',
        targetId: wsId,
        detail: 'User requested complete data purge',
      ),
    );
  }
}
