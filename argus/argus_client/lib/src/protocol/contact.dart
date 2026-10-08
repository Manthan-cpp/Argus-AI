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

abstract class Contact
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  Contact._({
    this.id,
    required this.workspaceId,
    required this.name,
    required this.role,
    required this.notifyInApp,
    this.telegramChatId,
    this.telegramLinkCode,
    this.isLinked,
    this.createdAt,
  });

  factory Contact({
    int? id,
    required int workspaceId,
    required String name,
    required String role,
    required bool notifyInApp,
    String? telegramChatId,
    String? telegramLinkCode,
    bool? isLinked,
    DateTime? createdAt,
  }) = _ContactImpl;

  factory Contact.fromJson(Map<String, dynamic> jsonSerialization) {
    return Contact(
      id: jsonSerialization['id'] as int?,
      workspaceId: jsonSerialization['workspaceId'] as int,
      name: jsonSerialization['name'] as String,
      role: jsonSerialization['role'] as String,
      notifyInApp: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['notifyInApp'],
      ),
      telegramChatId: jsonSerialization['telegramChatId'] as String?,
      telegramLinkCode: jsonSerialization['telegramLinkCode'] as String?,
      isLinked: jsonSerialization['isLinked'] == null
          ? null
          : _isc.BoolJsonExtension.fromJson(jsonSerialization['isLinked']),
      createdAt: jsonSerialization['createdAt'] == null
          ? null
          : _isc.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int workspaceId;

  String name;

  String role;

  bool notifyInApp;

  String? telegramChatId;

  String? telegramLinkCode;

  bool? isLinked;

  DateTime? createdAt;

  /// Returns a shallow copy of this [Contact]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Contact copyWith({
    int? id,
    int? workspaceId,
    String? name,
    String? role,
    bool? notifyInApp,
    String? telegramChatId,
    String? telegramLinkCode,
    bool? isLinked,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Contact',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'name': name,
      'role': role,
      'notifyInApp': notifyInApp,
      if (telegramChatId != null) 'telegramChatId': telegramChatId,
      if (telegramLinkCode != null) 'telegramLinkCode': telegramLinkCode,
      if (isLinked != null) 'isLinked': isLinked,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Contact',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'name': name,
      'role': role,
      'notifyInApp': notifyInApp,
      if (telegramChatId != null) 'telegramChatId': telegramChatId,
      if (telegramLinkCode != null) 'telegramLinkCode': telegramLinkCode,
      if (isLinked != null) 'isLinked': isLinked,
      if (createdAt != null) 'createdAt': createdAt?.toJson(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ContactImpl extends Contact {
  _ContactImpl({
    int? id,
    required int workspaceId,
    required String name,
    required String role,
    required bool notifyInApp,
    String? telegramChatId,
    String? telegramLinkCode,
    bool? isLinked,
    DateTime? createdAt,
  }) : super._(
         id: id,
         workspaceId: workspaceId,
         name: name,
         role: role,
         notifyInApp: notifyInApp,
         telegramChatId: telegramChatId,
         telegramLinkCode: telegramLinkCode,
         isLinked: isLinked,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Contact]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  Contact copyWith({
    Object? id = _Undefined,
    int? workspaceId,
    String? name,
    String? role,
    bool? notifyInApp,
    Object? telegramChatId = _Undefined,
    Object? telegramLinkCode = _Undefined,
    Object? isLinked = _Undefined,
    Object? createdAt = _Undefined,
  }) {
    return Contact(
      id: id is int? ? id : this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      role: role ?? this.role,
      notifyInApp: notifyInApp ?? this.notifyInApp,
      telegramChatId: telegramChatId is String?
          ? telegramChatId
          : this.telegramChatId,
      telegramLinkCode: telegramLinkCode is String?
          ? telegramLinkCode
          : this.telegramLinkCode,
      isLinked: isLinked is bool? ? isLinked : this.isLinked,
      createdAt: createdAt is DateTime? ? createdAt : this.createdAt,
    );
  }
}
