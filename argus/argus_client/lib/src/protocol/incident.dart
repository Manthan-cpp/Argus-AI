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
import 'verification_info.dart' as _iv8f4ltc;

abstract class Incident
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Incident._({
    this.id,
    required this.workspaceId,
    required this.cameraId,
    required this.ruleId,
    required this.ruleSnapshotJson,
    required this.severity,
    required this.status,
    required this.openedAt,
    this.ackedAt,
    this.resolvedAt,
    this.evidenceFileKey,
    required this.verification,
    required this.summary,
    required this.signalContextJson,
    this.assignedTo,
  });

  factory Incident({
    int? id,
    required int workspaceId,
    required int cameraId,
    required int ruleId,
    required String ruleSnapshotJson,
    required String severity,
    required String status,
    required DateTime openedAt,
    DateTime? ackedAt,
    DateTime? resolvedAt,
    String? evidenceFileKey,
    required _iv8f4ltc.VerificationInfo verification,
    required String summary,
    required String signalContextJson,
    String? assignedTo,
  }) = _IncidentImpl;

  factory Incident.fromJson(Map<String, dynamic> jsonSerialization) {
    return Incident(
      id: jsonSerialization['id'] as int?,
      workspaceId: jsonSerialization['workspaceId'] as int,
      cameraId: jsonSerialization['cameraId'] as int,
      ruleId: jsonSerialization['ruleId'] as int,
      ruleSnapshotJson: jsonSerialization['ruleSnapshotJson'] as String,
      severity: jsonSerialization['severity'] as String,
      status: jsonSerialization['status'] as String,
      openedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['openedAt'],
      ),
      ackedAt: jsonSerialization['ackedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['ackedAt']),
      resolvedAt: jsonSerialization['resolvedAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(
              jsonSerialization['resolvedAt'],
            ),
      evidenceFileKey: jsonSerialization['evidenceFileKey'] as String?,
      verification: _i5naexi9.Protocol()
          .deserialize<_iv8f4ltc.VerificationInfo>(
            jsonSerialization['verification'],
          ),
      summary: jsonSerialization['summary'] as String,
      signalContextJson: jsonSerialization['signalContextJson'] as String,
      assignedTo: jsonSerialization['assignedTo'] as String?,
    );
  }

  int? id;

  int workspaceId;

  int cameraId;

  int ruleId;

  String ruleSnapshotJson;

  String severity;

  String status;

  DateTime openedAt;

  DateTime? ackedAt;

  DateTime? resolvedAt;

  String? evidenceFileKey;

  _iv8f4ltc.VerificationInfo verification;

  String summary;

  String signalContextJson;

  String? assignedTo;

  /// Returns a shallow copy of this [Incident]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Incident copyWith({
    int? id,
    int? workspaceId,
    int? cameraId,
    int? ruleId,
    String? ruleSnapshotJson,
    String? severity,
    String? status,
    DateTime? openedAt,
    DateTime? ackedAt,
    DateTime? resolvedAt,
    String? evidenceFileKey,
    _iv8f4ltc.VerificationInfo? verification,
    String? summary,
    String? signalContextJson,
    String? assignedTo,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Incident',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'cameraId': cameraId,
      'ruleId': ruleId,
      'ruleSnapshotJson': ruleSnapshotJson,
      'severity': severity,
      'status': status,
      'openedAt': openedAt.toJson(),
      if (ackedAt != null) 'ackedAt': ackedAt?.toJson(),
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
      if (evidenceFileKey != null) 'evidenceFileKey': evidenceFileKey,
      'verification': verification.toJson(),
      'summary': summary,
      'signalContextJson': signalContextJson,
      if (assignedTo != null) 'assignedTo': assignedTo,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Incident',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'cameraId': cameraId,
      'ruleId': ruleId,
      'ruleSnapshotJson': ruleSnapshotJson,
      'severity': severity,
      'status': status,
      'openedAt': openedAt.toJson(),
      if (ackedAt != null) 'ackedAt': ackedAt?.toJson(),
      if (resolvedAt != null) 'resolvedAt': resolvedAt?.toJson(),
      if (evidenceFileKey != null) 'evidenceFileKey': evidenceFileKey,
      'verification': verification.toJsonForProtocol(),
      'summary': summary,
      'signalContextJson': signalContextJson,
      if (assignedTo != null) 'assignedTo': assignedTo,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _IncidentImpl extends Incident {
  _IncidentImpl({
    int? id,
    required int workspaceId,
    required int cameraId,
    required int ruleId,
    required String ruleSnapshotJson,
    required String severity,
    required String status,
    required DateTime openedAt,
    DateTime? ackedAt,
    DateTime? resolvedAt,
    String? evidenceFileKey,
    required _iv8f4ltc.VerificationInfo verification,
    required String summary,
    required String signalContextJson,
    String? assignedTo,
  }) : super._(
         id: id,
         workspaceId: workspaceId,
         cameraId: cameraId,
         ruleId: ruleId,
         ruleSnapshotJson: ruleSnapshotJson,
         severity: severity,
         status: status,
         openedAt: openedAt,
         ackedAt: ackedAt,
         resolvedAt: resolvedAt,
         evidenceFileKey: evidenceFileKey,
         verification: verification,
         summary: summary,
         signalContextJson: signalContextJson,
         assignedTo: assignedTo,
       );

  /// Returns a shallow copy of this [Incident]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Incident copyWith({
    Object? id = _Undefined,
    int? workspaceId,
    int? cameraId,
    int? ruleId,
    String? ruleSnapshotJson,
    String? severity,
    String? status,
    DateTime? openedAt,
    Object? ackedAt = _Undefined,
    Object? resolvedAt = _Undefined,
    Object? evidenceFileKey = _Undefined,
    _iv8f4ltc.VerificationInfo? verification,
    String? summary,
    String? signalContextJson,
    Object? assignedTo = _Undefined,
  }) {
    return Incident(
      id: id is int? ? id : this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      cameraId: cameraId ?? this.cameraId,
      ruleId: ruleId ?? this.ruleId,
      ruleSnapshotJson: ruleSnapshotJson ?? this.ruleSnapshotJson,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      openedAt: openedAt ?? this.openedAt,
      ackedAt: ackedAt is DateTime? ? ackedAt : this.ackedAt,
      resolvedAt: resolvedAt is DateTime? ? resolvedAt : this.resolvedAt,
      evidenceFileKey: evidenceFileKey is String?
          ? evidenceFileKey
          : this.evidenceFileKey,
      verification: verification ?? this.verification.copyWith(),
      summary: summary ?? this.summary,
      signalContextJson: signalContextJson ?? this.signalContextJson,
      assignedTo: assignedTo is String? ? assignedTo : this.assignedTo,
    );
  }
}
