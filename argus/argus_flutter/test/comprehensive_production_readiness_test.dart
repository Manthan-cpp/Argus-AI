import 'package:flutter_test/flutter_test.dart';
import 'package:argus_flutter/data/mock/mock_argus_repository.dart';
import 'package:argus_client/argus_client.dart';

PersonSignal _makePerson({
  required int trackId,
  double aspect = 0.5,
  double motionScore = 0.5,
  double confidence = 0.9,
  List<int> zoneIds = const [],
  double fallScore = 0.0,
  int motionlessMs = 0,
}) {
  return PersonSignal(
    trackId: trackId,
    bboxN: BBoxN(x: 0.3, y: 0.6, w: 0.4, h: 0.2),
    footN: PointN(x: 0.5, y: 0.7),
    aspect: aspect,
    motionScore: motionScore,
    confidence: confidence,
    zoneIds: zoneIds,
    fallScore: fallScore,
    motionlessMs: motionlessMs,
  );
}

Camera _makeCamera({
  required int workspaceId,
  required String name,
  String sourceKind = 'file',
  String sourceRef = 'video.mp4',
}) {
  return Camera(
    workspaceId: workspaceId,
    name: name,
    sourceKind: sourceKind,
    sourceRef: sourceRef,
    status: 'online',
    enabled: true,
    createdAt: DateTime.now(),
  );
}

