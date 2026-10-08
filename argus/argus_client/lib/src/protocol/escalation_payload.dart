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

abstract class EscalationPayload
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  EscalationPayload._({required this.incidentId});

  factory EscalationPayload({required int incidentId}) = _EscalationPayloadImpl;

  factory EscalationPayload.fromJson(Map<String, dynamic> jsonSerialization) {
    return EscalationPayload(
      incidentId: jsonSerialization['incidentId'] as int,
    );
  }

  int incidentId;

  /// Returns a shallow copy of this [EscalationPayload]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  EscalationPayload copyWith({int? incidentId});
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EscalationPayload',
      'incidentId': incidentId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'EscalationPayload',
      'incidentId': incidentId,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _EscalationPayloadImpl extends EscalationPayload {
  _EscalationPayloadImpl({required int incidentId})
    : super._(incidentId: incidentId);

  /// Returns a shallow copy of this [EscalationPayload]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  EscalationPayload copyWith({int? incidentId}) {
    return EscalationPayload(incidentId: incidentId ?? this.incidentId);
  }
}
