import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:argus_client/argus_client.dart';
import 'argus_repository.dart';
import 'mock/mock_argus_repository.dart';
import 'remote/remote_argus_repository.dart';

/// Provider for Serverpod Client connecting to backend API & WebSocket
final serverpodClientProvider = Provider<Client>((ref) {
  return Client(
    'http://localhost:8080/',
  );
});

/// Toggle between Production Live Serverpod Backend and Local Mock
final useMockOverrideProvider = StateProvider<bool>((ref) => false);

/// Production ArgusRepository provider
final argusRepositoryProvider = Provider<ArgusRepository>((ref) {
  final useMock = ref.watch(useMockOverrideProvider);
  if (useMock) {
    return MockArgusRepository();
  }
  final client = ref.watch(serverpodClientProvider);
  return RemoteArgusRepository(client);
});

final isMockModeProvider = Provider<bool>((ref) {
  final repo = ref.watch(argusRepositoryProvider);
  return repo is MockArgusRepository;
});

/// In-memory cache for static first-frames of video cameras (keyed by cameraId)
final cameraStaticFrameProvider = StateProvider<Map<int, String>>((ref) => {});