void main() {
  group('Comprehensive 90% Readiness: All Rule Types & Edge Case Scenarios', () {
    late MockArgusRepository repo;

    setUp(() {
      repo = MockArgusRepository();
    });

    test('1. Rule Scenario: person_in_zone triggers incident and dispatch alert for target zone', () async {
      final org = await repo.signUp('Director Vance', 'secureOrg999');
      final fac = await repo.createFacility(
        'Metro Transit Hub',
        creatorName: org.fullName,
      );

      final cam = await repo.saveCamera(
        _makeCamera(
          workspaceId: fac.id!,
          name: 'Platform 3 CCTV',
          sourceKind: 'rtsp',
          sourceRef: 'rtsp://10.0.0.10:554/stream1',
        ),
        workspaceId: fac.id,
      );

      final zone = await repo.saveZone(
        Zone(
          cameraId: cam.id!,
          name: 'Track Edge Danger Zone',
          kind: 'danger',
          color: '#EF4444',
          polygon: [
            PointN(x: 0.1, y: 0.1),
            PointN(x: 0.9, y: 0.1),
            PointN(x: 0.9, y: 0.9),
            PointN(x: 0.1, y: 0.9),
          ],
          createdAt: DateTime.now(),
        ),
      );

      // Create person_in_zone rule targeting zone.id
      final rule = await repo.saveRule(
        RuleSpec(
          workspaceId: fac.id!,
          name: 'Track Intrusion Warning',
          enabled: true,
          cameraIds: [cam.id!],
          trigger: RuleTrigger(
            signal: 'person_in_zone',
            zoneId: zone.id,
            minDurationSec: 0,
            minConfidence: 0.6,
          ),
          conditions: RuleConditions(timeWindows: [], daysOfWeek: [], timezone: 'UTC'),
          severity: 'critical',
          verify: RuleVerify(enabled: false, kind: 'none'),
          actions: [RuleAction(kind: 'notify', paramsJson: '{}')],
          cooldownSec: 30,
          escalation: [RuleEscalation(afterSec: 30, notify: 'security', message: 'Intrusion')],
          sourceText: 'if a person enters track danger zone alert',
          parsedBy: 'test',
          createdAt: DateTime.now(),
          version: 1,
        ),
      );

      // Create a dispatch room attached to this camera
      final room = await repo.createRoom(
        'Platform Tactical Dispatch',
        cameraIds: [cam.id!],
        workspaceId: fac.id,
        creatorName: org.fullName,
        creatorRole: 'organizer',
      );

      // Send signal where person is OUTSIDE zone -> rule must NOT trigger
      final outsideBatch = SignalBatch(
        sentAtMs: DateTime.now().millisecondsSinceEpoch,
        seq: 1,
        cameraId: cam.id!,
        signals: [
          SignalEvent(
            tsMs: DateTime.now().millisecondsSinceEpoch,
            kind: 'telemetry',
            personCount: 1,
            persons: [
              _makePerson(
                trackId: 101,
                aspect: 0.45,
                motionScore: 0.8,
                confidence: 0.95,
                zoneIds: [9999], // Different zone
              ),
            ],
          ),
        ],
      );
      await repo.sendSignals(outsideBatch);
      var incidents = await repo.listIncidents(workspaceId: fac.id);
      expect(incidents.isEmpty, isTrue);

      // Send signal where person enters target zone -> rule MUST trigger
      final insideBatch = SignalBatch(
        sentAtMs: DateTime.now().millisecondsSinceEpoch,
        seq: 2,
        cameraId: cam.id!,
        signals: [
          SignalEvent(
            tsMs: DateTime.now().millisecondsSinceEpoch,
            kind: 'telemetry',
            personCount: 1,
            persons: [
              _makePerson(
                trackId: 101,
                aspect: 0.45,
                motionScore: 0.8,
                confidence: 0.95,
                zoneIds: [zone.id!], // Inside target zone!
              ),
            ],
          ),
        ],
      );
      await repo.sendSignals(insideBatch);
      incidents = await repo.listIncidents(workspaceId: fac.id);
      expect(incidents.length, equals(1));
      expect(incidents.first.ruleId, equals(rule.id));
      expect(incidents.first.severity, equals('critical'));

      // Check room received automated alert
      final messages = await repo.listRoomMessages(room.id!);
      expect(messages.any((m) => m.kind == 'system_alert'), isTrue);
    });

    test('2. Rule Scenario: motionless subject rule triggers only after required duration threshold', () async {
      final cam = await repo.saveCamera(
        _makeCamera(workspaceId: 1, name: 'Warehouse Aisle 4'),
      );

      final rule = await repo.saveRule(
        RuleSpec(
          workspaceId: 1,
          name: 'Worker Incapacitation Alert',
          enabled: true,
          cameraIds: [cam.id!],
          trigger: RuleTrigger(
            signal: 'motionless',
            minDurationSec: 3, // Requires 3 seconds of motionless telemetry
            minConfidence: 0.6,
          ),
          conditions: RuleConditions(timeWindows: [], daysOfWeek: [], timezone: 'UTC'),
          severity: 'high',
          verify: RuleVerify(enabled: false, kind: 'none'),
          actions: [RuleAction(kind: 'notify', paramsJson: '{}')],
          cooldownSec: 30,
          escalation: [RuleEscalation(afterSec: 30, notify: 'security', message: 'Incapacitation')],
          sourceText: 'if someone motionless 3s alert',
          parsedBy: 'test',
          createdAt: DateTime.now(),
          version: 1,
        ),
      );

      // Send signal with motionlessMs = 1500 (below threshold) -> must NOT trigger
      await repo.sendSignals(
        SignalBatch(
          sentAtMs: DateTime.now().millisecondsSinceEpoch,
          seq: 1,
          cameraId: cam.id!,
          signals: [
            SignalEvent(
              tsMs: DateTime.now().millisecondsSinceEpoch,
              kind: 'telemetry',
              personCount: 1,
              persons: [
                _makePerson(
                  trackId: 202,
                  motionlessMs: 1500,
                ),
              ],
            ),
          ],
        ),
      );
      var incidents = await repo.listIncidents();
      expect(incidents.isEmpty, isTrue);

      // Send signal with motionlessMs = 3500 (satisfies 3s threshold) -> MUST trigger
      await repo.sendSignals(
        SignalBatch(
          sentAtMs: DateTime.now().millisecondsSinceEpoch,
          seq: 2,
          cameraId: cam.id!,
          signals: [
            SignalEvent(
              tsMs: DateTime.now().millisecondsSinceEpoch,
              kind: 'telemetry',
              personCount: 1,
              persons: [
                _makePerson(
                  trackId: 202,
                  motionlessMs: 3500,
                ),
              ],
            ),
          ],
        ),
      );
      incidents = await repo.listIncidents();
      expect(incidents.length, equals(1));
      expect(incidents.first.ruleId, equals(rule.id));
      expect(incidents.first.summary, contains('Worker Incapacitation Alert'));
    });

    test('3. Rule Scenario: person_count crowd surge triggers when count meets or exceeds threshold', () async {
      final cam = await repo.saveCamera(
        _makeCamera(workspaceId: 1, name: 'East Gate Turnstile'),
      );

      final rule = await repo.saveRule(
        RuleSpec(
          workspaceId: 1,
          name: 'Gate Congestion Alert',
          enabled: true,
          cameraIds: [cam.id!],
          trigger: RuleTrigger(
            signal: 'person_count',
            minCount: 3, // Trigger if 3 or more people gather
            minDurationSec: 0,
            minConfidence: 0.6,
          ),
          conditions: RuleConditions(timeWindows: [], daysOfWeek: [], timezone: 'UTC'),
          severity: 'medium',
          verify: RuleVerify(enabled: false, kind: 'none'),
          actions: [RuleAction(kind: 'notify', paramsJson: '{}')],
          cooldownSec: 30,
          escalation: [RuleEscalation(afterSec: 30, notify: 'security', message: 'Crowd')],
          sourceText: 'if 3 or more persons gather alert',
          parsedBy: 'test',
          createdAt: DateTime.now(),
          version: 1,
        ),
      );

      // 2 persons -> below threshold of 3 -> no incident
      await repo.sendSignals(
        SignalBatch(
          sentAtMs: DateTime.now().millisecondsSinceEpoch,
          seq: 1,
          cameraId: cam.id!,
          signals: [
            SignalEvent(
              tsMs: DateTime.now().millisecondsSinceEpoch,
              kind: 'telemetry',
              personCount: 2,
              persons: [
                _makePerson(trackId: 1),
                _makePerson(trackId: 2),
              ],
            ),
          ],
        ),
      );
      var incidents = await repo.listIncidents();
      expect(incidents.isEmpty, isTrue);

      // 4 persons -> satisfies threshold -> triggers incident
      await repo.sendSignals(
        SignalBatch(
          sentAtMs: DateTime.now().millisecondsSinceEpoch,
          seq: 2,
          cameraId: cam.id!,
          signals: [
            SignalEvent(
              tsMs: DateTime.now().millisecondsSinceEpoch,
              kind: 'telemetry',
              personCount: 4,
              persons: [
                _makePerson(trackId: 1),
                _makePerson(trackId: 2),
                _makePerson(trackId: 3),
                _makePerson(trackId: 4),
              ],
            ),
          ],
        ),
      );
      incidents = await repo.listIncidents();
      expect(incidents.length, equals(1));
      expect(incidents.first.ruleId, equals(rule.id));
      expect(incidents.first.summary, contains('Crowd surge: 4 people gathered'));
    });

    test('4. Camera Scoping: rule assigned to Camera A does NOT fire on Camera B telemetry', () async {
      final camA = await repo.saveCamera(_makeCamera(workspaceId: 1, name: 'Cam Alpha'));
      final camB = await repo.saveCamera(_makeCamera(workspaceId: 1, name: 'Cam Beta'));

      await repo.saveRule(
        RuleSpec(
          workspaceId: 1,
          name: 'Cam Alpha Fall Rule',
          enabled: true,
          cameraIds: [camA.id!],
          trigger: RuleTrigger(signal: 'fall_suspected', minDurationSec: 0, minConfidence: 0.6),
          conditions: RuleConditions(timeWindows: [], daysOfWeek: [], timezone: 'UTC'),
          severity: 'critical',
          verify: RuleVerify(enabled: false, kind: 'none'),
          actions: [RuleAction(kind: 'notify', paramsJson: '{}')],
          cooldownSec: 30,
          escalation: [RuleEscalation(afterSec: 30, notify: 'security', message: 'Fall')],
          sourceText: 'fall alert',
          parsedBy: 'test',
          createdAt: DateTime.now(),
          version: 1,
        ),
      );

      // Fall telemetry sent on Cam Beta
      await repo.sendSignals(
        SignalBatch(
          sentAtMs: DateTime.now().millisecondsSinceEpoch,
          seq: 1,
          cameraId: camB.id!, // Camera Beta!
          signals: [
            SignalEvent(
              tsMs: DateTime.now().millisecondsSinceEpoch,
              kind: 'telemetry',
              personCount: 1,
              persons: [
                _makePerson(
                  trackId: 99,
                  fallScore: 0.92,
                  motionlessMs: 2000,
                ),
              ],
            ),
          ],
        ),
      );

      final incidents = await repo.listIncidents();
      expect(incidents.isEmpty, isTrue); // Must not trigger because ruleA is strictly for Cam Alpha!
    });

    test('5. Disabled Rule Check: disabled rules do not generate incidents', () async {
      final cam = await repo.saveCamera(_makeCamera(workspaceId: 1, name: 'Cam Gamma'));

      final rule = await repo.saveRule(
        RuleSpec(
          workspaceId: 1,
          name: 'Disabled Alert',
          enabled: false, // Disabled!
          cameraIds: [cam.id!],
          trigger: RuleTrigger(signal: 'person_count', minCount: 1, minDurationSec: 0, minConfidence: 0.6),
          conditions: RuleConditions(timeWindows: [], daysOfWeek: [], timezone: 'UTC'),
          severity: 'low',
          verify: RuleVerify(enabled: false, kind: 'none'),
          actions: [RuleAction(kind: 'notify', paramsJson: '{}')],
          cooldownSec: 30,
          escalation: [RuleEscalation(afterSec: 30, notify: 'security', message: 'Count')],
          sourceText: 'count alert',
          parsedBy: 'test',
          createdAt: DateTime.now(),
          version: 1,
        ),
      );
      expect(rule.enabled, isFalse);

      // Send matching telemetry
      await repo.sendSignals(
        SignalBatch(
          sentAtMs: DateTime.now().millisecondsSinceEpoch,
          seq: 1,
          cameraId: cam.id!,
          signals: [
            SignalEvent(
              tsMs: DateTime.now().millisecondsSinceEpoch,
              kind: 'telemetry',
              personCount: 1,
              persons: [
                _makePerson(trackId: 1),
              ],
            ),
          ],
        ),
      );

      final incidents = await repo.listIncidents();
      expect(incidents.isEmpty, isTrue);
    });

    test('6. Deduplication & Cooldown: Sustained condition creates only 1 incident during 30s window', () async {
      final cam = await repo.saveCamera(_makeCamera(workspaceId: 1, name: 'Cam Delta'));
      await repo.saveRule(
        RuleSpec(
          workspaceId: 1,
          name: 'Fall Protection',
          enabled: true,
          cameraIds: [cam.id!],
          trigger: RuleTrigger(signal: 'fall_suspected', minDurationSec: 1, minConfidence: 0.6),
          conditions: RuleConditions(timeWindows: [], daysOfWeek: [], timezone: 'UTC'),
          severity: 'critical',
          verify: RuleVerify(enabled: false, kind: 'none'),
          actions: [RuleAction(kind: 'notify', paramsJson: '{}')],
          cooldownSec: 30,
          escalation: [RuleEscalation(afterSec: 30, notify: 'security', message: 'Fall')],
          sourceText: 'fall alert',
          parsedBy: 'test',
          createdAt: DateTime.now(),
          version: 1,
        ),
      );

      // Send 5 consecutive frames over 5 seconds simulating sustained fallen subject
      for (int i = 1; i <= 5; i++) {
        await repo.sendSignals(
          SignalBatch(
            sentAtMs: DateTime.now().millisecondsSinceEpoch,
            seq: i,
            cameraId: cam.id!,
            signals: [
              SignalEvent(
                tsMs: DateTime.now().millisecondsSinceEpoch,
                kind: 'telemetry',
                personCount: 1,
                persons: [
                  _makePerson(
                    trackId: 10,
                    fallScore: 0.90,
                    motionlessMs: i * 1000,
                  ),
                ],
              ),
            ],
          ),
        );
      }

      final incidents = await repo.listIncidents();
      // Exactly 1 incident should be registered, not 5 duplicates!
      expect(incidents.length, equals(1));
    });

    test('7. Guard Security Isolation: Guard cannot see admin codes or edit facility', () async {
      final org = await repo.signUp('Headmaster Albus', 'hogwartsMaster');
      final fac = await repo.createFacility(
        'Main Academy Campus',
        creatorName: org.fullName,
      );

      // Join as Guard with guardCode
      final guard = await repo.signUp('Guard Argus', 'filchPass');
      final joinedFac = await repo.joinFacility(
        fac.guardCode,
        userName: guard.fullName,
      );

      expect(joinedFac, isNotNull);
      // Sensitive organizer and supervisor codes must be concealed
      expect(joinedFac!.organizerCode, isEmpty);
      expect(joinedFac.supervisorCode, isEmpty);
      expect(joinedFac.guardCode, isEmpty);

      // Guards cannot delete or modify facility
      expect(
        () => repo.deleteFacility(fac.id!, userName: guard.fullName),
        throwsA(isA<StateError>()),
      );
      expect(
        () => repo.updateFacility(fac.id!, userName: guard.fullName, name: 'Hacked Facility'),
        throwsA(isA<StateError>()),
      );
    });
  });
}
