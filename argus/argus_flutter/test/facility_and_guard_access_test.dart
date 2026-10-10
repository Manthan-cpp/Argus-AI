import 'package:flutter_test/flutter_test.dart';
import 'package:argus_client/argus_client.dart';
import 'package:argus_flutter/data/mock/mock_argus_repository.dart';

void main() {
  group('Enterprise Facility & Role-Based Dispatch Lifecycle', () {
    late MockArgusRepository repo;

    setUp(() async {
      repo = MockArgusRepository();
      await repo.resetAllData();
    });

    test('1. Facility creation starts with 0 rooms; Organizer creates camera-bound room', () async {
      final facility = await repo.createFacility(
        'St. Thomas School',
        description: 'Comprehensive K-12 campus safety deployment',
        creatorName: 'Manthan',
      );

      expect(facility.name, equals('St. Thomas School'));
      expect(facility.organizerCode, startsWith('ORG-'));
      expect(facility.supervisorCode, startsWith('SUP-'));
      expect(facility.guardCode, startsWith('GRD-'));

      // New facility starts with 0 rooms
      final initialRooms = await repo.listRooms(workspaceId: facility.id, userName: 'Manthan');
      expect(initialRooms, isEmpty);

      // Organizer creates a tactical dispatch room
      final room = await repo.createRoom(
        'St. Thomas Main Hall',
        description: 'Patrol for main entrance and foyer',
        cameraIds: [1],
        workspaceId: facility.id,
        creatorName: 'Manthan',
        creatorRole: 'organizer',
      );

      expect(room.name, equals('St. Thomas Main Hall'));
      expect(room.createdByName, equals('Manthan'));
      expect(room.cameraIds, contains(1));

      // Creator has full visibility of invite codes
      expect(room.organizerCode, isNotEmpty);
      expect(room.supervisorCode, isNotEmpty);
      expect(room.guardCode, isNotEmpty);

      // Room is now in facility listing
      final updatedRooms = await repo.listRooms(workspaceId: facility.id, userName: 'Manthan');
      expect(updatedRooms.length, equals(1));
      expect(updatedRooms.first.name, equals('St. Thomas Main Hall'));
    });

    test('2. Joining with Supervisor code grants operational control & room creation', () async {
      final facility = await repo.createFacility(
        'St. Thomas School',
        creatorName: 'Manthan',
      );

      // Second user joins using the Supervisor code
      final supFacility = await repo.joinFacility(
        facility.supervisorCode,
        userName: 'Supervisor_Alice',
      );

      expect(supFacility, isNotNull);
      // Supervisor sees SUP and GRD codes, but ORG code is concealed
      expect(supFacility!.supervisorCode, equals(facility.supervisorCode));
      expect(supFacility.guardCode, equals(facility.guardCode));
      expect(supFacility.organizerCode, isEmpty);

      // Supervisor can create rooms in the facility
      final supRoom = await repo.createRoom(
        'ICU Safety Corridor',
        description: 'ICU monitoring group',
        cameraIds: [2],
        workspaceId: facility.id,
        creatorName: 'Supervisor_Alice',
        creatorRole: 'supervisor',
      );
      expect(supRoom.name, equals('ICU Safety Corridor'));

      // Supervisor can see all rooms in the facility
      final facilityRooms = await repo.listRooms(workspaceId: facility.id, userName: 'Supervisor_Alice');
      expect(facilityRooms.length, equals(1));
      expect(facilityRooms.first.supervisorCode, isNotNull);
      expect(facilityRooms.first.organizerCode, isNull); // ORG code concealed from supervisor

      // Supervisor can attach a new camera
      final cam = await repo.saveCamera(
        Camera(
          workspaceId: facility.id!,
          name: 'Main Gate CCTV',
          sourceKind: 'file',
          sourceRef: 'demo_s1_lab_entry.mp4',
          enabled: true,
          createdAt: DateTime.now(),
          status: 'online',
        ),
        workspaceId: facility.id!,
      );
      expect(cam.id, isNotNull);

      final facilityCams = await repo.listCameras(workspaceId: facility.id);
      expect(facilityCams.any((c) => c.name == 'Main Gate CCTV'), isTrue);
    });

    test('3. Joining with Guard code restricts invite codes and editing capabilities', () async {
      final facility = await repo.createFacility(
        'St. Thomas School',
        creatorName: 'Manthan',
      );

      // Organizer creates a room
      final room = await repo.createRoom(
        'Perimeter Patrol',
        workspaceId: facility.id,
        creatorName: 'Manthan',
        creatorRole: 'organizer',
      );

      // Third user joins facility using the Guard code
      final guardFacility = await repo.joinFacility(
        facility.guardCode,
        userName: 'Officer_Bob',
      );

      expect(guardFacility, isNotNull);
      // Guard has all share codes completely concealed
      expect(guardFacility!.organizerCode, isEmpty);
      expect(guardFacility.supervisorCode, isEmpty);
      expect(guardFacility.guardCode, isEmpty);

      // Guard sees all rooms in their facility
      final guardRooms = await repo.listRooms(workspaceId: facility.id, userName: 'Officer_Bob');
      expect(guardRooms.length, equals(1));
      expect(guardRooms.first.organizerCode, isNull);
      expect(guardRooms.first.supervisorCode, isNull);
      expect(guardRooms.first.guardCode, isNull);

      // Guard attempting to edit room throws permission error
      expect(
        repo.updateRoom(
          room.id!,
          userName: 'Officer_Bob',
          name: 'Compromised Name',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('4. Chat message tags sender accurately as ORGANIZER, SUPERVISOR, or GUARD', () async {
      final facility = await repo.createFacility('Oakridge Academy', creatorName: 'Admin_Sarah');
      await repo.joinFacility(facility.supervisorCode, userName: 'Sup_David');
      await repo.joinFacility(facility.guardCode, userName: 'Guard_Jack');

      final room = await repo.createRoom(
        'Oakridge Tactical Room',
        workspaceId: facility.id,
        creatorName: 'Admin_Sarah',
        creatorRole: 'organizer',
      );

      // Messages sent by each role
      final msg1 = await repo.sendRoomMessage(
        room.id!,
        'Perimeter status normal',
        senderName: 'Guard_Jack',
        senderRole: 'guard',
      );
      expect(msg1.senderRole, equals('guard'));

      final msg2 = await repo.sendRoomMessage(
        room.id!,
        'Acknowledged, maintain sweep',
        senderName: 'Sup_David',
        senderRole: 'supervisor',
      );
      expect(msg2.senderRole, equals('supervisor'));

      final msg3 = await repo.sendRoomMessage(
        room.id!,
        'Dispatch log verified',
        senderName: 'Admin_Sarah',
        senderRole: 'organizer',
      );
      expect(msg3.senderRole, equals('organizer'));

      final allMsgs = await repo.listRoomMessages(room.id!);
      expect(allMsgs.any((m) => m.senderName == 'Guard_Jack' && m.senderRole == 'guard'), isTrue);
      expect(allMsgs.any((m) => m.senderName == 'Sup_David' && m.senderRole == 'supervisor'), isTrue);
      expect(allMsgs.any((m) => m.senderName == 'Admin_Sarah' && m.senderRole == 'organizer'), isTrue);
    });

    test('5. Multi-facility isolation: user only sees their own facilities and cameras', () async {
      // User 1 creates Facility A
      final facA = await repo.createFacility('Alpha Compound', creatorName: 'User_1');
      await repo.saveCamera(
        Camera(
          workspaceId: facA.id!,
          name: 'Alpha Cam 1',
          sourceKind: 'webcam',
          sourceRef: 'local',
          enabled: true,
          createdAt: DateTime.now(),
          status: 'online',
        ),
        workspaceId: facA.id!,
      );

      // User 2 creates Facility B
      final facB = await repo.createFacility('Bravo Base', creatorName: 'User_2');
      await repo.saveCamera(
        Camera(
          workspaceId: facB.id!,
          name: 'Bravo Cam 1',
          sourceKind: 'webcam',
          sourceRef: 'local',
          enabled: true,
          createdAt: DateTime.now(),
          status: 'online',
        ),
        workspaceId: facB.id!,
      );

      // User 1's facilities list only contains Alpha
      final user1Facilities = await repo.listFacilities(userName: 'User_1');
      expect(user1Facilities.length, equals(1));
      expect(user1Facilities.first.name, equals('Alpha Compound'));

      // User 2's facilities list only contains Bravo
      final user2Facilities = await repo.listFacilities(userName: 'User_2');
      expect(user2Facilities.length, equals(1));
      expect(user2Facilities.first.name, equals('Bravo Base'));

      // Camera lists are isolated by workspaceId
      final alphaCams = await repo.listCameras(workspaceId: facA.id!);
      expect(alphaCams.length, equals(1));
      expect(alphaCams.first.name, equals('Alpha Cam 1'));

      final bravoCams = await repo.listCameras(workspaceId: facB.id!);
      expect(bravoCams.length, equals(1));
      expect(bravoCams.first.name, equals('Bravo Cam 1'));
    });

    test('6. Alert routing only sends alerts to rooms linked to the triggered camera', () async {
      final facility = await repo.createFacility('Metro Hospital', creatorName: 'Chief_Dr');

      // Create Camera 101 and Camera 102
      final cam1 = await repo.saveCamera(
        Camera(
          workspaceId: facility.id!,
          name: 'ICU Ward Cam',
          sourceKind: 'file',
          sourceRef: 'demo_s1_lab_entry.mp4',
          enabled: true,
          createdAt: DateTime.now(),
          status: 'online',
        ),
        workspaceId: facility.id!,
      );
      final cam2 = await repo.saveCamera(
        Camera(
          workspaceId: facility.id!,
          name: 'Main Parking Cam',
          sourceKind: 'file',
          sourceRef: 'demo_s2_fall.mp4',
          enabled: true,
          createdAt: DateTime.now(),
          status: 'online',
        ),
        workspaceId: facility.id!,
      );

      // Room A attached to Camera 1 (ICU)
      final roomA = await repo.createRoom(
        'ICU Dispatch Room',
        cameraIds: [cam1.id!],
        workspaceId: facility.id,
        creatorName: 'Chief_Dr',
        creatorRole: 'organizer',
      );

      // Room B attached to Camera 2 (Parking)
      final roomB = await repo.createRoom(
        'Parking Dispatch Room',
        cameraIds: [cam2.id!],
        workspaceId: facility.id,
        creatorName: 'Chief_Dr',
        creatorRole: 'organizer',
      );

      // Rule created on Camera 1 (ICU)
      await repo.saveRule(RuleSpec(
        id: 1,
        workspaceId: facility.id!,
        name: 'Restricted ICU Entry',
        enabled: true,
        cameraIds: [cam1.id!],
        trigger: RuleTrigger(
          signal: 'person_in_zone',
          zoneId: 1,
          minDurationSec: 0,
          minConfidence: 0.8,
        ),
        conditions: RuleConditions(
          timeWindows: [],
          daysOfWeek: [],
          timezone: 'UTC',
        ),
        severity: 'critical',
        verify: RuleVerify(enabled: false, kind: 'none'),
        actions: [],
        cooldownSec: 0,
        escalation: [],
        sourceText: 'Alert when person in restricted zone',
        parsedBy: 'mock',
        createdAt: DateTime.now(),
        version: 1,
      ));

      // Trigger telemetry on Camera 1 (ICU)
      await repo.sendSignals(SignalBatch(
        cameraId: cam1.id!,
        sentAtMs: DateTime.now().millisecondsSinceEpoch,
        seq: 1,
        signals: [
          SignalEvent(
            tsMs: DateTime.now().millisecondsSinceEpoch,
            kind: 'person_tracking',
            personCount: 1,
            persons: [
              PersonSignal(
                trackId: 10,
                bboxN: BBoxN(x: 0.1, y: 0.1, w: 0.4, h: 0.4),
                footN: PointN(x: 0.3, y: 0.5),
                zoneIds: [1],
                aspect: 0.5,
                motionScore: 0.5,
                fallScore: 0.1,
                motionlessMs: 0,
                confidence: 0.95,
              ),
            ],
          ),
        ],
      ));

      // Alert should be posted to Room A (ICU), but NOT Room B (Parking)
      final msgsA = await repo.listRoomMessages(roomA.id!);
      final msgsB = await repo.listRoomMessages(roomB.id!);

      expect(msgsA.any((m) => m.kind == 'system_alert' && m.content.contains('ICU Ward Cam')), isTrue);
      expect(msgsB.any((m) => m.kind == 'system_alert'), isFalse);
    });
  });
}
