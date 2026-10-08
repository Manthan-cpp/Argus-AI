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
import 'package:argus_server/src/generated/protocol.dart' as _iggnejrg;
import 'package:serverpod/serverpod.dart' as _is;
import 'workspace_settings.dart' as _i88empjm;

abstract class Workspace
    implements _is.SerializableModel, _is.ProtocolSerialization {
  Workspace._({
    this.id,
    required this.ownerUserId,
    required this.name,
    required this.createdAt,
    required this.settings,
  });

  factory Workspace({
    int? id,
    required String ownerUserId,
    required String name,
    required DateTime createdAt,
    required _i88empjm.WorkspaceSettings settings,
  }) = _WorkspaceImpl;

  factory Workspace.fromJson(Map<String, dynamic> jsonSerialization) {
    return Workspace(
      id: jsonSerialization['id'] as int?,
      ownerUserId: jsonSerialization['ownerUserId'] as String,
      name: jsonSerialization['name'] as String,
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      settings: _iggnejrg.Protocol().deserialize<_i88empjm.WorkspaceSettings>(
        jsonSerialization['settings'],
      ),
    );
  }

  int? id;

  String ownerUserId;

  String name;

  DateTime createdAt;

  _i88empjm.WorkspaceSettings settings;

  /// Returns a shallow copy of this [Workspace]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Workspace copyWith({
    int? id,
    String? ownerUserId,
    String? name,
    DateTime? createdAt,
    _i88empjm.WorkspaceSettings? settings,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Workspace',
      if (id != null) 'id': id,
      'ownerUserId': ownerUserId,
      'name': name,
      'createdAt': createdAt.toJson(),
      'settings': settings.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Workspace',
      if (id != null) 'id': id,
      'ownerUserId': ownerUserId,
      'name': name,
      'createdAt': createdAt.toJson(),
      'settings': settings.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _WorkspaceImpl extends Workspace {
  _WorkspaceImpl({
    int? id,
    required String ownerUserId,
    required String name,
    required DateTime createdAt,
    required _i88empjm.WorkspaceSettings settings,
  }) : super._(
         id: id,
         ownerUserId: ownerUserId,
         name: name,
         createdAt: createdAt,
         settings: settings,
       );

  /// Returns a shallow copy of this [Workspace]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Workspace copyWith({
    Object? id = _Undefined,
    String? ownerUserId,
    String? name,
    DateTime? createdAt,
    _i88empjm.WorkspaceSettings? settings,
  }) {
    return Workspace(
      id: id is int? ? id : this.id,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      settings: settings ?? this.settings.copyWith(),
    );
  }
}
