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

abstract class RuleTrigger
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RuleTrigger._({
    required this.signal,
    this.zoneId,
    required this.minDurationSec,
    required this.minConfidence,
    this.minCount,
    this.ppe,
  });

  factory RuleTrigger({
    required String signal,
    int? zoneId,
    required int minDurationSec,
    required double minConfidence,
    int? minCount,
    String? ppe,
  }) = _RuleTriggerImpl;

  factory RuleTrigger.fromJson(Map<String, dynamic> jsonSerialization) {
    return RuleTrigger(
      signal: jsonSerialization['signal'] as String,
      zoneId: jsonSerialization['zoneId'] as int?,
      minDurationSec: jsonSerialization['minDurationSec'] as int,
      minConfidence: (jsonSerialization['minConfidence'] as num).toDouble(),
      minCount: jsonSerialization['minCount'] as int?,
      ppe: jsonSerialization['ppe'] as String?,
    );
  }

  String signal;

  int? zoneId;

  int minDurationSec;

  double minConfidence;

  int? minCount;

  String? ppe;

  /// Returns a shallow copy of this [RuleTrigger]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RuleTrigger copyWith({
    String? signal,
    int? zoneId,
    int? minDurationSec,
    double? minConfidence,
    int? minCount,
    String? ppe,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RuleTrigger',
      'signal': signal,
      if (zoneId != null) 'zoneId': zoneId,
      'minDurationSec': minDurationSec,
      'minConfidence': minConfidence,
      if (minCount != null) 'minCount': minCount,
      if (ppe != null) 'ppe': ppe,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RuleTrigger',
      'signal': signal,
      if (zoneId != null) 'zoneId': zoneId,
      'minDurationSec': minDurationSec,
      'minConfidence': minConfidence,
      if (minCount != null) 'minCount': minCount,
      if (ppe != null) 'ppe': ppe,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RuleTriggerImpl extends RuleTrigger {
  _RuleTriggerImpl({
    required String signal,
    int? zoneId,
    required int minDurationSec,
    required double minConfidence,
    int? minCount,
    String? ppe,
  }) : super._(
         signal: signal,
         zoneId: zoneId,
         minDurationSec: minDurationSec,
         minConfidence: minConfidence,
         minCount: minCount,
         ppe: ppe,
       );

  /// Returns a shallow copy of this [RuleTrigger]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RuleTrigger copyWith({
    String? signal,
    Object? zoneId = _Undefined,
    int? minDurationSec,
    double? minConfidence,
    Object? minCount = _Undefined,
    Object? ppe = _Undefined,
  }) {
    return RuleTrigger(
      signal: signal ?? this.signal,
      zoneId: zoneId is int? ? zoneId : this.zoneId,
      minDurationSec: minDurationSec ?? this.minDurationSec,
      minConfidence: minConfidence ?? this.minConfidence,
      minCount: minCount is int? ? minCount : this.minCount,
      ppe: ppe is String? ? ppe : this.ppe,
    );
  }
}
