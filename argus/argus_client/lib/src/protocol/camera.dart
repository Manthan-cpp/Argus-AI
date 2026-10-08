/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class Camera
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Camera._({
    this.id,
    required this.workspaceId,
    required this.name,
    required this.sourceKind,
    required this.sourceRef,
    required this.enabled,
    required this.createdAt,
    this.lastSignalAt,
    required this.status,
  });

  factory Camera({
    int? id,
    required int workspaceId,
    required String name,
    required String sourceKind,
    required String sourceRef,
    required bool enabled,
    required DateTime createdAt,
    DateTime? lastSignalAt,
    required String status,
  }) = _CameraImpl;

  factory Camera.fromJson(Map<String, dynamic> jsonSerialization) {
    return Camera(
      id: jsonSerialization['id'] as int?,
      workspaceId: jsonSerialization['workspaceId'] as int,
      name: jsonSerialization['name'] as String,
      sourceKind: jsonSerialization['sourceKind'] as String,
      sourceRef: jsonSerialization['sourceRef'] as String,
      enabled: _isc.BoolJsonExtension.fromJson(jsonSerialization['enabled']),
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      lastSignalAt: jsonSerialization['lastSignalAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['lastSignalAt'],
            ),
      status: jsonSerialization['status'] as String,
    );
  }

  int? id;

  int workspaceId;

  String name;

  String sourceKind;

  String sourceRef;

  bool enabled;

  DateTime createdAt;

  DateTime? lastSignalAt;

  String status;

  /// Returns a shallow copy of this [Camera]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Camera copyWith({
    int? id,
    int? workspaceId,
    String? name,
    String? sourceKind,
    String? sourceRef,
    bool? enabled,
    DateTime? createdAt,
    DateTime? lastSignalAt,
    String? status,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Camera',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'name': name,
      'sourceKind': sourceKind,
      'sourceRef': sourceRef,
      'enabled': enabled,
      'createdAt': createdAt.toJson(),
      if (lastSignalAt != null) 'lastSignalAt': lastSignalAt?.toJson(),
      'status': status,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Camera',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'name': name,
      'sourceKind': sourceKind,
      'sourceRef': sourceRef,
      'enabled': enabled,
      'createdAt': createdAt.toJson(),
      if (lastSignalAt != null) 'lastSignalAt': lastSignalAt?.toJson(),
      'status': status,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CameraImpl extends Camera {
  _CameraImpl({
    int? id,
    required int workspaceId,
    required String name,
    required String sourceKind,
    required String sourceRef,
    required bool enabled,
    required DateTime createdAt,
    DateTime? lastSignalAt,
    required String status,
  }) : super._(
         id: id,
         workspaceId: workspaceId,
         name: name,
         sourceKind: sourceKind,
         sourceRef: sourceRef,
         enabled: enabled,
         createdAt: createdAt,
         lastSignalAt: lastSignalAt,
         status: status,
       );

  /// Returns a shallow copy of this [Camera]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Camera copyWith({
    Object? id = _Undefined,
    int? workspaceId,
    String? name,
    String? sourceKind,
    String? sourceRef,
    bool? enabled,
    DateTime? createdAt,
    Object? lastSignalAt = _Undefined,
    String? status,
  }) {
    return Camera(
      id: id is int? ? id : this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      sourceKind: sourceKind ?? this.sourceKind,
      sourceRef: sourceRef ?? this.sourceRef,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      lastSignalAt: lastSignalAt is DateTime?
          ? lastSignalAt
          : this.lastSignalAt,
      status: status ?? this.status,
    );
  }
}
