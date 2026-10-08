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

abstract class IncidentEvent
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  IncidentEvent._({
    this.id,
    required this.incidentId,
    required this.at,
    required this.kind,
    required this.detail,
  });

  factory IncidentEvent({
    int? id,
    required int incidentId,
    required DateTime at,
    required String kind,
    required String detail,
  }) = _IncidentEventImpl;

  factory IncidentEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return IncidentEvent(
      id: jsonSerialization['id'] as int?,
      incidentId: jsonSerialization['incidentId'] as int,
      at: _isc.DateTimeJsonExtension.fromJson(jsonSerialization['at']),
      kind: jsonSerialization['kind'] as String,
      detail: jsonSerialization['detail'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int incidentId;

  DateTime at;

  String kind;

  String detail;

  /// Returns a shallow copy of this [IncidentEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  IncidentEvent copyWith({
    int? id,
    int? incidentId,
    DateTime? at,
    String? kind,
    String? detail,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'IncidentEvent',
      if (id != null) 'id': id,
      'incidentId': incidentId,
      'at': at.toJson(),
      'kind': kind,
      'detail': detail,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'IncidentEvent',
      if (id != null) 'id': id,
      'incidentId': incidentId,
      'at': at.toJson(),
      'kind': kind,
      'detail': detail,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IncidentEventImpl extends IncidentEvent {
  _IncidentEventImpl({
    int? id,
    required int incidentId,
    required DateTime at,
    required String kind,
    required String detail,
  }) : super._(
         id: id,
         incidentId: incidentId,
         at: at,
         kind: kind,
         detail: detail,
       );

  /// Returns a shallow copy of this [IncidentEvent]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  IncidentEvent copyWith({
    Object? id = _Undefined,
    int? incidentId,
    DateTime? at,
    String? kind,
    String? detail,
  }) {
    return IncidentEvent(
      id: id is int? ? id : this.id,
      incidentId: incidentId ?? this.incidentId,
      at: at ?? this.at,
      kind: kind ?? this.kind,
      detail: detail ?? this.detail,
    );
  }
}
