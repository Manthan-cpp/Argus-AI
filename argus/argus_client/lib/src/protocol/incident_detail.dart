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

abstract class IncidentDetail
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  IncidentDetail._({
    required this.incident,
    required this.events,
    this.evidenceUrl,
  });

  factory IncidentDetail({
    required _iy4wsyyx.Incident incident,
    required List<_icglyrab.IncidentEvent> events,
    String? evidenceUrl,
  }) = _IncidentDetailImpl;

  factory IncidentDetail.fromJson(Map<String, dynamic> jsonSerialization) {
    return IncidentDetail(
      incident: _i5naexi9.Protocol().deserialize<_iy4wsyyx.Incident>(
        jsonSerialization['incident'],
      ),
      events: _i5naexi9.Protocol().deserialize<List<_icglyrab.IncidentEvent>>(
        jsonSerialization['events'],
      ),
      evidenceUrl: jsonSerialization['evidenceUrl'] as String?,
    );
  }

  _iy4wsyyx.Incident incident;

  List<_icglyrab.IncidentEvent> events;

  String? evidenceUrl;

  /// Returns a shallow copy of this [IncidentDetail]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  IncidentDetail copyWith({
    _iy4wsyyx.Incident? incident,
    List<_icglyrab.IncidentEvent>? events,
    String? evidenceUrl,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IncidentDetail',
      'incident': incident.toJson(),
      'events': events.toJson(valueToJson: (v) => v.toJson()),
      if (evidenceUrl != null) 'evidenceUrl': evidenceUrl,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IncidentDetail',
      'incident': incident.toJsonForProtocol(),
      'events': events.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (evidenceUrl != null) 'evidenceUrl': evidenceUrl,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IncidentDetailImpl extends IncidentDetail {
  _IncidentDetailImpl({
    required _iy4wsyyx.Incident incident,
    required List<_icglyrab.IncidentEvent> events,
    String? evidenceUrl,
  }) : super._(
         incident: incident,
         events: events,
         evidenceUrl: evidenceUrl,
       );

  /// Returns a shallow copy of this [IncidentDetail]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  IncidentDetail copyWith({
    _iy4wsyyx.Incident? incident,
    List<_icglyrab.IncidentEvent>? events,
    Object? evidenceUrl = _Undefined,
  }) {
    return IncidentDetail(
      incident: incident ?? this.incident.copyWith(),
      events: events ?? this.events.map((e0) => e0.copyWith()).toList(),
      evidenceUrl: evidenceUrl is String? ? evidenceUrl : this.evidenceUrl,
    );
  }
}
