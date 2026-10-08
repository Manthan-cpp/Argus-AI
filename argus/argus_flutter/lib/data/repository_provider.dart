import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'argus_repository.dart';
import 'mock/mock_argus_repository.dart';

/// Provider for ArgusRepository.
/// Phase 1 defaults to MockArgusRepository with visible MOCK DATA badge.
/// Phase 3 introduces RemoteArgusRepository.
final argusRepositoryProvider = Provider<ArgusRepository>((ref) {
  return MockArgusRepository();
});

final isMockModeProvider = Provider<bool>((ref) {
  final repo = ref.watch(argusRepositoryProvider);
  return repo is MockArgusRepository;
});
