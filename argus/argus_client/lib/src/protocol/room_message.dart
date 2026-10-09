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

abstract class RoomMessage
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RoomMessage._({
    this.id,
    required this.roomId,
    this.senderId,
    required this.senderName,
    this.senderRole,
    required this.kind,
    required this.content,
    this.incidentId,
    this.cameraName,
    this.severity,
    required this.createdAt,
  });

  factory RoomMessage({
    int? id,
    required int roomId,
    int? senderId,
    required String senderName,
    String? senderRole,
    required String kind,
    required String content,
    int? incidentId,
    String? cameraName,
    String? severity,
    required DateTime createdAt,
  }) = _RoomMessageImpl;

  factory RoomMessage.fromJson(Map<String, dynamic> jsonSerialization) {
    return RoomMessage(
      id: jsonSerialization['id'] as int?,
      roomId: jsonSerialization['roomId'] as int,
      senderId: jsonSerialization['senderId'] as int?,
      senderName: jsonSerialization['senderName'] as String,
      senderRole: jsonSerialization['senderRole'] as String?,
      kind: jsonSerialization['kind'] as String,
      content: jsonSerialization['content'] as String,
      incidentId: jsonSerialization['incidentId'] as int?,
      cameraName: jsonSerialization['cameraName'] as String?,
      severity: jsonSerialization['severity'] as String?,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int roomId;

  int? senderId;

  String senderName;

  String? senderRole;

  String kind;

  String content;

  int? incidentId;

  String? cameraName;

  String? severity;

  DateTime createdAt;

  /// Returns a shallow copy of this [RoomMessage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RoomMessage copyWith({
    int? id,
    int? roomId,
    int? senderId,
    String? senderName,
    String? senderRole,
    String? kind,
    String? content,
    int? incidentId,
    String? cameraName,
    String? severity,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RoomMessage',
      if (id != null) 'id': id,
      'roomId': roomId,
      if (senderId != null) 'senderId': senderId,
      'senderName': senderName,
      if (senderRole != null) 'senderRole': senderRole,
      'kind': kind,
      'content': content,
      if (incidentId != null) 'incidentId': incidentId,
      if (cameraName != null) 'cameraName': cameraName,
      if (severity != null) 'severity': severity,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RoomMessage',
      if (id != null) 'id': id,
      'roomId': roomId,
      if (senderId != null) 'senderId': senderId,
      'senderName': senderName,
      if (senderRole != null) 'senderRole': senderRole,
      'kind': kind,
      'content': content,
      if (incidentId != null) 'incidentId': incidentId,
      if (cameraName != null) 'cameraName': cameraName,
      if (severity != null) 'severity': severity,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RoomMessageImpl extends RoomMessage {
  _RoomMessageImpl({
    int? id,
    required int roomId,
    int? senderId,
    required String senderName,
    String? senderRole,
    required String kind,
    required String content,
    int? incidentId,
    String? cameraName,
    String? severity,
    required DateTime createdAt,
  }) : super._(
         id: id,
         roomId: roomId,
         senderId: senderId,
         senderName: senderName,
         senderRole: senderRole,
         kind: kind,
         content: content,
         incidentId: incidentId,
         cameraName: cameraName,
         severity: severity,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [RoomMessage]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RoomMessage copyWith({
    Object? id = _Undefined,
    int? roomId,
    Object? senderId = _Undefined,
    String? senderName,
    Object? senderRole = _Undefined,
    String? kind,
    String? content,
    Object? incidentId = _Undefined,
    Object? cameraName = _Undefined,
    Object? severity = _Undefined,
    DateTime? createdAt,
  }) {
    return RoomMessage(
      id: id is int? ? id : this.id,
      roomId: roomId ?? this.roomId,
      senderId: senderId is int? ? senderId : this.senderId,
      senderName: senderName ?? this.senderName,
      senderRole: senderRole is String? ? senderRole : this.senderRole,
      kind: kind ?? this.kind,
      content: content ?? this.content,
      incidentId: incidentId is int? ? incidentId : this.incidentId,
      cameraName: cameraName is String? ? cameraName : this.cameraName,
      severity: severity is String? ? severity : this.severity,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
