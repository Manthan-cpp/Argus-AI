import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:argus_client/argus_client.dart';
import '../../data/repository_provider.dart';
import '../rooms/room_providers.dart';

import '../../core/storage/web_storage.dart' as storage;

/// Storage synchronization listener for active facility
final _activeFacilityStorageSyncProvider = Provider<void>((ref) {
  ref.listen<Workspace?>(activeFacilityProvider, (previous, next) {
    if (next != null) {
      if (next.id != null) {
        storage.setStorageItem('argus_active_facility_id', next.id.toString());
      }
      try {
        storage.setStorageItem('argus_active_facility_json', jsonEncode(next.toJson()));
      } catch (_) {}
    } else {
      storage.removeStorageItem('argus_active_facility_id');
      storage.removeStorageItem('argus_active_facility_json');
    }
  });
});

/// Currently selected active Facility (Workspace) in the operational console.
final activeFacilityProvider = StateProvider<Workspace?>((ref) {
  try {
    final rawJson = storage.getStorageItem('argus_active_facility_json');
    if (rawJson != null && rawJson.isNotEmpty) {
      final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
      return Workspace.fromJson(decoded);
    }
  } catch (_) {}
  return null;
});

/// List of all Facilities the signed-in user belongs to.
final userFacilitiesProvider = FutureProvider<List<Workspace>>((ref) async {
  ref.watch(_activeFacilityStorageSyncProvider);
  final userAsync = ref.watch(currentUserProvider);
  var user = userAsync.valueOrNull;
  if (user == null && userAsync.isLoading) {
    user = await ref.read(currentUserProvider.notifier).ensureUser();
  }
  if (user == null) {
    return <Workspace>[];
  }
  final repo = ref.watch(argusRepositoryProvider);
  final facilities = await repo.listFacilities(userName: user.fullName);

  if (facilities.isNotEmpty) {
    final currentActive = ref.read(activeFacilityProvider);
    final storedIdStr = storage.getStorageItem('argus_active_facility_id');
    final storedId = storedIdStr != null ? int.tryParse(storedIdStr) : null;

    if (currentActive == null || !facilities.any((f) => f.id == currentActive.id)) {
      final match = storedId != null
          ? facilities.where((f) => f.id == storedId).firstOrNull
          : null;
      final selected = match ?? facilities.first;
      Future.microtask(() {
        ref.read(activeFacilityProvider.notifier).state = selected;
      });
    } else {
      final fresh = facilities.where((f) => f.id == currentActive.id).firstOrNull;
      if (fresh != null && fresh != currentActive) {
        Future.microtask(() {
          ref.read(activeFacilityProvider.notifier).state = fresh;
        });
      }
    }
  }

  return facilities;
});

/// Cameras available for dispatch routing and monitoring.
final activeFacilityCamerasProvider = FutureProvider<List<Camera>>((ref) async {
  final repo = ref.watch(argusRepositoryProvider);
  return await repo.listCameras();
});

/// Dedicated 1:1 Dispatch Room for the active facility (legacy/fallback).
final activeFacilityRoomProvider = FutureProvider<DispatchRoom?>((ref) async {
  ref.watch(_activeFacilityStorageSyncProvider);
  final facility = ref.watch(activeFacilityProvider);
  final userAsync = ref.watch(currentUserProvider);
  var user = userAsync.valueOrNull;
  if (facility == null || facility.id == null) {
    return null;
  }
  if (user == null && userAsync.isLoading) {
    user = await ref.read(currentUserProvider.notifier).ensureUser();
  }
  final repo = ref.watch(argusRepositoryProvider);
  return await repo.getRoomForFacility(facility.id!, userName: user?.fullName);
});

/// All Dispatch Rooms belonging to the active facility.
final activeFacilityRoomsProvider = FutureProvider<List<DispatchRoom>>((ref) async {
  ref.watch(_activeFacilityStorageSyncProvider);
  final facility = ref.watch(activeFacilityProvider);
  final userAsync = ref.watch(currentUserProvider);
  var user = userAsync.valueOrNull;
  if (facility == null || facility.id == null) {
    return <DispatchRoom>[];
  }
  if (user == null && userAsync.isLoading) {
    user = await ref.read(currentUserProvider.notifier).ensureUser();
  }
  if (user == null) {
    return <DispatchRoom>[];
  }
  final repo = ref.watch(argusRepositoryProvider);
  return await repo.listRooms(workspaceId: facility.id, userName: user.fullName);
});

/// Current user's role in the active facility ('organizer', 'supervisor', or 'guard').
final activeFacilityRoleProvider = Provider<String>((ref) {
  final facility = ref.watch(activeFacilityProvider);
  final user = ref.watch(currentUserProvider).valueOrNull;
  if (facility == null || user == null) return 'guard';

  final userName = user.fullName.toLowerCase();
  final isOwner = facility.ownerUserId.toLowerCase() == userName;
  if (isOwner) return 'organizer';

  // If organizerCode is visible and non-empty, user has organizer level
  if (facility.organizerCode.isNotEmpty) return 'organizer';

  // If supervisorCode is visible and non-empty, user has supervisor level
  if (facility.supervisorCode.isNotEmpty) return 'supervisor';

  return 'guard';
});
