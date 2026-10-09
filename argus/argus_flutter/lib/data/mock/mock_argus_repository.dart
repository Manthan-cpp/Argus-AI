import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:argus_client/argus_client.dart';
import 'package:argus_engine/argus_engine.dart' as engine;
import '../../core/util/preloaded_scenes.dart';
import '../argus_repository.dart';

/// MockArgusRepository implementing full Phase 1 mock scenario pipelines (S1–S4).
/// All data here is strictly for zero-friction mock evaluation.
class MockArgusRepository implements ArgusRepository {
  static final Random _random = Random();

  // MOCK: In-memory stores
  Workspace _workspace = Workspace(
    id: 1,
    ownerUserId: 'guest-user-001',
    name: 'Main Facility (Demo)',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    settings: WorkspaceSettings(
      cloudVerification: false,
      blurEvidence: true,
      retentionDays: 7,
      browserNotifications: true,
      telegramLinked: false,
      timezone: 'UTC',
    ),
  );

  final List<Camera> _cameras = [];
  final List<Zone> _zones = [];
  final List<RuleSpec> _rules = [];
  final List<Incident> _incidents = [];
  final Map<int, List<IncidentEvent>> _incidentEvents = {};
  final List<Contact> _contacts = [];
  final List<AuditEntry> _auditLog = [];

  // In-app user profile & dispatch rooms
  UserProfile _currentUser = UserProfile(
    id: 1,
    workspaceId: 1,
    fullName: 'Chief Operations Officer',
    email: 'organizer@argus.ai',
    role: 'organizer',
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
  );
  final List<DispatchRoom> _rooms = [];
  final Map<int, List<RoomMember>> _roomMembers = {};
  final Map<int, List<RoomMessage>> _roomMessages = {};
  final Map<int, StreamController<RoomMessage>> _roomStreamControllers = {};

  final StreamController<IncidentUpdate> _incidentStreamCtrl =
      StreamController<IncidentUpdate>.broadcast();

  final engine.GrammarParser _grammarParser = const engine.GrammarParser();

  MockArgusRepository() {
    _initDefaultDispatchRooms();
  }

