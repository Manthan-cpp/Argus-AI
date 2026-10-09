import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:argus_client/argus_client.dart';
import '../../data/repository_provider.dart';

class CurrentUserNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  final Ref ref;

  CurrentUserNotifier(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    try {
      final repo = ref.read(argusRepositoryProvider);
      final user = await repo.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<UserProfile> login(String fullName, String role, {String? email}) async {
    final repo = ref.read(argusRepositoryProvider);
    final user = await repo.login(fullName, role, email: email);
    state = AsyncValue.data(user);
    return user;
  }
}

final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, AsyncValue<UserProfile>>((ref) {
  return CurrentUserNotifier(ref);
});

final roomsListProvider = FutureProvider<List<DispatchRoom>>((ref) async {
  final repo = ref.watch(argusRepositoryProvider);
  return await repo.listRooms();
});

final activeRoomProvider = StateProvider<DispatchRoom?>((ref) => null);

final roomMembersProvider =
    FutureProvider.family<List<RoomMember>, int>((ref, roomId) async {
  final repo = ref.watch(argusRepositoryProvider);
  return await repo.listRoomMembers(roomId);
});

class RoomMessagesNotifier extends StateNotifier<AsyncValue<List<RoomMessage>>> {
  final Ref ref;
  final int roomId;
  StreamSubscription<RoomMessage>? _sub;

  RoomMessagesNotifier(this.ref, this.roomId) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final repo = ref.read(argusRepositoryProvider);
      final initial = await repo.listRoomMessages(roomId);
      state = AsyncValue.data(initial);

      _sub = repo.watchRoomMessages(roomId).listen((newMsg) {
        final current = state.valueOrNull ?? [];
        final alreadyPresent = newMsg.id != null && current.any((m) => m.id == newMsg.id);
        if (!alreadyPresent) {
          state = AsyncValue.data([...current, newMsg]);
        }
      });
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<RoomMessage> sendMessage(
    String content, {
    String? senderName,
    String? senderRole,
    int? senderId,
  }) async {
    final repo = ref.read(argusRepositoryProvider);
    final msg = await repo.sendRoomMessage(
      roomId,
      content,
      senderName: senderName,
      senderRole: senderRole,
      senderId: senderId,
    );
    final current = state.valueOrNull ?? [];
    if (!current.any((m) => m.id != null && m.id == msg.id)) {
      state = AsyncValue.data([...current, msg]);
    }
    return msg;
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final roomMessagesProvider = StateNotifierProvider.family<
    RoomMessagesNotifier,
    AsyncValue<List<RoomMessage>>,
    int>((ref, roomId) {
  return RoomMessagesNotifier(ref, roomId);
});
