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
import 'signal_event.dart' as _ixpqzu9p;

abstract class SignalBatch
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SignalBatch._({
    required this.cameraId,
    required this.sentAtMs,
    required this.seq,
    required this.signals,
  });

  factory SignalBatch({
    required int cameraId,
    required int sentAtMs,
    required int seq,
    required List<_ixpqzu9p.SignalEvent> signals,
  }) = _SignalBatchImpl;

  factory SignalBatch.fromJson(Map<String, dynamic> jsonSerialization) {
    return SignalBatch(
      cameraId: jsonSerialization['cameraId'] as int,
      sentAtMs: jsonSerialization['sentAtMs'] as int,
      seq: jsonSerialization['seq'] as int,
      signals: _i5naexi9.Protocol().deserialize<List<_ixpqzu9p.SignalEvent>>(
        jsonSerialization['signals'],
      ),
    );
  }

  int cameraId;

  int sentAtMs;

  int seq;

  List<_ixpqzu9p.SignalEvent> signals;

  /// Returns a shallow copy of this [SignalBatch]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SignalBatch copyWith({
    int? cameraId,
    int? sentAtMs,
    int? seq,
    List<_ixpqzu9p.SignalEvent>? signals,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SignalBatch',
      'cameraId': cameraId,
      'sentAtMs': sentAtMs,
      'seq': seq,
      'signals': signals.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SignalBatch',
      'cameraId': cameraId,
      'sentAtMs': sentAtMs,
      'seq': seq,
      'signals': signals.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _SignalBatchImpl extends SignalBatch {
  _SignalBatchImpl({
    required int cameraId,
    required int sentAtMs,
    required int seq,
    required List<_ixpqzu9p.SignalEvent> signals,
  }) : super._(
         cameraId: cameraId,
         sentAtMs: sentAtMs,
         seq: seq,
         signals: signals,
       );

  /// Returns a shallow copy of this [SignalBatch]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SignalBatch copyWith({
    int? cameraId,
    int? sentAtMs,
    int? seq,
    List<_ixpqzu9p.SignalEvent>? signals,
  }) {
    return SignalBatch(
      cameraId: cameraId ?? this.cameraId,
      sentAtMs: sentAtMs ?? this.sentAtMs,
      seq: seq ?? this.seq,
      signals: signals ?? this.signals.map((e0) => e0.copyWith()).toList(),
    );
  }
}