  void _initDefaultDispatchRooms() {
    final defaultRoom = DispatchRoom(
      id: 1,
      workspaceId: 1,
      name: 'Terminal 1 Command Hub',
      code: 'ARG-7842',
      description: 'Central operations dispatch and guard deployment hub for Terminal 1.',
      createdById: 1,
      createdByName: 'Chief Operations Officer',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      cameraIds: [1, 2, 3],
      isActive: true,
    );
    _rooms.add(defaultRoom);

    _roomMembers[1] = [
      RoomMember(
        id: 1,
        roomId: 1,
        userId: 1,
        userName: 'Chief Operations Officer',
        userRole: 'organizer',
        joinedAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      RoomMember(
        id: 2,
        roomId: 1,
        userId: 2,
        userName: 'Officer Sarah Jenkins',
        userRole: 'supervisor',
        joinedAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 40)),
      ),
      RoomMember(
        id: 3,
        roomId: 1,
        userId: 3,
        userName: 'Marcus Vance',
        userRole: 'member',
        joinedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 15)),
      ),
    ];

    _roomMessages[1] = [
      RoomMessage(
        id: 1,
        roomId: 1,
        senderId: null,
        senderName: 'Argus System',
        senderRole: 'system',
        kind: 'action_log',
        content: 'Dispatch Room "Terminal 1 Command Hub" initialized with code ARG-7842.',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      RoomMessage(
        id: 2,
        roomId: 1,
        senderId: 2,
        senderName: 'Officer Sarah Jenkins',
        senderRole: 'supervisor',
        kind: 'chat',
        content: 'All camera sectors synchronized and calibrated for shift rotation.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2, minutes: 20)),
      ),
      RoomMessage(
        id: 3,
        roomId: 1,
        senderId: 3,
        senderName: 'Marcus Vance',
        senderRole: 'member',
        kind: 'chat',
        content: 'Patrol unit 4 standing by near Sector B. Ready for instructions.',
        createdAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 5)),
      ),
    ];
  }

  void _initSeedData() {
    // 1. Cameras
    _cameras.addAll([
      Camera(
        id: 1,
        workspaceId: 1,
        name: 'Chemical Lab 01',
        sourceKind: 'demo',
        sourceRef: 'demo_s1_lab_entry.mp4',
        enabled: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        status: 'online',
        lastSignalAt: DateTime.now(),
      ),
      Camera(
        id: 2,
        workspaceId: 1,
        name: 'Staircase East',
        sourceKind: 'demo',
        sourceRef: 'demo_s2_fall_stairs.mp4',
        enabled: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        status: 'online',
        lastSignalAt: DateTime.now(),
      ),
      Camera(
        id: 3,
        workspaceId: 1,
        name: 'Restricted Hazard Zone',
        sourceKind: 'replay',
        sourceRef: 'demo_s3_restricted_zone.json',
        enabled: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        status: 'replay',
        lastSignalAt: DateTime.now(),
      ),
      Camera(
        id: 4,
        workspaceId: 1,
        name: 'Construction Bay North',
        sourceKind: 'demo',
        sourceRef: 'demo_s4_ppe_check.mp4',
        enabled: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        status: 'online',
        lastSignalAt: DateTime.now(),
      ),
    ]);

    // 2. Zones
    _zones.addAll([
      Zone(
        id: 10,
        cameraId: 1,
        name: 'Lab Enclosure',
        kind: 'restricted',
        color: '#F43F5E',
        polygon: [
          PointN(x: 0.15, y: 0.20),
          PointN(x: 0.85, y: 0.20),
          PointN(x: 0.85, y: 0.85),
          PointN(x: 0.15, y: 0.85),
        ],
        createdAt: DateTime.now(),
      ),
      Zone(
        id: 20,
        cameraId: 2,
        name: 'Stair Landing Hazard',
        kind: 'stairs',
        color: '#A78BFA',
        polygon: [
          PointN(x: 0.25, y: 0.35),
          PointN(x: 0.75, y: 0.35),
          PointN(x: 0.75, y: 0.90),
          PointN(x: 0.25, y: 0.90),
        ],
        createdAt: DateTime.now(),
      ),
      Zone(
        id: 30,
        cameraId: 3,
        name: 'Red Zone Perimeter',
        kind: 'restricted',
        color: '#F43F5E',
        polygon: [
          PointN(x: 0.30, y: 0.40),
          PointN(x: 0.70, y: 0.40),
          PointN(x: 0.70, y: 0.80),
          PointN(x: 0.30, y: 0.80),
        ],
        createdAt: DateTime.now(),
      ),
      Zone(
        id: 40,
        cameraId: 4,
        name: 'High Hazard Work Area',
        kind: 'work',
        color: '#FBBF24',
        polygon: [
          PointN(x: 0.10, y: 0.10),
          PointN(x: 0.90, y: 0.10),
          PointN(x: 0.90, y: 0.90),
          PointN(x: 0.10, y: 0.90),
        ],
        createdAt: DateTime.now(),
      ),
    ]);

    // 3. Rules (S1–S4)
    _rules.addAll([
      RuleSpec(
        id: 1,
        workspaceId: 1,
        name: 'After-hours Lab Entry',
        enabled: true,
        cameraIds: [1],
        trigger: RuleTrigger(
          signal: 'person_in_zone',
          zoneId: 10,
          minDurationSec: 0,
          minConfidence: 0.65,
        ),
        conditions: RuleConditions(
          timeWindows: [TimeWindow(start: '20:00', end: '06:00')],
          daysOfWeek: [1, 2, 3, 4, 5, 6, 7],
          timezone: 'UTC',
        ),
        severity: 'high',
        verify: RuleVerify(enabled: false, kind: 'generic'),
        actions: [
          RuleAction(kind: 'create_incident', paramsJson: '{}'),
          RuleAction(kind: 'snapshot', paramsJson: '{}'),
          RuleAction(kind: 'in_app', paramsJson: '{}'),
        ],
        cooldownSec: 60,
        escalation: [
          RuleEscalation(afterSec: 90, notify: 'Supervisor', message: 'Unauthorized lab entry detected after hours'),
        ],
        sourceText: 'If anyone enters the lab after 8 pm, take a snapshot and alert the supervisor.',
        parsedBy: 'grammar',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        version: 1,
      ),
      RuleSpec(
        id: 2,
        workspaceId: 1,
        name: 'Fall & Inactivity Alert',
        enabled: true,
        cameraIds: [2],
        trigger: RuleTrigger(
          signal: 'fall_suspected',
          zoneId: 20,
          minDurationSec: 15,
          minConfidence: 0.70,
        ),
        conditions: RuleConditions(
          timeWindows: [],
          daysOfWeek: [],
          timezone: 'UTC',
        ),
        severity: 'critical',
        verify: RuleVerify(enabled: false, kind: 'person_down'),
        actions: [
          RuleAction(kind: 'create_incident', paramsJson: '{}'),
          RuleAction(kind: 'snapshot', paramsJson: '{}'),
          RuleAction(kind: 'in_app', paramsJson: '{}'),
        ],
        cooldownSec: 120,
        escalation: [
          RuleEscalation(afterSec: 60, notify: 'First Responder', message: 'Fall verified and person remains motionless!'),
          RuleEscalation(afterSec: 180, notify: 'Security Lead', message: 'Critical incident unacknowledged after 3 minutes'),
        ],
        sourceText: 'If someone falls near the staircase and stays down for 15 seconds, alert security and escalate.',
        parsedBy: 'gemini',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        version: 1,
      ),
      RuleSpec(
        id: 3,
        workspaceId: 1,
        name: 'Red Zone Loitering',
        enabled: true,
        cameraIds: [3],
        trigger: RuleTrigger(
          signal: 'person_in_zone',
          zoneId: 30,
          minDurationSec: 5,
          minConfidence: 0.60,
        ),
        conditions: RuleConditions(timeWindows: [], daysOfWeek: [], timezone: 'UTC'),
        severity: 'high',
        verify: RuleVerify(enabled: false, kind: 'generic'),
        actions: [
          RuleAction(kind: 'create_incident', paramsJson: '{}'),
          RuleAction(kind: 'in_app', paramsJson: '{}'),
        ],
        cooldownSec: 45,
        escalation: [],
        sourceText: 'If a person stays in the red zone for more than 5 seconds, create a high-severity incident.',
        parsedBy: 'grammar',
        createdAt: DateTime.now().subtract(const Duration(hours: 18)),
        version: 1,
      ),
      RuleSpec(
        id: 4,
        workspaceId: 1,
        name: 'PPE Hard Hat Check',
        enabled: true,
        cameraIds: [4],
        trigger: RuleTrigger(
          signal: 'ppe_check',
          zoneId: 40,
          minDurationSec: 0,
          minConfidence: 0.60,
          ppe: 'helmet',
        ),
        conditions: RuleConditions(timeWindows: [], daysOfWeek: [], timezone: 'UTC'),
        severity: 'medium',
        verify: RuleVerify(enabled: true, kind: 'helmet'),
        actions: [
          RuleAction(kind: 'create_incident', paramsJson: '{}'),
          RuleAction(kind: 'snapshot', paramsJson: '{}'),
        ],
        cooldownSec: 90,
        escalation: [],
        sourceText: "If a person in the work zone isn't wearing a helmet, save evidence and alert the site manager.",
        parsedBy: 'gemini',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
        version: 1,
      ),
    ]);

    // 4. Contacts
    _contacts.addAll([
      Contact(
        id: 1,
        workspaceId: 1,
        name: 'Alex Rivera',
        role: 'Site Safety Officer',
        telegramChatId: '@alex_rivera_safety',
        notifyInApp: true,
      ),
      Contact(
        id: 2,
        workspaceId: 1,
        name: 'Elena Rostova',
        role: 'Facility Lead',
        telegramChatId: null,
        notifyInApp: true,
      ),
      Contact(
        id: 3,
        workspaceId: 1,
        name: 'Campus Security Desk',
        role: 'Security Dispatch',
        telegramChatId: '@campus_sec_bot',
        notifyInApp: true,
      ),
    ]);

    // 5. Seeded Incidents
    final now = DateTime.now();
    _incidents.addAll([
      Incident(
        id: 101,
        workspaceId: 1,
        cameraId: 2,
        ruleId: 2,
        ruleSnapshotJson: '{"name":"Fall & Inactivity Alert"}',
        severity: 'critical',
        status: 'open',
        openedAt: now.subtract(const Duration(minutes: 3)),
        summary: 'Fall & Inactivity Alert triggered on Staircase East',
        verification: VerificationInfo(status: 'not_requested'),
        evidenceFileKey: 'mock/evidence_s2_fall.jpg',
        signalContextJson: '{}',
      ),
      Incident(
        id: 102,
        workspaceId: 1,
        cameraId: 1,
        ruleId: 1,
        ruleSnapshotJson: '{"name":"After-hours Lab Entry"}',
        severity: 'high',
        status: 'acknowledged',
        openedAt: now.subtract(const Duration(minutes: 24)),
        ackedAt: now.subtract(const Duration(minutes: 20)),
        summary: 'After-hours Lab Entry triggered on Chemical Lab 01',
        verification: VerificationInfo(status: 'not_requested'),
        evidenceFileKey: 'mock/evidence_s1_entry.jpg',
        signalContextJson: '{}',
        assignedTo: 'Alex Rivera',
      ),
      Incident(
        id: 103,
        workspaceId: 1,
        cameraId: 3,
        ruleId: 3,
        ruleSnapshotJson: '{"name":"Red Zone Loitering"}',
        severity: 'high',
        status: 'resolved',
        openedAt: now.subtract(const Duration(hours: 2, minutes: 10)),
        ackedAt: now.subtract(const Duration(hours: 2, minutes: 5)),
        resolvedAt: now.subtract(const Duration(hours: 1, minutes: 45)),
        summary: 'Red Zone Loitering triggered on Restricted Hazard Zone',
        verification: VerificationInfo(status: 'not_requested'),
        signalContextJson: '{}',
      ),
      Incident(
        id: 104,
        workspaceId: 1,
        cameraId: 4,
        ruleId: 4,
        ruleSnapshotJson: '{"name":"PPE Hard Hat Check"}',
        severity: 'medium',
        status: 'false_positive',
        openedAt: now.subtract(const Duration(hours: 5)),
        ackedAt: now.subtract(const Duration(hours: 4, minutes: 50)),
        resolvedAt: now.subtract(const Duration(hours: 4, minutes: 40)),
        summary: 'PPE Hard Hat Check triggered on Construction Bay North',
        verification: VerificationInfo(
          status: 'rejected',
          reason: 'Worker is wearing protective high-visibility hooded gear',
          model: 'Gemini 2.5 Flash',
        ),
        signalContextJson: '{}',
      ),
    ]);

    // Populate events
    for (final inc in _incidents) {
      final incId = inc.id ?? 1;
      final events = <IncidentEvent>[
        IncidentEvent(
          id: incId * 10 + 1,
          incidentId: incId,
          at: inc.openedAt,
          kind: 'opened',
          detail: 'Incident automatically opened by Rule Engine evaluation.',
        ),
      ];

      if (inc.evidenceFileKey != null) {
        events.add(IncidentEvent(
          id: incId * 10 + 2,
          incidentId: incId,
          at: inc.openedAt.add(const Duration(seconds: 1)),
          kind: 'evidence_added',
          detail: 'Blurred privacy snapshot captured on-device and stored.',
        ));
      }

      if (inc.ackedAt != null) {
        events.add(IncidentEvent(
          id: incId * 10 + 3,
          incidentId: incId,
          at: inc.ackedAt!,
          kind: 'acknowledged',
          detail: 'Acknowledged by ${inc.assignedTo ?? "Supervisor"}. Escalations suspended.',
        ));
      }

      if (inc.resolvedAt != null) {
        events.add(IncidentEvent(
          id: incId * 10 + 4,
          incidentId: incId,
          at: inc.resolvedAt!,
          kind: inc.status == 'false_positive' ? 'false_positive' : 'resolved',
          detail: inc.status == 'false_positive'
              ? 'Marked as false positive. Feedback queued for detector lab tuning.'
              : 'Resolved after security perimeter verification.',
        ));
      }

      _incidentEvents[incId] = events;
    }

    _auditLog.clear();
    _auditLog.addAll([
      AuditEntry(
        id: 1,
        workspaceId: 1,
        at: DateTime.now().subtract(const Duration(minutes: 15)),
        actor: 'Alex Rivera',
        action: 'ACKNOWLEDGE',
        targetKind: 'Incident',
        targetId: 102,
        detail: 'Acknowledged incident #102 on Chemical Lab 01',
      ),
      AuditEntry(
        id: 2,
        workspaceId: 1,
        at: DateTime.now().subtract(const Duration(hours: 1)),
        actor: 'Elena Rostova',
        action: 'UPDATE_RULE',
        targetKind: 'RuleSpec',
        targetId: 2,
        detail: 'Adjusted motionless threshold from 10s to 15s',
      ),
    ]);
  }

  // --- WORKSPACE & DEMO ---
  @override
  Future<Workspace> ensureWorkspace() async {
    return _workspace;
  }

  @override
  Future<DemoSeedResult> seedDemo() async {
    _initSeedData();
    return DemoSeedResult(
      workspaceId: 1,
      cameraIds: _cameras.map((c) => c.id!).toList(),
      ruleIds: _rules.map((r) => r.id!).toList(),
    );
  }

  @override
  Future<ClientConfig> getConfig() async {
    return ClientConfig(
      limitsJson: '{"maxCameras":5,"maxRules":30,"retentionDays":7}',
      featuresJson: '{"cloudVerification":true,"replayMode":true,"detectorLab":true}',
    );
  }

  @override
  Future<WorkspaceSettings> updateSettings(WorkspaceSettings s) async {
    _workspace = Workspace(
      id: _workspace.id,
      ownerUserId: _workspace.ownerUserId,
      name: _workspace.name,
      createdAt: _workspace.createdAt,
      settings: s,
    );
    return s;
  }

  @override
  Future<void> deleteWorkspaceData() async {
    _cameras.clear();
    _zones.clear();
    _rules.clear();
    _incidents.clear();
    _incidentEvents.clear();
  }

  // --- CAMERAS & ZONES ---
  @override
  Future<List<Camera>> listCameras() async => List.unmodifiable(_cameras);

  @override
  Future<Camera> saveCamera(Camera c) async {
    final idx = _cameras.indexWhere((x) => x.id == c.id);
    if (idx >= 0) {
      _cameras[idx] = c;
      return c;
    } else {
      final newCam = Camera(
        id: _cameras.length + 1,
        workspaceId: 1,
        name: c.name,
        sourceKind: c.sourceKind,
        sourceRef: c.sourceRef,
        enabled: c.enabled,
        createdAt: DateTime.now(),
        status: c.status,
      );
      _cameras.add(newCam);
      return newCam;
    }
  }

  @override
  Future<void> deleteCamera(int id) async {
    _cameras.removeWhere((c) => c.id == id);
    _zones.removeWhere((z) => z.cameraId == id);
  }

  @override
  Future<List<Zone>> listZones(int cameraId) async {
    return _zones.where((z) => z.cameraId == cameraId).toList();
  }

  @override
  Future<Zone> saveZone(Zone z) async {
    final idx = _zones.indexWhere((x) => x.id == z.id);
    if (idx >= 0) {
      _zones[idx] = z;
      return z;
    } else {
      final newZone = Zone(
        id: _zones.length + 1,
        cameraId: z.cameraId,
        name: z.name,
        kind: z.kind,
        color: z.color,
        polygon: z.polygon,
        createdAt: DateTime.now(),
      );
      _zones.add(newZone);
      return newZone;
    }
  }

  @override
  Future<void> deleteZone(int id) async {
    _zones.removeWhere((z) => z.id == id);
  }

  // --- RULES ---
  @override
  Future<ParseResult> interpretRule(String sentence, {int? cameraId}) async {
    // Filter zones to camera if specified
    final targetZones = (cameraId != null)
        ? _zones.where((z) => z.cameraId == cameraId).toList()
        : _zones;

    // Convert to pure engine models for parsing
    final engineZones = targetZones.map((z) => engine.Zone(
      id: z.id ?? 1,
      cameraId: z.cameraId,
      name: z.name,
      kind: engine.ZoneKind.values.firstWhere(
        (k) => k.name.toLowerCase() == z.kind.toLowerCase(),
        orElse: () => engine.ZoneKind.custom,
      ),
      color: z.color,
      polygon: z.polygon.map((p) => engine.PointN(x: p.x, y: p.y)).toList(),
      createdAt: z.createdAt,
    )).toList();

    final parsed = _grammarParser.parse(sentence, knownZones: engineZones);

    if (parsed.spec == null) {
      return ParseResult(
        parsedBy: 'grammar',
        confidence: 0.2,
        warnings: parsed.warnings,
        unsupportedReason: parsed.unsupportedReason,
        alternatives: parsed.alternatives,
      );
    }

    final s = parsed.spec!;
    final ruleSpec = RuleSpec(
      id: _rules.length + 1,
      workspaceId: 1,
      name: s.name,
      enabled: s.enabled,
      cameraIds: cameraId != null ? [cameraId] : s.cameraIds,
      trigger: RuleTrigger(
        signal: s.trigger.signal.name,
        zoneId: s.trigger.zoneId,
        minDurationSec: s.trigger.minDurationSec,
        minConfidence: s.trigger.minConfidence,
        minCount: s.trigger.minCount,
        ppe: s.trigger.ppe,
      ),
      conditions: RuleConditions(
        timeWindows: s.conditions.timeWindows.map((tw) => TimeWindow(start: tw.start, end: tw.end)).toList(),
        daysOfWeek: s.conditions.daysOfWeek,
        timezone: s.conditions.timezone,
      ),
      severity: s.severity.name,
      verify: RuleVerify(enabled: s.verify.enabled, kind: s.verify.kind),
      actions: s.actions.map((a) => RuleAction(kind: a.kind, paramsJson: '{}')).toList(),
      cooldownSec: s.cooldownSec,
      escalation: s.escalation.map((e) => RuleEscalation(
        afterSec: e.afterSec,
        notify: e.notify,
        message: e.message,
      )).toList(),
      sourceText: s.sourceText,
      parsedBy: 'gemini (mock)',
      createdAt: DateTime.now(),
      version: 1,
    );

    return ParseResult(
      spec: ruleSpec,
      parsedBy: 'gemini (mock)',
      confidence: 0.94,
      warnings: parsed.warnings,
      alternatives: parsed.alternatives,
    );
  }

  @override
  Future<List<RuleSpec>> listRules() async => List.unmodifiable(_rules);

  @override
  Future<RuleSpec> saveRule(RuleSpec r) async {
    final idx = _rules.indexWhere((x) => x.id == r.id);
    if (idx >= 0) {
      _rules[idx] = r;
      return r;
    } else {
      final newRule = RuleSpec(
        id: _rules.length + 1,
        workspaceId: 1,
        name: r.name,
        enabled: r.enabled,
        cameraIds: r.cameraIds,
        trigger: r.trigger,
        conditions: r.conditions,
        severity: r.severity,
        verify: r.verify,
        actions: r.actions,
        cooldownSec: r.cooldownSec,
        escalation: r.escalation,
        sourceText: r.sourceText,
        parsedBy: r.parsedBy,
        createdAt: DateTime.now(),
        version: r.version,
      );
      _rules.add(newRule);
      return newRule;
    }
  }

  @override
  Future<void> deleteRule(int id) async {
    _rules.removeWhere((r) => r.id == id);
  }

  @override
  Future<DryRunResult> dryRunRule(RuleSpec r, String replayClipId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return DryRunResult(
      triggered: true,
      triggeredAtMs: 3400,
      explanation: 'Condition matched at 3.4s in test clip. Trigger signal "${r.trigger.signal}" satisfied for ${r.trigger.minDurationSec}s.',
      firedPointsMs: [3400],
    );
  }

  // --- LIVE SIGNALS & STREAMING ---
  @override
  Future<SignalAck> sendSignals(SignalBatch batch) async {
    if (batch.signals.isNotEmpty) {
      final latest = batch.signals.last;
      final persons = latest.persons;
      final activeRules = _rules.where((r) => r.enabled && (r.cameraIds.isEmpty || r.cameraIds.contains(batch.cameraId))).toList();

      for (final rule in activeRules) {
        bool met = false;
        String detail = '';
        if (rule.trigger.signal == 'person_in_zone') {
          final targetZoneId = rule.trigger.zoneId;
          for (final p in persons) {
            final matches = (targetZoneId == null || targetZoneId == 0)
                ? p.zoneIds.isNotEmpty
                : p.zoneIds.contains(targetZoneId);
            if (matches) {
              met = true;
              final zoneObj = (targetZoneId != null && targetZoneId > 0)
                  ? _zones.where((z) => z.id == targetZoneId).firstOrNull
                  : null;
              final zoneDesc = zoneObj != null ? zoneObj.name : ((targetZoneId != null && targetZoneId > 0) ? 'Zone #$targetZoneId' : 'Restricted Zone');
              detail = 'Person (ID ${p.trackId}) in $zoneDesc';
              break;
            }
          }
        } else if (rule.trigger.signal == 'person_count') {
          final targetZoneId = rule.trigger.zoneId;
          final minCount = rule.trigger.minCount ?? 1;
          final matchingPersons = (targetZoneId != null && targetZoneId > 0)
              ? persons.where((p) => p.zoneIds.contains(targetZoneId)).toList()
              : persons;
          if (matchingPersons.length >= minCount) {
            met = true;
            final zoneObj = (targetZoneId != null && targetZoneId > 0)
                ? _zones.where((z) => z.id == targetZoneId).firstOrNull
                : null;
            final zoneDesc = zoneObj != null ? zoneObj.name : 'camera field of view';
            detail = 'Crowd surge: ${matchingPersons.length} people gathered in $zoneDesc (threshold: $minCount)';
          }
        } else if (rule.trigger.signal == 'fall_suspected') {
          final targetZoneId = rule.trigger.zoneId;
          final reqFallMs = rule.trigger.minDurationSec * 1000;
          for (final p in persons) {
            if (targetZoneId != null && targetZoneId > 0 && !p.zoneIds.contains(targetZoneId)) {
              continue;
            }
            if (p.fallScore >= 0.6) {
              if (reqFallMs > 0) {
                if (p.motionlessMs >= reqFallMs) {
                  met = true;
                  detail = 'Subject fell and remained down for ${(p.motionlessMs / 1000).toStringAsFixed(0)}s';
                  break;
                }
              } else {
                // Require sustained fall confirmation (at least 1s motionless or high confidence)
                if (p.motionlessMs >= 1000 || p.fallScore >= 0.85) {
                  met = true;
                  detail = 'Sudden fall detected';
                  break;
                }
              }
            }
          }
        } else if (rule.trigger.signal == 'motionless') {
          final targetZoneId = rule.trigger.zoneId;
          final reqMs = rule.trigger.minDurationSec * 1000;
          for (final p in persons) {
            if (targetZoneId != null && targetZoneId > 0 && !p.zoneIds.contains(targetZoneId)) {
              continue;
            }
            if (p.motionlessMs >= reqMs) {
              met = true;
              detail = 'Motionless subject detected for ${(p.motionlessMs / 1000).toStringAsFixed(0)}s';
              break;
            }
          }
        }

        if (met) {
          Incident? existing;
          try {
            existing = _incidents.firstWhere(
              (i) => i.ruleId == rule.id && i.cameraId == batch.cameraId && (i.status == 'open' || i.status == 'acknowledged'),
            );
          } catch (_) {
            existing = null;
          }

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
            final newId = _incidents.length + 101;
            final inc = Incident(
              id: newId,
              workspaceId: 1,
              cameraId: batch.cameraId,
              ruleId: rule.id!,
              ruleSnapshotJson: json.encode(rule.toJson()),
              severity: rule.severity,
              status: 'open',
              openedAt: DateTime.now(),
              verification: VerificationInfo(status: 'not_requested', reason: 'Vision telemetry condition met'),
              summary: '${rule.name}: $detail',
              signalContextJson: '{}',
            );
            _incidents.insert(0, inc);
            final event = IncidentEvent(
              incidentId: newId,
              at: DateTime.now(),
              kind: 'opened',
              detail: detail,
            );
            _incidentEvents[newId] = [event];
            _incidentStreamCtrl.add(IncidentUpdate(incident: inc, event: event));
            _broadcastAlertToRooms(inc);

            // Escalation ladder simulation
            final escalationSec = rule.escalation.isNotEmpty ? rule.escalation.first.afterSec : 30;
            Timer(Duration(seconds: escalationSec), () {
              final currIdx = _incidents.indexWhere((x) => x.id == newId);
              if (currIdx >= 0 && _incidents[currIdx].status == 'open') {
                final escEvent = IncidentEvent(
                  incidentId: newId,
                  at: DateTime.now(),
                  kind: 'escalated',
                  detail: 'Escalated due to unacknowledged timeout (${escalationSec}s)',
                );
                _incidentEvents[newId]?.insert(0, escEvent);
                _incidentStreamCtrl.add(IncidentUpdate(incident: _incidents[currIdx], event: escEvent));
              }
            });
          }
        }
      }
    }

    return SignalAck(
      accepted: true,
      needEvidenceFor: [],
      serverTimeMs: DateTime.now().millisecondsSinceEpoch,
    );
  }

  final Map<int, String> _incidentEvidence = {};

  @override
  Future<void> uploadEvidence(EvidenceUpload upload) async {
    _incidentEvidence[upload.incidentId] = upload.snapshotJpegBase64;
    final idx = _incidents.indexWhere((i) => i.id == upload.incidentId);
    if (idx >= 0) {
      _incidents[idx] = _incidents[idx].copyWith(
        evidenceFileKey: 'ev_${upload.incidentId}',
      );
    }
  }

  @override
  Stream<IncidentUpdate> watchIncidents({int? sinceIncidentId}) {
    return _incidentStreamCtrl.stream;
  }

  // --- INCIDENTS ---
  @override
  Future<List<Incident>> listIncidents({String? status, String? severity, int? cameraId, int? ruleId}) async {
    return _incidents.where((i) {
      if (status != null && i.status.toLowerCase() != status.toLowerCase()) return false;
      if (severity != null && i.severity.toLowerCase() != severity.toLowerCase()) return false;
      if (cameraId != null && i.cameraId != cameraId) return false;
      if (ruleId != null && i.ruleId != ruleId) return false;
      return true;
    }).toList();
  }

  @override
  Future<IncidentDetail> getIncident(int id) async {
    final inc = _incidents.firstWhere((i) => i.id == id);
    final events = _incidentEvents[id] ?? [];
    String? evidence = _incidentEvidence[id];
    if (evidence == null || evidence.isEmpty) {
      final cam = _cameras.where((c) => c.id == inc.cameraId).firstOrNull;
      evidence = getPreloadedSceneFrame(cam?.sourceRef);
    }
    return IncidentDetail(
      incident: inc,
      events: events,
      evidenceUrl: evidence,
    );
  }

  @override
  Future<Incident> acknowledge(int id, {String? note}) async {
    final idx = _incidents.indexWhere((i) => i.id == id);
    if (idx < 0) throw Exception('Incident not found');

    final updated = Incident(
      id: _incidents[idx].id,
      workspaceId: _incidents[idx].workspaceId,
      cameraId: _incidents[idx].cameraId,
      ruleId: _incidents[idx].ruleId,
      ruleSnapshotJson: _incidents[idx].ruleSnapshotJson,
      severity: _incidents[idx].severity,
      status: 'acknowledged',
      openedAt: _incidents[idx].openedAt,
      ackedAt: DateTime.now(),
      resolvedAt: _incidents[idx].resolvedAt,
      evidenceFileKey: _incidents[idx].evidenceFileKey,
      verification: _incidents[idx].verification,
      summary: _incidents[idx].summary,
      signalContextJson: _incidents[idx].signalContextJson,
      assignedTo: 'Current User',
    );

    _incidents[idx] = updated;

    final event = IncidentEvent(
      id: DateTime.now().millisecondsSinceEpoch,
      incidentId: id,
      at: DateTime.now(),
      kind: 'acknowledged',
      detail: note ?? 'Acknowledged by operator. Escalations cancelled.',
    );
    _incidentEvents.putIfAbsent(id, () => []).add(event);

    _incidentStreamCtrl.add(IncidentUpdate(incident: updated, event: event));
    return updated;
  }

  @override
  Future<Incident> resolve(int id, {String? note}) async {
    final idx = _incidents.indexWhere((i) => i.id == id);
    if (idx < 0) throw Exception('Incident not found');

    final updated = Incident(
      id: _incidents[idx].id,
      workspaceId: _incidents[idx].workspaceId,
      cameraId: _incidents[idx].cameraId,
      ruleId: _incidents[idx].ruleId,
      ruleSnapshotJson: _incidents[idx].ruleSnapshotJson,
      severity: _incidents[idx].severity,
      status: 'resolved',
      openedAt: _incidents[idx].openedAt,
      ackedAt: _incidents[idx].ackedAt ?? DateTime.now(),
      resolvedAt: DateTime.now(),
      evidenceFileKey: _incidents[idx].evidenceFileKey,
      verification: _incidents[idx].verification,
      summary: _incidents[idx].summary,
      signalContextJson: _incidents[idx].signalContextJson,
      assignedTo: _incidents[idx].assignedTo ?? 'Current User',
    );

    _incidents[idx] = updated;

    final event = IncidentEvent(
      id: DateTime.now().millisecondsSinceEpoch,
      incidentId: id,
      at: DateTime.now(),
      kind: 'resolved',
      detail: note ?? 'Incident resolved by operator.',
    );
    _incidentEvents.putIfAbsent(id, () => []).add(event);

    _incidentStreamCtrl.add(IncidentUpdate(incident: updated, event: event));
    return updated;
  }

  @override
  Future<Incident> markFalsePositive(int id, {String? note}) async {
    final idx = _incidents.indexWhere((i) => i.id == id);
    if (idx < 0) throw Exception('Incident not found');

    final updated = Incident(
      id: _incidents[idx].id,
      workspaceId: _incidents[idx].workspaceId,
      cameraId: _incidents[idx].cameraId,
      ruleId: _incidents[idx].ruleId,
      ruleSnapshotJson: _incidents[idx].ruleSnapshotJson,
      severity: _incidents[idx].severity,
      status: 'false_positive',
      openedAt: _incidents[idx].openedAt,
      ackedAt: _incidents[idx].ackedAt ?? DateTime.now(),
      resolvedAt: DateTime.now(),
      evidenceFileKey: _incidents[idx].evidenceFileKey,
      verification: _incidents[idx].verification,
      summary: _incidents[idx].summary,
      signalContextJson: _incidents[idx].signalContextJson,
      assignedTo: _incidents[idx].assignedTo ?? 'Current User',
    );

    _incidents[idx] = updated;

    final event = IncidentEvent(
      id: DateTime.now().millisecondsSinceEpoch,
      incidentId: id,
      at: DateTime.now(),
      kind: 'false_positive',
      detail: note ?? 'Marked as false positive. Sent to detector lab.',
    );
    _incidentEvents.putIfAbsent(id, () => []).add(event);

    _incidentStreamCtrl.add(IncidentUpdate(incident: updated, event: event));
    return updated;
  }

  @override
  Future<bool> deleteIncident(int id) async {
    _incidents.removeWhere((i) => i.id == id);
    _incidentEvents.remove(id);
    return true;
  }

  @override
  Future<bool> deleteAllIncidents() async {
    _incidents.clear();
    _incidentEvents.clear();
    return true;
  }

  // --- CONTACTS & LAB ---
  @override
  Future<List<Contact>> listContacts() async => List.unmodifiable(_contacts);

  @override
  Future<Contact> saveContact(Contact c) async {
    final idx = _contacts.indexWhere((x) => x.id == c.id);
    if (idx >= 0) {
      _contacts[idx] = c;
      return c;
    } else {
      final newContact = Contact(
        id: _contacts.length + 1,
        workspaceId: 1,
        name: c.name,
        role: c.role,
        telegramChatId: c.telegramChatId,
        notifyInApp: c.notifyInApp,
      );
      _contacts.add(newContact);
      return newContact;
    }
  }

  @override
  Future<void> deleteContact(int id) async {
    _contacts.removeWhere((c) => c.id == id);
  }

  @override
  Future<String> createTelegramLinkCode() async => 'ARGUS-7829-TG';

  @override
  Future<DetectorLabReport?> getLabReport() async {
    return DetectorLabReport(
      clips: [
        LabClipResult(
          clipId: 'S1-Lab-01',
          scenario: 'After-hours Lab Entry',
          expectedEvents: 4,
          detectedEvents: 4,
          tp: 4,
          fp: 0,
          fn: 0,
          latencyMsP50: 120,
        ),
        LabClipResult(
          clipId: 'S2-Fall-Stairs',
          scenario: 'Fall & Inactivity near stairs',
          expectedEvents: 3,
          detectedEvents: 3,
          tp: 3,
          fp: 1,
          fn: 0,
          latencyMsP50: 240,
        ),
        LabClipResult(
          clipId: 'S3-RedZone-01',
          scenario: 'Restricted Zone Intrusion',
          expectedEvents: 5,
          detectedEvents: 5,
          tp: 5,
          fp: 0,
          fn: 0,
          latencyMsP50: 95,
        ),
      ],
      precision: 0.923,
      recall: 1.0,
      generatedAt: DateTime.now().subtract(const Duration(hours: 4)),
      notes: 'Evaluated against local benchmark test clips in Chrome on CPU WASM.',
    );
  }

  @override
  Future<void> saveLabReport(DetectorLabReport r) async {}

  @override
  Future<List<AuditEntry>> listAudit({int limit = 100}) async {
    return List.unmodifiable(_auditLog.take(limit));
  }

  @override
  Future<HealthInfo> health() async {
    return HealthInfo(
      version: '1.0.0',
      engineVersion: 'argus_engine-1.0.0',
      geminiState: 'available',
      quotaNote: 'AI Studio Free Tier active. 15 RPM token bucket.',
      queueDepth: 0,
    );
  }

  void _broadcastAlertToRooms(Incident inc) {
    final cameraObj = _cameras.where((c) => c.id == inc.cameraId).firstOrNull;
    final cameraName = cameraObj?.name ?? 'Camera #${inc.cameraId}';
    final alertContent = 'Guards near the $cameraName area, please look into the matter immediately.';

    for (final room in _rooms) {
      if (room.isActive && (room.cameraIds.isEmpty || room.cameraIds.contains(inc.cameraId))) {
        final newMsg = RoomMessage(
          id: (_roomMessages[room.id!]?.length ?? 0) + 1,
          roomId: room.id!,
          senderId: null,
          senderName: 'Argus System',
          senderRole: 'system',
          kind: 'system_alert',
          content: alertContent,
          incidentId: inc.id,
          cameraName: cameraName,
          severity: inc.severity,
          createdAt: DateTime.now(),
        );
        _roomMessages.putIfAbsent(room.id!, () => []).add(newMsg);
        _roomStreamControllers[room.id!]?.add(newMsg);
      }
    }
  }

  // User Authentication & Profiles
  @override
  Future<UserProfile> login(String fullName, String role, {String? email}) async {
    final cleanRole = role.trim().toLowerCase();
    final userEmail = (email != null && email.isNotEmpty)
        ? email
        : '${fullName.toLowerCase().replaceAll(' ', '.')}@argus.ai';

    _currentUser = UserProfile(
      id: _currentUser.id,
      workspaceId: 1,
      fullName: fullName.trim(),
      email: userEmail,
      role: cleanRole,
      createdAt: DateTime.now(),
    );
    return _currentUser;
  }

  @override
  Future<UserProfile> getCurrentUser() async {
    return _currentUser;
  }

  // In-App Dispatch Rooms & Operations Collaboration
  @override
  Future<DispatchRoom> createRoom(
    String name, {
    String? description,
    List<int>? cameraIds,
    String? creatorName,
    String? creatorRole,
  }) async {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final code = 'ARG-${List.generate(4, (_) => chars[_random.nextInt(chars.length)]).join()}';
    final newId = _rooms.length + 1;
    final effectiveCreator = (creatorName != null && creatorName.isNotEmpty)
        ? creatorName
        : _currentUser.fullName;
    final effectiveRole = (creatorRole != null && creatorRole.isNotEmpty)
        ? creatorRole
        : _currentUser.role;

    final room = DispatchRoom(
      id: newId,
      workspaceId: 1,
      name: name.trim(),
      code: code,
      description: description?.trim(),
      createdById: _currentUser.id ?? 1,
      createdByName: effectiveCreator,
      createdAt: DateTime.now(),
      cameraIds: cameraIds ?? <int>[],
      isActive: true,
    );
    _rooms.add(room);

    _roomMembers[newId] = [
      RoomMember(
        id: 1,
        roomId: newId,
        userId: _currentUser.id ?? 1,
        userName: effectiveCreator,
        userRole: effectiveRole,
        joinedAt: DateTime.now(),
      ),
    ];

    final initialMsg = RoomMessage(
      id: 1,
      roomId: newId,
      senderId: null,
      senderName: 'Argus System',
      senderRole: 'system',
      kind: 'action_log',
      content: 'Dispatch Room "${room.name}" created with code $code.',
      createdAt: DateTime.now(),
    );
    _roomMessages[newId] = [initialMsg];

    return room;
  }

  @override
  Future<DispatchRoom?> joinRoom(
    String code, {
    required String userName,
    required String userRole,
    String? userEmail,
  }) async {
    final cleanCode = code.trim().toUpperCase();
    final room = _rooms.where((r) => r.code == cleanCode && r.isActive).firstOrNull;
    if (room == null) return null;

    final roomId = room.id!;
    final members = _roomMembers.putIfAbsent(roomId, () => []);
    final existing = members.where((m) => m.userName == userName).firstOrNull;
    if (existing == null) {
      final newMember = RoomMember(
        id: members.length + 1,
        roomId: roomId,
        userId: members.length + 10,
        userName: userName.trim(),
        userRole: userRole.trim().toLowerCase(),
        joinedAt: DateTime.now(),
      );
      members.add(newMember);

      final joinMsg = RoomMessage(
        id: (_roomMessages[roomId]?.length ?? 0) + 1,
        roomId: roomId,
        senderId: newMember.userId,
        senderName: newMember.userName,
        senderRole: newMember.userRole,
        kind: 'action_log',
        content: '$userName joined as ${userRole.toUpperCase()}.',
        createdAt: DateTime.now(),
      );
      _roomMessages.putIfAbsent(roomId, () => []).add(joinMsg);
      _roomStreamControllers[roomId]?.add(joinMsg);
    }
    return room;
  }

  @override
  Future<List<DispatchRoom>> listRooms() async {
    return List.unmodifiable(_rooms.where((r) => r.isActive).toList().reversed);
  }

  @override
  Future<DispatchRoom?> getRoomByCode(String code) async {
    final cleanCode = code.trim().toUpperCase();
    return _rooms.where((r) => r.code == cleanCode).firstOrNull;
  }

  @override
  Future<List<RoomMember>> listRoomMembers(int roomId) async {
    return List.unmodifiable(_roomMembers[roomId] ?? []);
  }

  // Live Dispatch Room Messaging & Alerts
  @override
  Future<RoomMessage> sendRoomMessage(
    int roomId,
    String content, {
    String? senderName,
    String? senderRole,
    int? senderId,
  }) async {
    final newId = (_roomMessages[roomId]?.length ?? 0) + 1;
    final msg = RoomMessage(
      id: newId,
      roomId: roomId,
      senderId: senderId ?? _currentUser.id,
      senderName: senderName ?? _currentUser.fullName,
      senderRole: senderRole ?? _currentUser.role,
      kind: 'chat',
      content: content.trim(),
      createdAt: DateTime.now(),
    );

    _roomMessages.putIfAbsent(roomId, () => []).add(msg);
    _roomStreamControllers[roomId]?.add(msg);
    return msg;
  }

  @override
  Future<List<RoomMessage>> listRoomMessages(int roomId, {int? limit}) async {
    final list = _roomMessages[roomId] ?? [];
    if (limit != null && list.length > limit) {
      return List.unmodifiable(list.sublist(list.length - limit));
    }
    return List.unmodifiable(list);
  }

  @override
  Stream<RoomMessage> watchRoomMessages(int roomId) {
    final ctrl = _roomStreamControllers.putIfAbsent(
      roomId,
      () => StreamController<RoomMessage>.broadcast(),
    );
    return ctrl.stream;
  }
}
