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

abstract class RoomMember
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  RoomMember._({
    this.id,
    required this.roomId,
    required this.userId,
    required this.userName,
    required this.userRole,
    required this.joinedAt,
  });

  factory RoomMember({
    int? id,
    required int roomId,
    required int userId,
    required String userName,
    required String userRole,
    required DateTime joinedAt,
  }) = _RoomMemberImpl;

  factory RoomMember.fromJson(Map<String, dynamic> jsonSerialization) {
    return RoomMember(
      id: jsonSerialization['id'] as int?,
      roomId: jsonSerialization['roomId'] as int,
      userId: jsonSerialization['userId'] as int,
      userName: jsonSerialization['userName'] as String,
      userRole: jsonSerialization['userRole'] as String,
      joinedAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['joinedAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int roomId;

  int userId;

  String userName;

  String userRole;

  DateTime joinedAt;

  /// Returns a shallow copy of this [RoomMember]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  RoomMember copyWith({
    int? id,
    int? roomId,
    int? userId,
    String? userName,
    String? userRole,
    DateTime? joinedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RoomMember',
      if (id != null) 'id': id,
      'roomId': roomId,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'joinedAt': joinedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RoomMember',
      if (id != null) 'id': id,
      'roomId': roomId,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'joinedAt': joinedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RoomMemberImpl extends RoomMember {
  _RoomMemberImpl({
    int? id,
    required int roomId,
    required int userId,
    required String userName,
    required String userRole,
    required DateTime joinedAt,
  }) : super._(
         id: id,
         roomId: roomId,
         userId: userId,
         userName: userName,
         userRole: userRole,
         joinedAt: joinedAt,
       );

  /// Returns a shallow copy of this [RoomMember]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  RoomMember copyWith({
    Object? id = _Undefined,
    int? roomId,
    int? userId,
    String? userName,
    String? userRole,
    DateTime? joinedAt,
  }) {
    return RoomMember(
      id: id is int? ? id : this.id,
      roomId: roomId ?? this.roomId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }
}
