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

abstract class RuleVerify
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RuleVerify._({
    required this.enabled,
    required this.kind,
  });

  factory RuleVerify({
    required bool enabled,
    required String kind,
  }) = _RuleVerifyImpl;

  factory RuleVerify.fromJson(Map<String, dynamic> jsonSerialization) {
    return RuleVerify(
      enabled: _isc.BoolJsonExtension.fromJson(jsonSerialization['enabled']),
      kind: jsonSerialization['kind'] as String,
    );
  }

  bool enabled;

  String kind;

  /// Returns a shallow copy of this [RuleVerify]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RuleVerify copyWith({
    bool? enabled,
    String? kind,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RuleVerify',
      'enabled': enabled,
      'kind': kind,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RuleVerify',
      'enabled': enabled,
      'kind': kind,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _RuleVerifyImpl extends RuleVerify {
  _RuleVerifyImpl({
    required bool enabled,
    required String kind,
  }) : super._(
         enabled: enabled,
         kind: kind,
       );

  /// Returns a shallow copy of this [RuleVerify]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RuleVerify copyWith({
    bool? enabled,
    String? kind,
  }) {
    return RuleVerify(
      enabled: enabled ?? this.enabled,
      kind: kind ?? this.kind,
    );
  }
}
