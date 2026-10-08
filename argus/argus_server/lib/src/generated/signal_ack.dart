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

abstract class SignalAck
    implements _is.SerializableModel, _is.ProtocolSerialization {
  SignalAck._({
    required this.accepted,
    required this.needEvidenceFor,
    required this.serverTimeMs,
  });

  factory SignalAck({
    required bool accepted,
    required List<int> needEvidenceFor,
    required int serverTimeMs,
  }) = _SignalAckImpl;

  factory SignalAck.fromJson(Map<String, dynamic> jsonSerialization) {
    return SignalAck(
      accepted: _is.BoolJsonExtension.fromJson(jsonSerialization['accepted']),
      needEvidenceFor: _iggnejrg.Protocol().deserialize<List<int>>(
        jsonSerialization['needEvidenceFor'],
      ),
      serverTimeMs: jsonSerialization['serverTimeMs'] as int,
    );
  }

  bool accepted;

  List<int> needEvidenceFor;

  int serverTimeMs;

  /// Returns a shallow copy of this [SignalAck]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  SignalAck copyWith({
    bool? accepted,
    List<int>? needEvidenceFor,
    int? serverTimeMs,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SignalAck',
      'accepted': accepted,
      'needEvidenceFor': needEvidenceFor.toJson(),
      'serverTimeMs': serverTimeMs,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SignalAck',
      'accepted': accepted,
      'needEvidenceFor': needEvidenceFor.toJson(),
      'serverTimeMs': serverTimeMs,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _SignalAckImpl extends SignalAck {
  _SignalAckImpl({
    required bool accepted,
    required List<int> needEvidenceFor,
    required int serverTimeMs,
  }) : super._(
         accepted: accepted,
         needEvidenceFor: needEvidenceFor,
         serverTimeMs: serverTimeMs,
       );

  /// Returns a shallow copy of this [SignalAck]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  SignalAck copyWith({
    bool? accepted,
    List<int>? needEvidenceFor,
    int? serverTimeMs,
  }) {
    return SignalAck(
      accepted: accepted ?? this.accepted,
      needEvidenceFor:
          needEvidenceFor ?? this.needEvidenceFor.map((e0) => e0).toList(),
      serverTimeMs: serverTimeMs ?? this.serverTimeMs,
    );
  }
}
