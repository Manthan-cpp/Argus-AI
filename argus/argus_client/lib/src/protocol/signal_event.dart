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
import 'person_signal.dart' as _izlx5iyl;

abstract class SignalEvent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  SignalEvent._({
    required this.tsMs,
    required this.kind,
    required this.personCount,
    required this.persons,
  });

  factory SignalEvent({
    required int tsMs,
    required String kind,
    required int personCount,
    required List<_izlx5iyl.PersonSignal> persons,
  }) = _SignalEventImpl;

  factory SignalEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return SignalEvent(
      tsMs: jsonSerialization['tsMs'] as int,
      kind: jsonSerialization['kind'] as String,
      personCount: jsonSerialization['personCount'] as int,
      persons: _i5naexi9.Protocol().deserialize<List<_izlx5iyl.PersonSignal>>(
        jsonSerialization['persons'],
      ),
    );
  }

  int tsMs;

  String kind;

  int personCount;

  List<_izlx5iyl.PersonSignal> persons;

  /// Returns a shallow copy of this [SignalEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  SignalEvent copyWith({
    int? tsMs,
    String? kind,
    int? personCount,
    List<_izlx5iyl.PersonSignal>? persons,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'SignalEvent',
      'tsMs': tsMs,
      'kind': kind,
      'personCount': personCount,
      'persons': persons.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'SignalEvent',
      'tsMs': tsMs,
      'kind': kind,
      'personCount': personCount,
      'persons': persons.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _SignalEventImpl extends SignalEvent {
  _SignalEventImpl({
    required int tsMs,
    required String kind,
    required int personCount,
    required List<_izlx5iyl.PersonSignal> persons,
  }) : super._(
         tsMs: tsMs,
         kind: kind,
         personCount: personCount,
         persons: persons,
       );

  /// Returns a shallow copy of this [SignalEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  SignalEvent copyWith({
    int? tsMs,
    String? kind,
    int? personCount,
    List<_izlx5iyl.PersonSignal>? persons,
  }) {
    return SignalEvent(
      tsMs: tsMs ?? this.tsMs,
      kind: kind ?? this.kind,
      personCount: personCount ?? this.personCount,
      persons: persons ?? this.persons.map((e0) => e0.copyWith()).toList(),
    );
  }
}
