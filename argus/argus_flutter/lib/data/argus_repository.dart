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
  Future<List<Camera>> listCameras();
  Future<Camera> saveCamera(Camera c);
  Future<void> deleteCamera(int id);
  Future<List<Zone>> listZones(int cameraId);
  Future<Zone> saveZone(Zone z);
  Future<void> deleteZone(int id);

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
  Future<List<Incident>> listIncidents({String? status, String? severity, int? cameraId, int? ruleId});
  Future<IncidentDetail> getIncident(int id);
  Future<Incident> acknowledge(int id, {String? note});
  Future<Incident> resolve(int id, {String? note});
  Future<Incident> markFalsePositive(int id, {String? note});
  Future<bool> deleteIncident(int id);
  Future<bool> deleteAllIncidents();

  // Contacts & escalation, lab, audit
  Future<List<Contact>> listContacts();
  Future<Contact> saveContact(Contact c);
  Future<void> deleteContact(int id);
  Future<DetectorLabReport?> getLabReport();
  Future<void> saveLabReport(DetectorLabReport r);
  Future<List<AuditEntry>> listAudit({int limit = 100});
  Future<HealthInfo> health();

  // User Authentication & Profiles
  Future<UserProfile> login(String fullName, String role, {String? email});
  Future<UserProfile> getCurrentUser();

  // In-App Dispatch Rooms & Operations Collaboration
  Future<DispatchRoom> createRoom(
    String name, {
    String? description,
    List<int>? cameraIds,
    String? creatorName,
    String? creatorRole,
  });
  Future<DispatchRoom?> joinRoom(
    String code, {
    required String userName,
    required String userRole,
    String? userEmail,
  });
  Future<List<DispatchRoom>> listRooms();
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
