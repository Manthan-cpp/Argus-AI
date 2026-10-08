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

abstract class AuditEntry
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  AuditEntry._({
    this.id,
    required this.workspaceId,
    required this.at,
    required this.actor,
    required this.action,
    required this.targetKind,
    required this.targetId,
    required this.detail,
  });

  factory AuditEntry({
    int? id,
    required int workspaceId,
    required DateTime at,
    required String actor,
    required String action,
    required String targetKind,
    required int targetId,
    required String detail,
  }) = _AuditEntryImpl;

  factory AuditEntry.fromJson(Map<String, dynamic> jsonSerialization) {
    return AuditEntry(
      id: jsonSerialization['id'] as int?,
      workspaceId: jsonSerialization['workspaceId'] as int,
      at: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['at']),
      actor: jsonSerialization['actor'] as String,
      action: jsonSerialization['action'] as String,
      targetKind: jsonSerialization['targetKind'] as String,
      targetId: jsonSerialization['targetId'] as int,
      detail: jsonSerialization['detail'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int workspaceId;

  DateTime at;

  String actor;

  String action;

  String targetKind;

  int targetId;

  String detail;

  /// Returns a shallow copy of this [AuditEntry]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  AuditEntry copyWith({
    int? id,
    int? workspaceId,
    DateTime? at,
    String? actor,
    String? action,
    String? targetKind,
    int? targetId,
    String? detail,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AuditEntry',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'at': at.toJson(),
      'actor': actor,
      'action': action,
      'targetKind': targetKind,
      'targetId': targetId,
      'detail': detail,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'AuditEntry',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'at': at.toJson(),
      'actor': actor,
      'action': action,
      'targetKind': targetKind,
      'targetId': targetId,
      'detail': detail,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AuditEntryImpl extends AuditEntry {
  _AuditEntryImpl({
    int? id,
    required int workspaceId,
    required DateTime at,
    required String actor,
    required String action,
    required String targetKind,
    required int targetId,
    required String detail,
  }) : super._(
         id: id,
         workspaceId: workspaceId,
         at: at,
         actor: actor,
         action: action,
         targetKind: targetKind,
         targetId: targetId,
         detail: detail,
       );

  /// Returns a shallow copy of this [AuditEntry]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  AuditEntry copyWith({
    Object? id = _Undefined,
    int? workspaceId,
    DateTime? at,
    String? actor,
    String? action,
    String? targetKind,
    int? targetId,
    String? detail,
  }) {
    return AuditEntry(
      id: id is int? ? id : this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      at: at ?? this.at,
      actor: actor ?? this.actor,
      action: action ?? this.action,
      targetKind: targetKind ?? this.targetKind,
      targetId: targetId ?? this.targetId,
      detail: detail ?? this.detail,
    );
  }
}
