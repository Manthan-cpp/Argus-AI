import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:argus_client/argus_client.dart';
import 'package:argus_flutter/data/mock/mock_argus_repository.dart';

void main() {
  group('Incident Deduplication and Facility Scoping Verification', () {
    late MockArgusRepository repo;

    setUp(() async {
      repo = MockArgusRepository();
      await repo.resetAllData();
    });

    test('Sustained fall over 8 seconds triggers EXACTLY 1 incident and 1 room alert', () async {
      // 1. Create a Facility "St. Thomas School"
      final facility = await repo.createFacility(
        'St. Thomas School',
        description: 'Campus security prototype',
        creatorName: 'Manthan',
      );
      expect(facility.id, isNotNull);

      // 2. Add camera in facility
      final camera = await repo.saveCamera(
        Camera(
          name: 'Stairwell Camera A',
          sourceKind: 'video_file',
          sourceRef: 'campus_stairs.mp4',
          enabled: true,
          createdAt: DateTime.now(),
          status: 'online',
          workspaceId: facility.id!,
        ),
        workspaceId: facility.id,
      );
      expect(camera.id, isNotNull);

      // 3. Create a Dispatch Room in facility monitoring this camera
      final room = await repo.createRoom(
        'Security Dispatch 1',
        cameraIds: [camera.id!],
        workspaceId: facility.id,
        creatorName: 'Manthan',
        creatorRole: 'organizer',
      );
      expect(room.id, isNotNull);

      // 4. Save Rule: Person falls and stays down for more than 2 seconds (minDurationSec: 2)
      final rule = await repo.saveRule(
        RuleSpec(
          workspaceId: facility.id!,
          name: 'Sustained Fall Down',
          enabled: true,
          cameraIds: [camera.id!],
          trigger: RuleTrigger(
            signal: 'fall_suspected',
            minDurationSec: 2, // 2 seconds
            minConfidence: 0.6,
          ),
          conditions: RuleConditions(timeWindows: [], daysOfWeek: [], timezone: 'UTC'),
          severity: 'critical',
          verify: RuleVerify(enabled: false, kind: 'none'),
          actions: [RuleAction(kind: 'notify', paramsJson: '{}')],
          cooldownSec: 30,
          escalation: [RuleEscalation(afterSec: 30, notify: 'security', message: 'Fall unacknowledged')],
          sourceText: 'if a person falls and stays down for more than 2 seconds alert',
          parsedBy: 'test',
          createdAt: DateTime.now(),
          version: 1,
        ),
      );
      expect(rule.id, isNotNull);

      // Watch room messages
      final receivedMessages = <RoomMessage>[];
      final sub = repo.watchRoomMessages(room.id!).listen((m) {
        if (m.kind == 'system_alert') {
          receivedMessages.add(m);
        }
      });

      // Track live incident stream
      final streamedIncidents = <IncidentUpdate>[];
      final incSub = repo.watchIncidents().listen((u) {
        streamedIncidents.add(u);
      });

      // Helper function to build telemetry batch for a given motionless duration
      SignalBatch makeBatch(int motionlessMs) {
        return SignalBatch(
          cameraId: camera.id!,
          sentAtMs: DateTime.now().millisecondsSinceEpoch,
          seq: 1,
          signals: [
            SignalEvent(
              tsMs: DateTime.now().millisecondsSinceEpoch,
              kind: 'fall',
              personCount: 1,
              persons: [
                PersonSignal(
                  trackId: 101,
                  bboxN: BBoxN(x: 0.3, y: 0.6, w: 0.4, h: 0.2),
                  footN: PointN(x: 0.5, y: 0.7),
                  aspect: 0.5,
                  motionScore: 0.1,
                  fallScore: 0.92, // Clear fall
                  motionlessMs: motionlessMs,
                  confidence: 0.95,
                  zoneIds: [],
                ),
              ],
            ),
          ],
        );
      }

      // Second 1 (1000ms): Less than 2 seconds threshold -> condition NOT met yet
      await repo.sendSignals(makeBatch(1000));
      var incidents = await repo.listIncidents(workspaceId: facility.id);
      expect(incidents.length, equals(0), reason: 'Should not trigger before 2s threshold');

      // Second 2 (2000ms): Threshold REACHED -> First trigger fires!
      await repo.sendSignals(makeBatch(2000));
      incidents = await repo.listIncidents(workspaceId: facility.id);
      expect(incidents.length, equals(1), reason: 'First incident must open at 2s threshold');
      expect(incidents.first.status, equals('open'));
      expect(incidents.first.severity, equals('critical'));

      // Check room chat alerts
      var roomAlerts = (await repo.listRoomMessages(room.id!))
          .where((m) => m.kind == 'system_alert')
          .toList();
      expect(roomAlerts.length, equals(1), reason: 'Exactly 1 alert message in room chat');

      // Seconds 3 through 8 (3000ms to 8000ms): Subject remains down and motionless
      // All subsequent seconds MUST be suppressed because the incident is actively open!
      for (int sec = 3; sec <= 8; sec++) {
        await repo.sendSignals(makeBatch(sec * 1000));
      }

      // VERIFY: Incidents count is STILL exactly 1! (NO duplicates)
      incidents = await repo.listIncidents(workspaceId: facility.id);
      expect(
        incidents.length,
        equals(1),
        reason: 'Zero duplicate incidents should be created during sustained fall!',
      );

      // VERIFY: Room chat alerts count is STILL exactly 1! (NO spam in room chat)
      roomAlerts = (await repo.listRoomMessages(room.id!))
          .where((m) => m.kind == 'system_alert')
          .toList();
      expect(
        roomAlerts.length,
        equals(1),
        reason: 'Zero duplicate room alert spam during sustained fall!',
      );

      // VERIFY: Incident shows up in Incidents Tab query
      final listedForFacility = await repo.listIncidents(workspaceId: facility.id);
      expect(listedForFacility.isNotEmpty, isTrue);
      expect(listedForFacility.first.workspaceId, equals(facility.id));
      expect(listedForFacility.first.summary, contains('Sustained Fall Down'));

      // VERIFY: Incident does NOT leak to another facility
      final listedOtherFacility = await repo.listIncidents(workspaceId: 999);
      expect(listedOtherFacility, isEmpty);

      // Clean up subscriptions
      await sub.cancel();
      await incSub.cancel();
    });

    test('Acknowledging an incident respects cooldown period before re-triggering', () async {
      final facility = await repo.createFacility(
        'Metro Hospital',
        creatorName: 'Doctor Alice',
      );
      final camera = await repo.saveCamera(
        Camera(
          name: 'Hallway Camera',
          sourceKind: 'video_file',
          sourceRef: 'hallway.mp4',
          enabled: true,
          createdAt: DateTime.now(),
          status: 'online',
          workspaceId: facility.id!,
        ),
        workspaceId: facility.id,
      );
      final room = await repo.createRoom(
        'Hospital Dispatch',
        cameraIds: [camera.id!],
        workspaceId: facility.id,
        creatorName: 'Doctor Alice',
        creatorRole: 'organizer',
      );

      final rule = await repo.saveRule(
        RuleSpec(
          workspaceId: facility.id!,
          name: 'Patient Fall',
          enabled: true,
          cameraIds: [camera.id!],
          trigger: RuleTrigger(signal: 'fall_suspected', minDurationSec: 2, minConfidence: 0.6),
          conditions: RuleConditions(timeWindows: [], daysOfWeek: [], timezone: 'UTC'),
          severity: 'high',
          verify: RuleVerify(enabled: false, kind: 'none'),
          actions: [],
          cooldownSec: 10, // 10 second cooldown
          escalation: [],
          sourceText: 'patient fall alert',
          parsedBy: 'test',
          createdAt: DateTime.now(),
          version: 1,
        ),
      );

      SignalBatch makeBatch() {
        return SignalBatch(
          cameraId: camera.id!,
          sentAtMs: DateTime.now().millisecondsSinceEpoch,
          seq: 1,
          signals: [
            SignalEvent(
              tsMs: DateTime.now().millisecondsSinceEpoch,
              kind: 'fall',
              personCount: 1,
              persons: [
                PersonSignal(
                  trackId: 102,
                  bboxN: BBoxN(x: 0.1, y: 0.1, w: 0.5, h: 0.5),
                  footN: PointN(x: 0.3, y: 0.5),
                  aspect: 0.5,
                  motionScore: 0.1,
                  fallScore: 0.9,
                  motionlessMs: 2500,
                  confidence: 0.95,
                  zoneIds: [],
                ),
              ],
            ),
          ],
        );
      }

      // Trigger 1st incident
      await repo.sendSignals(makeBatch());
      var list = await repo.listIncidents(workspaceId: facility.id);
      expect(list.length, equals(1));
      final incId = list.first.id!;

      // Operator acknowledges
      final acked = await repo.acknowledge(incId, note: 'Nurse dispatched');
      expect(acked.status, equals('acknowledged'));

      // Signals arrive immediately after ack (within 10s cooldown) -> suppressed
      await repo.sendSignals(makeBatch());
      list = await repo.listIncidents(workspaceId: facility.id);
      expect(list.length, equals(1), reason: 'Should remain 1 incident during cooldown');

      final roomAlerts = (await repo.listRoomMessages(room.id!))
          .where((m) => m.kind == 'system_alert')
          .toList();
      expect(roomAlerts.length, equals(1), reason: 'No room spam during cooldown');
    });
  });
}
