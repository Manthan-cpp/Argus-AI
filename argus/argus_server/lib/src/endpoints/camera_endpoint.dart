import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import 'workspace_endpoint.dart';

class CameraEndpoint extends Endpoint {
  Future<List<Camera>> list(Session session) async {
    final ws = await WorkspaceEndpoint().ensure(session);
    return await Camera.db.find(
      session,
      where: (t) => t.workspaceId.equals(ws.id!),
      orderBy: (t) => t.id,
    );
  }

  Future<Camera> save(Session session, Camera camera) async {
    final ws = await WorkspaceEndpoint().ensure(session);
    final targetCam = camera.copyWith(workspaceId: ws.id!);

    if (targetCam.id == null || targetCam.id == 0) {
      final toInsert = targetCam.copyWith(
        id: null,
        createdAt: DateTime.now(),
      );
      final inserted = await Camera.db.insertRow(session, toInsert);
      
      await AuditEntry.db.insertRow(
        session,
        AuditEntry(
          workspaceId: ws.id!,
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
          workspaceId: ws.id!,
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
    final ws = await WorkspaceEndpoint().ensure(session);
    
    // Delete attached zones
    await Zone.db.deleteWhere(
      session,
      where: (t) => t.cameraId.equals(id),
    );

    // Delete camera
    await Camera.db.deleteWhere(
      session,
      where: (t) => t.id.equals(id) & t.workspaceId.equals(ws.id!),
    );

    await AuditEntry.db.insertRow(
      session,
      AuditEntry(
        workspaceId: ws.id!,
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
