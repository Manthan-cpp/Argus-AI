import 'dart:async';
import 'package:argus_client/argus_client.dart';

abstract class ArgusRepository {
  // Workspace & demo
  Future<Workspace> ensureWorkspace();
  Future<DemoSeedResult> seedDemo();
  Future<ClientConfig> getConfig();
  Future<WorkspaceSettings> updateSettings(WorkspaceSettings s);
  Future<void> deleteWorkspaceData();

  // Cameras & zones
  Future<List<Camera>> listCameras({int? workspaceId});
  Future<Camera> saveCamera(Camera c, {int? workspaceId});
  Future<void> deleteCamera(int id);
  Future<List<Zone>> listZones(int cameraId);
  Future<Zone> saveZone(Zone z);
  Future<void> deleteZone(int id);

  // Facilities (Workspaces)
  Future<Workspace> createFacility(
    String name, {
    String? description,
    required String creatorName,
  });
  Future<Workspace?> joinFacility(
    String code, {
    required String userName,
  });
  Future<List<Workspace>> listFacilities({required String userName});
  Future<Workspace?> getFacility(int facilityId, {String? userName});
  Future<Workspace> updateFacility(
    int facilityId, {
    required String userName,
    String? name,
    String? description,
  });
  Future<bool> deleteFacility(int facilityId, {required String userName});
  Future<DispatchRoom?> getRoomForFacility(int facilityId, {String? userName});

  // Rules
  Future<ParseResult> interpretRule(String sentence, {int? cameraId});
  Future<List<RuleSpec>> listRules();
  Future<RuleSpec> saveRule(RuleSpec r);
  Future<void> deleteRule(int id);
  Future<DryRunResult> dryRunRule(RuleSpec r, String replayClipId);

  // Live pipeline
  Future<SignalAck> sendSignals(SignalBatch batch);
  Future<void> uploadEvidence(EvidenceUpload upload);
  Stream<IncidentUpdate> watchIncidents({int? sinceIncidentId});

  // Incidents
  Future<List<Incident>> listIncidents({int? workspaceId, String? status, String? severity, int? cameraId, int? ruleId});
  Future<IncidentDetail> getIncident(int id);
  Future<Incident> acknowledge(int id, {String? note});
  Future<Incident> resolve(int id, {String? note});
  Future<Incident> markFalsePositive(int id, {String? note});
  Future<bool> deleteIncident(int id);
  Future<bool> deleteAllIncidents({int? workspaceId});

  // Contacts & escalation, lab, audit
  Future<List<Contact>> listContacts();
  Future<Contact> saveContact(Contact c);
  Future<void> deleteContact(int id);
  Future<DetectorLabReport?> getLabReport();
  Future<void> saveLabReport(DetectorLabReport r);
  Future<List<AuditEntry>> listAudit({int limit = 100});
  Future<HealthInfo> health();

  // User Authentication & Profiles
  Future<UserProfile> signUp(String fullName, String password);
  Future<UserProfile> login(String fullName, String password);
  Future<UserProfile?> getCurrentUser({String? fullName});
  Future<void> resetAllData();

  // In-App Dispatch Rooms & Operations Collaboration
  Future<DispatchRoom> createRoom(
    String name, {
    String? description,
    List<int>? cameraIds,
    int? workspaceId,
    required String creatorName,
    required String creatorRole,
  });
  Future<DispatchRoom?> joinRoom(
    String code, {
    required String userName,
  });
  Future<bool> deleteRoom(int roomId, {required String userName});
  Future<DispatchRoom> updateRoom(
    int roomId, {
    required String userName,
    String? name,
    String? description,
    List<int>? cameraIds,
  });
  Future<List<DispatchRoom>> listRooms({
    int? workspaceId,
    String? userName,
  });
  Future<DispatchRoom?> getRoom(int roomId, {String? userName});
  Future<DispatchRoom?> getRoomByCode(String code);
  Future<List<RoomMember>> listRoomMembers(int roomId);

  // Live Dispatch Room Messaging & Alerts
  Future<RoomMessage> sendRoomMessage(
    int roomId,
    String content, {
    String? senderName,
    String? senderRole,
    int? senderId,
  });
  Future<List<RoomMessage>> listRoomMessages(int roomId, {int? limit});
  Stream<RoomMessage> watchRoomMessages(int roomId);
}
