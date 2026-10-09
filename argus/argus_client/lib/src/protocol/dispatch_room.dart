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
import 'package:argus_client/src/protocol/protocol.dart' as _i5naexi9;
import 'package:serverpod_client/serverpod_client.dart' as _isc;

abstract class DispatchRoom
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DispatchRoom._({
    this.id,
    required this.workspaceId,
    required this.name,
    required this.code,
    this.description,
    required this.createdById,
    required this.createdByName,
    required this.createdAt,
    required this.cameraIds,
    required this.isActive,
  });

  factory DispatchRoom({
    int? id,
    required int workspaceId,
    required String name,
    required String code,
    String? description,
    required int createdById,
    required String createdByName,
    required DateTime createdAt,
    required List<int> cameraIds,
    required bool isActive,
  }) = _DispatchRoomImpl;

  factory DispatchRoom.fromJson(Map<String, dynamic> jsonSerialization) {
    return DispatchRoom(
      id: jsonSerialization['id'] as int?,
      workspaceId: jsonSerialization['workspaceId'] as int,
      name: jsonSerialization['name'] as String,
      code: jsonSerialization['code'] as String,
      description: jsonSerialization['description'] as String?,
      createdById: jsonSerialization['createdById'] as int,
      createdByName: jsonSerialization['createdByName'] as String,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      cameraIds: _i5naexi9.Protocol().deserialize<List<int>>(
        jsonSerialization['cameraIds'],
      ),
      isActive: _isc.BoolJsonExtension.fromJson(jsonSerialization['isActive']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int workspaceId;

  String name;

  String code;

  String? description;

  int createdById;

  String createdByName;

  DateTime createdAt;

  List<int> cameraIds;

  bool isActive;

  /// Returns a shallow copy of this [DispatchRoom]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DispatchRoom copyWith({
    int? id,
    int? workspaceId,
    String? name,
    String? code,
    String? description,
    int? createdById,
    String? createdByName,
    DateTime? createdAt,
    List<int>? cameraIds,
    bool? isActive,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DispatchRoom',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'name': name,
      'code': code,
      if (description != null) 'description': description,
      'createdById': createdById,
      'createdByName': createdByName,
      'createdAt': createdAt.toJson(),
      'cameraIds': cameraIds.toJson(),
      'isActive': isActive,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DispatchRoom',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'name': name,
      'code': code,
      if (description != null) 'description': description,
      'createdById': createdById,
      'createdByName': createdByName,
      'createdAt': createdAt.toJson(),
      'cameraIds': cameraIds.toJson(),
      'isActive': isActive,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DispatchRoomImpl extends DispatchRoom {
  _DispatchRoomImpl({
    int? id,
    required int workspaceId,
    required String name,
    required String code,
    String? description,
    required int createdById,
    required String createdByName,
    required DateTime createdAt,
    required List<int> cameraIds,
    required bool isActive,
  }) : super._(
         id: id,
         workspaceId: workspaceId,
         name: name,
         code: code,
         description: description,
         createdById: createdById,
         createdByName: createdByName,
         createdAt: createdAt,
         cameraIds: cameraIds,
         isActive: isActive,
       );

  /// Returns a shallow copy of this [DispatchRoom]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DispatchRoom copyWith({
    Object? id = _Undefined,
    int? workspaceId,
    String? name,
    String? code,
    Object? description = _Undefined,
    int? createdById,
    String? createdByName,
    DateTime? createdAt,
    List<int>? cameraIds,
    bool? isActive,
  }) {
    return DispatchRoom(
      id: id is int? ? id : this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description is String? ? description : this.description,
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
      cameraIds: cameraIds ?? this.cameraIds.map((e0) => e0).toList(),
      isActive: isActive ?? this.isActive,
    );
  }
}
