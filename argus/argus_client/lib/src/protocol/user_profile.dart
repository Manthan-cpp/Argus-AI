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

abstract class UserProfile
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  UserProfile._({
    this.id,
    required this.workspaceId,
    required this.fullName,
    required this.email,
    required this.role,
    this.avatarUrl,
    required this.createdAt,
  });

  factory UserProfile({
    int? id,
    required int workspaceId,
    required String fullName,
    required String email,
    required String role,
    String? avatarUrl,
    required DateTime createdAt,
  }) = _UserProfileImpl;

  factory UserProfile.fromJson(Map<String, dynamic> jsonSerialization) {
    return UserProfile(
      id: jsonSerialization['id'] as int?,
      workspaceId: jsonSerialization['workspaceId'] as int,
      fullName: jsonSerialization['fullName'] as String,
      email: jsonSerialization['email'] as String,
      role: jsonSerialization['role'] as String,
      avatarUrl: jsonSerialization['avatarUrl'] as String?,
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int workspaceId;

  String fullName;

  String email;

  String role;

  String? avatarUrl;

  DateTime createdAt;

  /// Returns a shallow copy of this [UserProfile]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  UserProfile copyWith({
    int? id,
    int? workspaceId,
    String? fullName,
    String? email,
    String? role,
    String? avatarUrl,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'UserProfile',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'fullName': fullName,
      'email': email,
      'role': role,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'UserProfile',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'fullName': fullName,
      'email': email,
      'role': role,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _UserProfileImpl extends UserProfile {
  _UserProfileImpl({
    int? id,
    required int workspaceId,
    required String fullName,
    required String email,
    required String role,
    String? avatarUrl,
    required DateTime createdAt,
  }) : super._(
         id: id,
         workspaceId: workspaceId,
         fullName: fullName,
         email: email,
         role: role,
         avatarUrl: avatarUrl,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [UserProfile]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  UserProfile copyWith({
    Object? id = _Undefined,
    int? workspaceId,
    String? fullName,
    String? email,
    String? role,
    Object? avatarUrl = _Undefined,
    DateTime? createdAt,
  }) {
    return UserProfile(
      id: id is int? ? id : this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl is String? ? avatarUrl : this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
