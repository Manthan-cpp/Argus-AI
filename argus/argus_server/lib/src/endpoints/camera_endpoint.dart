import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'workspace_endpoint.dart';

class CameraEndpoint extends Endpoint {
  Future<List<Camera>> list(Session session, {int? workspaceId}) async {
    if (workspaceId != null) {
      return await Camera.db.find(
        session,
        where: (t) => t.workspaceId.equals(workspaceId),
        orderBy: (t) => t.id,
      );
    }
    final activeWorkspaces = await Workspace.db.find(
      session,
      where: (t) => t.isActive.equals(true),
      orderBy: (t) => t.id,
    );
    final targetWsId = activeWorkspaces.isNotEmpty ? activeWorkspaces.last.id! : (await WorkspaceEndpoint().ensure(session)).id!;
    return await Camera.db.find(
      session,
      where: (t) => t.workspaceId.equals(targetWsId),
      orderBy: (t) => t.id,
    );
  }

  Future<Camera> save(Session session, Camera camera, {int? workspaceId}) async {
    final targetWsId = workspaceId ?? (camera.workspaceId != 0 ? camera.workspaceId : (await WorkspaceEndpoint().ensure(session)).id!);
    final targetCam = camera.copyWith(workspaceId: targetWsId);

    if (targetCam.id == null || targetCam.id == 0) {
      final toInsert = targetCam.copyWith(
        id: null,
        createdAt: DateTime.now(),
      );
      final inserted = await Camera.db.insertRow(session, toInsert);

      await AuditEntry.db.insertRow(
        session,
        AuditEntry(
          workspaceId: targetWsId,
          at: DateTime.now(),
          actor: 'Operator',
          action: 'CAMERA_CREATED',
          targetKind: 'Camera',
          targetId: inserted.id!,
          detail: 'Registered camera "${inserted.name}" (${inserted.sourceKind})',
        ),
      );
      return inserted;
    } else {
      final updated = await Camera.db.updateRow(session, targetCam);
      await AuditEntry.db.insertRow(
        session,
        AuditEntry(
          workspaceId: targetWsId,
          at: DateTime.now(),
          actor: 'Operator',
          action: 'CAMERA_UPDATED',
          targetKind: 'Camera',
          targetId: updated.id!,
          detail: 'Updated configuration for camera "${updated.name}"',
        ),
      );
      return updated;
    }
  }

  Future<void> delete(Session session, int id) async {
    final cam = await Camera.db.findById(session, id);
    final wsId = cam?.workspaceId ?? (await WorkspaceEndpoint().ensure(session)).id!;

    // Delete attached zones
    await Zone.db.deleteWhere(
      session,
      where: (t) => t.cameraId.equals(id),
    );

    // Delete camera
    await Camera.db.deleteWhere(
      session,
      where: (t) => t.id.equals(id),
    );

    await AuditEntry.db.insertRow(
      session,
      AuditEntry(
        workspaceId: wsId,
        at: DateTime.now(),
        actor: 'Operator',
        action: 'CAMERA_DELETED',
        targetKind: 'Camera',
        targetId: id,
        detail: 'Deleted camera #$id and child geofences',
      ),
    );
  }
}
