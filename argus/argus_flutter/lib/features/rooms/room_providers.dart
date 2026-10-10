import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:argus_client/argus_client.dart';
import '../../core/storage/web_storage.dart' as storage;
import '../../data/repository_provider.dart';

class CurrentUserNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final Ref ref;

  CurrentUserNotifier(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  String? _getStoredUserName() {
    return storage.getStorageItem('argus_user_name');
  }

  void _setStoredUserName(String? name) {
    storage.setStorageItem('argus_user_name', name?.trim());
  }

  Future<void> load() async {
    try {
      final repo = ref.read(argusRepositoryProvider);
      final storedName = _getStoredUserName();
      final user = await repo.getCurrentUser(fullName: storedName);
      state = AsyncValue.data(user);
    } catch (_) {
      state = const AsyncValue.data(null);
    }
  }

  Future<UserProfile> signUp(String fullName, String password) async {
    final repo = ref.read(argusRepositoryProvider);
    final user = await repo.signUp(fullName, password);
    _setStoredUserName(user.fullName);
    state = AsyncValue.data(user);
    return user;
  }

  Future<UserProfile> login(String fullName, String password) async {
    final repo = ref.read(argusRepositoryProvider);
    final user = await repo.login(fullName, password);
    _setStoredUserName(user.fullName);
    state = AsyncValue.data(user);
    return user;
  }

  Future<void> logout() async {
    _setStoredUserName(null);
    state = const AsyncValue.data(null);
    ref.invalidate(roomsListProvider);
    ref.invalidate(activeRoomProvider);
  }
}

final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, AsyncValue<UserProfile?>>((ref) {
  return CurrentUserNotifier(ref);
});

final roomsListProvider = FutureProvider<List<DispatchRoom>>((ref) async {
  final userAsync = ref.watch(currentUserProvider);
  final user = userAsync.valueOrNull;
  if (user == null) {
    return <DispatchRoom>[];
  }
  final repo = ref.watch(argusRepositoryProvider);
  return await repo.listRooms(userName: user.fullName);
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
