import 'dart:math';
import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';

class WorkspaceEndpoint extends Endpoint {
  static final _random = Random();

  static String _generateCode(String prefix) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final suffix = List.generate(4, (_) => chars[_random.nextInt(chars.length)]).join();
    return '$prefix-$suffix';
  }

  Future<Workspace> ensure(Session session) async {
    var ws = await Workspace.db.findFirstRow(
      session,
      where: (t) => t.isActive.equals(true),
      orderBy: (t) => t.id,
    );

    if (ws != null) return ws;

    final orgCode = _generateCode('ORG');
    final supCode = _generateCode('SUP');
    final grdCode = _generateCode('GRD');

    final newWs = Workspace(
      ownerUserId: 'System Administrator',
      name: 'Default Security Facility',
      description: 'Default surveillance and guard operations facility',
      organizerCode: orgCode,
      supervisorCode: supCode,
      guardCode: grdCode,
      createdAt: DateTime.now(),
      isActive: true,
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

  Future<Workspace> createWorkspace(
    Session session,
    String name, {
    String? description,
    required String creatorName,
  }) async {
    final cleanName = name.trim();
    if (cleanName.isEmpty) {
      throw ArgumentError('Facility name cannot be empty');
    }

    final cleanCreator = creatorName.trim().isNotEmpty ? creatorName.trim() : 'Organizer';

    // Generate unique role codes for this facility
    String orgCode = _generateCode('ORG');
    String supCode = _generateCode('SUP');
    String grdCode = _generateCode('GRD');

    for (int i = 0; i < 10; i++) {
      final existing = await Workspace.db.findFirstRow(
        session,
        where: (t) =>
            t.organizerCode.equals(orgCode) |
            t.supervisorCode.equals(supCode) |
            t.guardCode.equals(grdCode),
      );
      if (existing == null) break;
      orgCode = _generateCode('ORG');
      supCode = _generateCode('SUP');
      grdCode = _generateCode('GRD');
    }

    final newWs = Workspace(
      ownerUserId: cleanCreator,
      name: cleanName,
      description: description?.trim(),
      organizerCode: orgCode,
      supervisorCode: supCode,
      guardCode: grdCode,
      createdAt: DateTime.now(),
      isActive: true,
      settings: WorkspaceSettings(
        cloudVerification: false,
        blurEvidence: true,
        retentionDays: 7,
        timezone: 'UTC',
        telegramLinked: false,
        browserNotifications: true,
      ),
    );

    final savedWs = await Workspace.db.insertRow(session, newWs);

    // Create user profile in this workspace
    var user = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.workspaceId.equals(savedWs.id!) & t.fullName.equals(cleanCreator),
    );
    user ??= await UserProfile.db.insertRow(
      session,
      UserProfile(
        workspaceId: savedWs.id!,
        fullName: cleanCreator,
        role: 'organizer',
        createdAt: DateTime.now(),
      ),
    );

    // Register creator as organizer member of this workspace
    await WorkspaceMember.db.insertRow(
      session,
      WorkspaceMember(
        workspaceId: savedWs.id!,
        userId: user.id ?? 1,
        userName: cleanCreator,
        userRole: 'organizer',
        joinedAt: DateTime.now(),
      ),
    );

    return savedWs;
  }

  Future<Workspace?> joinWorkspace(
    Session session,
    String code, {
    required String userName,
  }) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) return null;

    final ws = await Workspace.db.findFirstRow(
      session,
      where: (t) =>
          t.isActive.equals(true) &
          (t.organizerCode.equals(cleanCode) |
              t.supervisorCode.equals(cleanCode) |
              t.guardCode.equals(cleanCode)),
    );

    if (ws == null) return null;

    String assignedRole = 'guard';
    if (cleanCode == ws.organizerCode || cleanCode.startsWith('ORG-')) {
      assignedRole = 'organizer';
    } else if (cleanCode == ws.supervisorCode || cleanCode.startsWith('SUP-')) {
      assignedRole = 'supervisor';
    } else if (cleanCode == ws.guardCode || cleanCode.startsWith('GRD-')) {
      assignedRole = 'guard';
    }

    final cleanName = userName.trim();

    var user = await UserProfile.db.findFirstRow(
      session,
      where: (t) => t.workspaceId.equals(ws.id!) & t.fullName.equals(cleanName),
    );
    user ??= await UserProfile.db.insertRow(
      session,
      UserProfile(
        workspaceId: ws.id!,
        fullName: cleanName,
        role: assignedRole,
        createdAt: DateTime.now(),
      ),
    );

    // Register or update workspace membership
    final existingMember = await WorkspaceMember.db.findFirstRow(
      session,
      where: (t) => t.workspaceId.equals(ws.id!) & t.userName.equals(cleanName),
    );

    if (existingMember == null) {
      await WorkspaceMember.db.insertRow(
        session,
        WorkspaceMember(
          workspaceId: ws.id!,
          userId: user.id!,
          userName: cleanName,
          userRole: assignedRole,
          joinedAt: DateTime.now(),
        ),
      );
    } else if (existingMember.userRole != assignedRole) {
      await WorkspaceMember.db.updateRow(
        session,
        existingMember.copyWith(userRole: assignedRole),
      );
    }

    // If joining as guard, conceal codes in response
    if (assignedRole == 'guard') {
      return ws.copyWith(
        organizerCode: '',
        supervisorCode: '',
        guardCode: '',
      );
    }

    return ws;
  }

  Future<List<Workspace>> listUserWorkspaces(
    Session session, {
    required String userName,
  }) async {
    final cleanName = userName.trim();
    if (cleanName.isEmpty) return <Workspace>[];

    final memberships = await WorkspaceMember.db.find(
      session,
      where: (t) => t.userName.equals(cleanName),
    );

    final joinedIds = memberships.map((m) => m.workspaceId).toSet();
    final roleByWsId = {
      for (final m in memberships) m.workspaceId: m.userRole.toLowerCase(),
    };

    final allWs = await Workspace.db.find(
      session,
      where: (t) => t.isActive.equals(true),
      orderBy: (t) => t.id,
    );

    final userWs = allWs
        .where((w) => w.ownerUserId.toLowerCase() == cleanName.toLowerCase() || joinedIds.contains(w.id))
        .map((w) {
          final isOwner = w.ownerUserId.toLowerCase() == cleanName.toLowerCase();
          final role = roleByWsId[w.id] ?? (isOwner ? 'organizer' : 'guard');

          if (role == 'guard') {
            return w.copyWith(
              organizerCode: '',
              supervisorCode: '',
              guardCode: '',
            );
          } else if (role == 'supervisor') {
            return w.copyWith(
              organizerCode: '', // Supervisors cannot see organizer code
            );
          }
          return w;
        })
        .toList();

    return userWs.reversed.toList();
  }

  Future<Workspace?> getWorkspace(
    Session session,
    int workspaceId, {
    String? userName,
  }) async {
    final ws = await Workspace.db.findById(session, workspaceId);
    if (ws == null || !ws.isActive) return null;

    if (userName != null && userName.trim().isNotEmpty) {
      final cleanName = userName.trim();
      final member = await WorkspaceMember.db.findFirstRow(
        session,
        where: (t) => t.workspaceId.equals(workspaceId) & t.userName.equals(cleanName),
      );
      final isOwner = ws.ownerUserId.toLowerCase() == cleanName.toLowerCase();
      final role = member?.userRole.toLowerCase() ?? (isOwner ? 'organizer' : 'guard');

      if (role == 'guard') {
        return ws.copyWith(
          organizerCode: '',
          supervisorCode: '',
          guardCode: '',
        );
      } else if (role == 'supervisor') {
        return ws.copyWith(
          organizerCode: '',
        );
      }
    }
    return ws;
  }

  Future<Workspace> updateWorkspace(
    Session session,
    int workspaceId, {
    required String userName,
    String? name,
    String? description,
  }) async {
    final cleanName = userName.trim();
    final ws = await Workspace.db.findById(session, workspaceId);
    if (ws == null || !ws.isActive) {
      throw StateError('Facility not found or inactive');
    }

    final member = await WorkspaceMember.db.findFirstRow(
      session,
      where: (t) => t.workspaceId.equals(workspaceId) & t.userName.equals(cleanName),
    );
    final isOwner = ws.ownerUserId.toLowerCase() == cleanName.toLowerCase();
    final role = member?.userRole.toLowerCase() ?? (isOwner ? 'organizer' : 'guard');

    if (role != 'organizer' && role != 'supervisor') {
      throw StateError('Permission denied: Guards cannot edit facility settings.');
    }

    final updated = ws.copyWith(
      name: (name != null && name.trim().isNotEmpty) ? name.trim() : ws.name,
      description: description?.trim() ?? ws.description,
    );

    final saved = await Workspace.db.updateRow(session, updated);

    return saved;
  }

  Future<bool> deleteWorkspace(
    Session session,
    int workspaceId, {
    required String userName,
  }) async {
    final cleanName = userName.trim();
    final ws = await Workspace.db.findById(session, workspaceId);
    if (ws == null) return false;

    final member = await WorkspaceMember.db.findFirstRow(
      session,
      where: (t) => t.workspaceId.equals(workspaceId) & t.userName.equals(cleanName),
    );
    final isOwner = ws.ownerUserId.toLowerCase() == cleanName.toLowerCase();
    final role = member?.userRole.toLowerCase() ?? (isOwner ? 'organizer' : 'guard');

    if (role != 'organizer') {
      throw StateError('Permission denied: Only the Organizer can delete a facility.');
    }

    // Cascade delete incidents and events
    final incidents = await Incident.db.find(
      session,
      where: (t) => t.workspaceId.equals(workspaceId),
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
      where: (t) => t.workspaceId.equals(workspaceId),
    );

    // Delete rules
    await RuleSpec.db.deleteWhere(
      session,
      where: (t) => t.workspaceId.equals(workspaceId),
    );

    // Delete cameras and zones
    final cameras = await Camera.db.find(
      session,
      where: (t) => t.workspaceId.equals(workspaceId),
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
      where: (t) => t.workspaceId.equals(workspaceId),
    );

    // Delete rooms and messages
    final rooms = await DispatchRoom.db.find(
      session,
      where: (t) => t.workspaceId.equals(workspaceId),
    );
    for (final rm in rooms) {
      if (rm.id != null) {
        await RoomMessage.db.deleteWhere(session, where: (t) => t.roomId.equals(rm.id!));
        await RoomMember.db.deleteWhere(session, where: (t) => t.roomId.equals(rm.id!));
      }
    }
    await DispatchRoom.db.deleteWhere(
      session,
      where: (t) => t.workspaceId.equals(workspaceId),
    );

    // Delete members and workspace
    await WorkspaceMember.db.deleteWhere(
      session,
      where: (t) => t.workspaceId.equals(workspaceId),
    );
    await Workspace.db.deleteRow(session, ws);

    return true;
  }

  Future<bool> resetAllData(Session session) async {
    // Truncate all tables for a 100% pristine clean slate
    await RoomMessage.db.deleteWhere(session, where: (t) => t.id >= 0);
    await RoomMember.db.deleteWhere(session, where: (t) => t.id >= 0);
    await DispatchRoom.db.deleteWhere(session, where: (t) => t.id >= 0);
    await IncidentEvent.db.deleteWhere(session, where: (t) => t.id >= 0);
    await Incident.db.deleteWhere(session, where: (t) => t.id >= 0);
    await Zone.db.deleteWhere(session, where: (t) => t.id >= 0);
    await Camera.db.deleteWhere(session, where: (t) => t.id >= 0);
    await RuleSpec.db.deleteWhere(session, where: (t) => t.id >= 0);
    await WorkspaceMember.db.deleteWhere(session, where: (t) => t.id >= 0);
    await Workspace.db.deleteWhere(session, where: (t) => t.id >= 0);
    await UserProfile.db.deleteWhere(session, where: (t) => t.id >= 0);
    await AuditEntry.db.deleteWhere(session, where: (t) => t.id >= 0);
    return true;
  }
}
