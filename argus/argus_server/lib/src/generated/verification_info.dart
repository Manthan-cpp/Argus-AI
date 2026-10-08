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

abstract class VerificationInfo
    implements _is.SerializableModel, _is.ProtocolSerialization {
  VerificationInfo._({
    required this.status,
    this.reason,
    this.model,
  });

  factory VerificationInfo({
    required String status,
    String? reason,
    String? model,
  }) = _VerificationInfoImpl;

  factory VerificationInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return VerificationInfo(
      status: jsonSerialization['status'] as String,
      reason: jsonSerialization['reason'] as String?,
      model: jsonSerialization['model'] as String?,
    );
  }

  String status;

  String? reason;

  String? model;

  /// Returns a shallow copy of this [VerificationInfo]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  VerificationInfo copyWith({
    String? status,
    String? reason,
    String? model,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'VerificationInfo',
      'status': status,
      if (reason != null) 'reason': reason,
      if (model != null) 'model': model,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'VerificationInfo',
      'status': status,
      if (reason != null) 'reason': reason,
      if (model != null) 'model': model,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _VerificationInfoImpl extends VerificationInfo {
  _VerificationInfoImpl({
    required String status,
    String? reason,
    String? model,
  }) : super._(
         status: status,
         reason: reason,
         model: model,
       );

  /// Returns a shallow copy of this [VerificationInfo]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  VerificationInfo copyWith({
    String? status,
    Object? reason = _Undefined,
    Object? model = _Undefined,
  }) {
    return VerificationInfo(
      status: status ?? this.status,
      reason: reason is String? ? reason : this.reason,
      model: model is String? ? model : this.model,
    );
  }
}
