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

abstract class DryRunResult
    implements _is.SerializableModel, _is.ProtocolSerialization {
  DryRunResult._({
    required this.triggered,
    this.triggeredAtMs,
    required this.explanation,
    required this.firedPointsMs,
  });

  factory DryRunResult({
    required bool triggered,
    int? triggeredAtMs,
    required String explanation,
    required List<int> firedPointsMs,
  }) = _DryRunResultImpl;

  factory DryRunResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return DryRunResult(
      triggered: _is.BoolJsonExtension.fromJson(jsonSerialization['triggered']),
      triggeredAtMs: jsonSerialization['triggeredAtMs'] as int?,
      explanation: jsonSerialization['explanation'] as String,
      firedPointsMs: _iggnejrg.Protocol().deserialize<List<int>>(
        jsonSerialization['firedPointsMs'],
      ),
    );
  }

  bool triggered;

  int? triggeredAtMs;

  String explanation;

  List<int> firedPointsMs;

  /// Returns a shallow copy of this [DryRunResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DryRunResult copyWith({
    bool? triggered,
    int? triggeredAtMs,
    String? explanation,
    List<int>? firedPointsMs,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DryRunResult',
      'triggered': triggered,
      if (triggeredAtMs != null) 'triggeredAtMs': triggeredAtMs,
      'explanation': explanation,
      'firedPointsMs': firedPointsMs.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DryRunResult',
      'triggered': triggered,
      if (triggeredAtMs != null) 'triggeredAtMs': triggeredAtMs,
      'explanation': explanation,
      'firedPointsMs': firedPointsMs.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DryRunResultImpl extends DryRunResult {
  _DryRunResultImpl({
    required bool triggered,
    int? triggeredAtMs,
    required String explanation,
    required List<int> firedPointsMs,
  }) : super._(
         triggered: triggered,
         triggeredAtMs: triggeredAtMs,
         explanation: explanation,
         firedPointsMs: firedPointsMs,
       );

  /// Returns a shallow copy of this [DryRunResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DryRunResult copyWith({
    bool? triggered,
    Object? triggeredAtMs = _Undefined,
    String? explanation,
    List<int>? firedPointsMs,
  }) {
    return DryRunResult(
      triggered: triggered ?? this.triggered,
      triggeredAtMs: triggeredAtMs is int? ? triggeredAtMs : this.triggeredAtMs,
      explanation: explanation ?? this.explanation,
      firedPointsMs:
          firedPointsMs ?? this.firedPointsMs.map((e0) => e0).toList(),
    );
  }
}
