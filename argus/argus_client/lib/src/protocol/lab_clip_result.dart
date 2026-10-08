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

abstract class LabClipResult
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  LabClipResult._({
    required this.clipId,
    required this.scenario,
    required this.expectedEvents,
    required this.detectedEvents,
    required this.tp,
    required this.fp,
    required this.fn,
    required this.latencyMsP50,
  });

  factory LabClipResult({
    required String clipId,
    required String scenario,
    required int expectedEvents,
    required int detectedEvents,
    required int tp,
    required int fp,
    required int fn,
    required int latencyMsP50,
  }) = _LabClipResultImpl;

  factory LabClipResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return LabClipResult(
      clipId: jsonSerialization['clipId'] as String,
      scenario: jsonSerialization['scenario'] as String,
      expectedEvents: jsonSerialization['expectedEvents'] as int,
      detectedEvents: jsonSerialization['detectedEvents'] as int,
      tp: jsonSerialization['tp'] as int,
      fp: jsonSerialization['fp'] as int,
      fn: jsonSerialization['fn'] as int,
      latencyMsP50: jsonSerialization['latencyMsP50'] as int,
    );
  }

  String clipId;

  String scenario;

  int expectedEvents;

  int detectedEvents;

  int tp;

  int fp;

  int fn;

  int latencyMsP50;

  /// Returns a shallow copy of this [LabClipResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  LabClipResult copyWith({
    String? clipId,
    String? scenario,
    int? expectedEvents,
    int? detectedEvents,
    int? tp,
    int? fp,
    int? fn,
    int? latencyMsP50,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'LabClipResult',
      'clipId': clipId,
      'scenario': scenario,
      'expectedEvents': expectedEvents,
      'detectedEvents': detectedEvents,
      'tp': tp,
      'fp': fp,
      'fn': fn,
      'latencyMsP50': latencyMsP50,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'LabClipResult',
      'clipId': clipId,
      'scenario': scenario,
      'expectedEvents': expectedEvents,
      'detectedEvents': detectedEvents,
      'tp': tp,
      'fp': fp,
      'fn': fn,
      'latencyMsP50': latencyMsP50,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _LabClipResultImpl extends LabClipResult {
  _LabClipResultImpl({
    required String clipId,
    required String scenario,
    required int expectedEvents,
    required int detectedEvents,
    required int tp,
    required int fp,
    required int fn,
    required int latencyMsP50,
  }) : super._(
         clipId: clipId,
         scenario: scenario,
         expectedEvents: expectedEvents,
         detectedEvents: detectedEvents,
         tp: tp,
         fp: fp,
         fn: fn,
         latencyMsP50: latencyMsP50,
       );

  /// Returns a shallow copy of this [LabClipResult]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  LabClipResult copyWith({
    String? clipId,
    String? scenario,
    int? expectedEvents,
    int? detectedEvents,
    int? tp,
    int? fp,
    int? fn,
    int? latencyMsP50,
  }) {
    return LabClipResult(
      clipId: clipId ?? this.clipId,
      scenario: scenario ?? this.scenario,
      expectedEvents: expectedEvents ?? this.expectedEvents,
      detectedEvents: detectedEvents ?? this.detectedEvents,
      tp: tp ?? this.tp,
      fp: fp ?? this.fp,
      fn: fn ?? this.fn,
      latencyMsP50: latencyMsP50 ?? this.latencyMsP50,
    );
  }
}
