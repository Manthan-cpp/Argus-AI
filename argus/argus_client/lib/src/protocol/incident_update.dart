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
import 'incident.dart' as _iy4wsyyx;
import 'incident_event.dart' as _icglyrab;

abstract class IncidentUpdate
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  IncidentUpdate._({
    required this.incident,
    this.event,
  });

  factory IncidentUpdate({
    required _iy4wsyyx.Incident incident,
    _icglyrab.IncidentEvent? event,
  }) = _IncidentUpdateImpl;

  factory IncidentUpdate.fromJson(Map<String, dynamic> jsonSerialization) {
    return IncidentUpdate(
      incident: _i5naexi9.Protocol().deserialize<_iy4wsyyx.Incident>(
        jsonSerialization['incident'],
      ),
      event: jsonSerialization['event'] == null
          ? null
          : _i5naexi9.Protocol().deserialize<_icglyrab.IncidentEvent>(
              jsonSerialization['event'],
            ),
    );
  }

  _iy4wsyyx.Incident incident;

  _icglyrab.IncidentEvent? event;

  /// Returns a shallow copy of this [IncidentUpdate]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  IncidentUpdate copyWith({
    _iy4wsyyx.Incident? incident,
    _icglyrab.IncidentEvent? event,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IncidentUpdate',
      'incident': incident.toJson(),
      if (event != null) 'event': event?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IncidentUpdate',
      'incident': incident.toJsonForProtocol(),
      if (event != null) 'event': event?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IncidentUpdateImpl extends IncidentUpdate {
  _IncidentUpdateImpl({
    required _iy4wsyyx.Incident incident,
    _icglyrab.IncidentEvent? event,
  }) : super._(
         incident: incident,
         event: event,
       );

  /// Returns a shallow copy of this [IncidentUpdate]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  IncidentUpdate copyWith({
    _iy4wsyyx.Incident? incident,
    Object? event = _Undefined,
  }) {
    return IncidentUpdate(
      incident: incident ?? this.incident.copyWith(),
      event: event is _icglyrab.IncidentEvent? ? event : this.event?.copyWith(),
    );
  }
}
