import 'package:flutter_test/flutter_test.dart';
import 'package:argus_flutter/data/mock/mock_argus_repository.dart';

void main() {
  group('Guard Re-entry & Role Concealment Tests', () {
    late MockArgusRepository repo;

    setUp(() async {
      repo = MockArgusRepository();
      await repo.resetAllData();
    });

    test('Guard can re-enter room by ID or code without restricted error', () async {
      // 1. Organizer signs up and creates a room
      final organizer = await repo.signUp('Alice', 'pass123');
      final room = await repo.createRoom(
        'Perimeter Post Alpha',
        description: 'Guard surveillance outpost',
        creatorName: organizer.fullName,
        creatorRole: 'organizer',
      );

      expect(room.id, isNotNull);
      expect(room.organizerCode, isNotNull);
      expect(room.supervisorCode, isNotNull);
      expect(room.guardCode, isNotNull);
      final guardCode = room.guardCode!;

      // 2. Guard signs up and joins with guard code
      final guard = await repo.signUp('Bob', 'pass456');
      final joined = await repo.joinRoom(guardCode, userName: guard.fullName);
      expect(joined, isNotNull);

      // Verify memberships
      final members = await repo.listRoomMembers(room.id!);
      expect(members.length, equals(2));
      final bobMember = members.firstWhere((m) => m.userName == 'Bob');
      expect(bobMember.userRole, equals('guard'));

      // 3. Guard lists rooms
      final guardRooms = await repo.listRooms(userName: guard.fullName);
      expect(guardRooms.length, equals(1));
      final guardRoomView = guardRooms.first;

      // Codes must be concealed from Guard
      expect(guardRoomView.organizerCode, isNull);
      expect(guardRoomView.supervisorCode, isNull);
      expect(guardRoomView.guardCode, isNull);
      // Code must NOT be the broken 'RESTRICTED' literal string; must be room ID string
      expect(guardRoomView.code, equals(room.id.toString()));
      expect(guardRoomView.code, isNot(equals('RESTRICTED')));

      // 4. Guard re-enters room by numeric ID (what Enter Dispatch Room button executes)
      final reloadedById = await repo.getRoom(guardRoomView.id!, userName: guard.fullName);
      expect(reloadedById, isNotNull);
      expect(reloadedById!.name, equals('Perimeter Post Alpha'));
      expect(reloadedById.organizerCode, isNull);

      // 5. Guard re-enters room by code string (which is now room.id.toString())
      final reloadedByCode = await repo.getRoomByCode(guardRoomView.code);
      expect(reloadedByCode, isNotNull);
      expect(reloadedByCode!.id, equals(room.id));

      // 6. Looking up with original join code also succeeds
      final reloadedByJoinCode = await repo.getRoomByCode(guardCode);
      expect(reloadedByJoinCode, isNotNull);
      expect(reloadedByJoinCode!.id, equals(room.id));

      // 7. Guard sends message - role must be guard, not member
      final msg = await repo.sendRoomMessage(
        room.id!,
        'Reporting at East Gate',
        senderName: guard.fullName,
        senderRole: 'guard',
      );
      expect(msg.senderRole, equals('guard'));
    });
  });
}
