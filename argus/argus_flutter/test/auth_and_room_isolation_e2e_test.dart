// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:argus_client/argus_client.dart';

void main() {
  test('Production Auth, Room Multi-Tenant Isolation, Role Tags & Guard Concealment E2E Verification', () async {
    final client = Client('http://127.0.0.1:8080/');

    // 1. Reset database to pure clean slate
    print('Step 1: Resetting database to clean state...');
    final resetSuccess = await client.user.resetData();
    expect(resetSuccess, isTrue);

    // 2. Unauthenticated user listing rooms -> must be empty
    print('Step 2: Checking unauthenticated room listing...');
    final unauthRooms = await client.room.listRooms();
    expect(unauthRooms, isEmpty);

    final emptyNameRooms = await client.room.listRooms(userName: '');
    expect(emptyNameRooms, isEmpty);

    // 3. User A signs up
    print('Step 3: User A (Alice) signs up...');
    final userA = await client.user.signUp('Alice', 'password123');
    expect(userA.fullName, equals('Alice'));

    // User A has 0 rooms initially
    final aliceInitialRooms = await client.room.listRooms(userName: 'Alice');
    expect(aliceInitialRooms, isEmpty);

    // 4. User A creates room as organizer
    print('Step 4: User A creates room "HQ Command Center" as organizer...');
    final roomA = await client.room.createRoom(
      'HQ Command Center',
      creatorName: 'Alice',
      creatorRole: 'organizer',
    );
    expect(roomA.id, isNotNull);
    expect(roomA.organizerCode, startsWith('ORG-'));
    expect(roomA.supervisorCode, startsWith('SUP-'));
    expect(roomA.guardCode, startsWith('GRD-'));

    // Alice now sees 1 room with visible codes
    final aliceRooms = await client.room.listRooms(userName: 'Alice');
    expect(aliceRooms.length, equals(1));
    expect(aliceRooms.first.name, equals('HQ Command Center'));
    expect(aliceRooms.first.organizerCode, isNotNull);
    expect(aliceRooms.first.supervisorCode, isNotNull);
    expect(aliceRooms.first.guardCode, isNotNull);

    // 5. User B signs up
    print('Step 5: User B (Bob) signs up...');
    final userB = await client.user.signUp('Bob', 'bobpassword');
    expect(userB.fullName, equals('Bob'));

    // Multi-tenant room isolation for Bob
    print('Step 5b: Verifying multi-tenant room isolation for Bob...');
    final bobInitialRooms = await client.room.listRooms(userName: 'Bob');
    expect(bobInitialRooms, isEmpty, reason: "Bob should not see Alice's room before joining!");

    // 6. User B joins room via Guard Code
    print('Step 6: User B joins room using Guard code: ${roomA.guardCode}...');
    final joinedRoom = await client.room.joinRoom(
      roomA.guardCode!,
      userName: 'Bob',
    );
    expect(joinedRoom, isNotNull);

    // 7. User C (Charlie) signs up and joins as Supervisor
    print('Step 7: User C (Charlie) signs up and joins as Supervisor...');
    final userC = await client.user.signUp('Charlie', 'charliepass');
    expect(userC.fullName, equals('Charlie'));
    final charlieJoined = await client.room.joinRoom(
      roomA.supervisorCode!,
      userName: 'Charlie',
    );
    expect(charlieJoined, isNotNull);

    // Verify all 3 memberships and roles
    final members = await client.room.listMembers(roomA.id!);
    expect(members.length, equals(3));
    final bobMember = members.firstWhere((m) => m.userName == 'Bob');
    expect(bobMember.userRole, equals('guard'));

    final aliceMember = members.firstWhere((m) => m.userName == 'Alice');
    expect(aliceMember.userRole, equals('organizer'));

    final charlieMember = members.firstWhere((m) => m.userName == 'Charlie');
    expect(charlieMember.userRole, equals('supervisor'));

    // 8. Security & Code Concealment for Guards
    print('Step 8: Verifying code concealment for Guards...');
    final bobRooms = await client.room.listRooms(userName: 'Bob');
    expect(bobRooms.length, equals(1));
    final bobRoomView = bobRooms.first;
    expect(bobRoomView.organizerCode, isNull, reason: 'Guard must not see organizer code');
    expect(bobRoomView.supervisorCode, isNull, reason: 'Guard must not see supervisor code');
    expect(bobRoomView.code, equals(bobRoomView.id.toString()));

    // Verify Guard can re-load room by ID and by code seamlessly
    final reloadedById = await client.room.getRoom(bobRoomView.id!, userName: 'Bob');
    expect(reloadedById, isNotNull);
    expect(reloadedById!.name, equals(roomA.name));
    expect(reloadedById.organizerCode, isNull, reason: 'Guard must not see organizer code on reload');

    final reloadedByCode = await client.room.getRoomByCode(bobRoomView.code);
    expect(reloadedByCode, isNotNull);
    expect(reloadedByCode!.id, equals(bobRoomView.id));

    // Supervisor Charlie CANNOT see organizer code, but CAN see supervisor and guard codes
    final charlieRooms = await client.room.listRooms(userName: 'Charlie');
    expect(charlieRooms.first.organizerCode, isNull, reason: 'Supervisor must not see organizer code');
    expect(charlieRooms.first.supervisorCode, isNotNull);
    expect(charlieRooms.first.guardCode, isNotNull);

    // 9. Message Role Tag Integrity
    print('Step 9: Testing chat messages with role tags...');
    final msgAlice = await client.roomMessage.sendMessage(
      roomA.id!,
      'Hello from organizer Alice',
      senderName: 'Alice',
    );
    expect(msgAlice.senderRole, equals('organizer'));

    final msgBob = await client.roomMessage.sendMessage(
      roomA.id!,
      'Guard Bob reporting for duty',
      senderName: 'Bob',
    );
    expect(msgBob.senderRole, equals('guard'));

    final msgCharlie = await client.roomMessage.sendMessage(
      roomA.id!,
      'Supervisor Charlie on command deck',
      senderName: 'Charlie',
    );
    expect(msgCharlie.senderRole, equals('supervisor'));

    // 10. Room Editing Permissions
    print('Step 10: Testing room editing by Organizer and Supervisor...');
    final updatedByAlice = await client.room.updateRoom(
      roomA.id!,
      userName: 'Alice',
      name: 'Alpha Command Center',
      description: 'Primary operations tactical room',
    );
    expect(updatedByAlice.name, equals('Alpha Command Center'));
    expect(updatedByAlice.description, equals('Primary operations tactical room'));

    final updatedByCharlie = await client.room.updateRoom(
      roomA.id!,
      userName: 'Charlie',
      description: 'Supervised tactical operations channel',
    );
    expect(updatedByCharlie.description, equals('Supervised tactical operations channel'));

    // Guard Bob cannot edit room
    print('Step 10b: Verifying Guard Bob is rejected from editing room...');
    expect(
      () => client.room.updateRoom(roomA.id!, userName: 'Bob', name: 'Unauthorized rename'),
      throwsA(isA<ServerpodClientException>()),
    );

    // Guard Bob cannot delete room
    print('Step 10c: Verifying Guard Bob is rejected from deleting room...');
    expect(
      () => client.room.deleteRoom(roomA.id!, userName: 'Bob'),
      throwsA(isA<ServerpodClientException>()),
    );

    // 11. Organizer Alice deletes room
    print('Step 11: Organizer Alice deletes room...');
    final deleted = await client.room.deleteRoom(roomA.id!, userName: 'Alice');
    expect(deleted, isTrue);

    // After deletion, room is gone for all users
    final aliceRoomsAfterDelete = await client.room.listRooms(userName: 'Alice');
    expect(aliceRoomsAfterDelete, isEmpty);

    final bobRoomsAfterDelete = await client.room.listRooms(userName: 'Bob');
    expect(bobRoomsAfterDelete, isEmpty);

    final charlieRoomsAfterDelete = await client.room.listRooms(userName: 'Charlie');
    expect(charlieRoomsAfterDelete, isEmpty);

    // 12. Final database cleanup
    print('Step 12: Final database cleanup...');
    await client.user.resetData();

    print('ALL AUTH, ROOM ISOLATION, ROLE TAGS & GUARD CONCEALMENT TESTS PASSED CLEANLY!');
  });
}
