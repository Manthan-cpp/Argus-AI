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

abstract class DemoSeedResult
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  DemoSeedResult._({
    required this.workspaceId,
    required this.cameraIds,
    required this.ruleIds,
  });

  factory DemoSeedResult({
    required int workspaceId,
    required List<int> cameraIds,
    required List<int> ruleIds,
  }) = _DemoSeedResultImpl;

  factory DemoSeedResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return DemoSeedResult(
      workspaceId: jsonSerialization['workspaceId'] as int,
      cameraIds: _i5naexi9.Protocol().deserialize<List<int>>(
        jsonSerialization['cameraIds'],
      ),
      ruleIds: _i5naexi9.Protocol().deserialize<List<int>>(
        jsonSerialization['ruleIds'],
      ),
    );
  }

  int workspaceId;

  List<int> cameraIds;

  List<int> ruleIds;

  /// Returns a shallow copy of this [DemoSeedResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  DemoSeedResult copyWith({
    int? workspaceId,
    List<int>? cameraIds,
    List<int>? ruleIds,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DemoSeedResult',
      'workspaceId': workspaceId,
      'cameraIds': cameraIds.toJson(),
      'ruleIds': ruleIds.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DemoSeedResult',
      'workspaceId': workspaceId,
      'cameraIds': cameraIds.toJson(),
      'ruleIds': ruleIds.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _DemoSeedResultImpl extends DemoSeedResult {
  _DemoSeedResultImpl({
    required int workspaceId,
    required List<int> cameraIds,
    required List<int> ruleIds,
  }) : super._(
         workspaceId: workspaceId,
         cameraIds: cameraIds,
         ruleIds: ruleIds,
       );

  /// Returns a shallow copy of this [DemoSeedResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  DemoSeedResult copyWith({
    int? workspaceId,
    List<int>? cameraIds,
    List<int>? ruleIds,
  }) {
    return DemoSeedResult(
      workspaceId: workspaceId ?? this.workspaceId,
      cameraIds: cameraIds ?? this.cameraIds.map((e0) => e0).toList(),
      ruleIds: ruleIds ?? this.ruleIds.map((e0) => e0).toList(),
    );
  }
}
