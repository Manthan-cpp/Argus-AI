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
import 'package:serverpod/serverpod.dart' as _is;

abstract class RetentionPayload
    implements _is.SerializableModel, _is.ProtocolSerialization {
  RetentionPayload._({this.workspaceId});

  factory RetentionPayload({int? workspaceId}) = _RetentionPayloadImpl;

  factory RetentionPayload.fromJson(Map<String, dynamic> jsonSerialization) {
    return RetentionPayload(
      workspaceId: jsonSerialization['workspaceId'] as int?,
    );
  }

  int? workspaceId;

  /// Returns a shallow copy of this [RetentionPayload]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RetentionPayload copyWith({int? workspaceId});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RetentionPayload',
      if (workspaceId != null) 'workspaceId': workspaceId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RetentionPayload',
      if (workspaceId != null) 'workspaceId': workspaceId,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RetentionPayloadImpl extends RetentionPayload {
  _RetentionPayloadImpl({int? workspaceId}) : super._(workspaceId: workspaceId);

  /// Returns a shallow copy of this [RetentionPayload]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RetentionPayload copyWith({Object? workspaceId = _Undefined}) {
    return RetentionPayload(
      workspaceId: workspaceId is int? ? workspaceId : this.workspaceId,
    );
  }
}
