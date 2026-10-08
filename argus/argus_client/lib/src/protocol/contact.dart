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
    this.telegramChatId,
    required this.notifyInApp,
  });

  factory Contact({
    int? id,
    required int workspaceId,
    required String name,
    required String role,
    String? telegramChatId,
    required bool notifyInApp,
  }) = _ContactImpl;

  factory Contact.fromJson(Map<String, dynamic> jsonSerialization) {
    return Contact(
      id: jsonSerialization['id'] as int?,
      workspaceId: jsonSerialization['workspaceId'] as int,
      name: jsonSerialization['name'] as String,
      role: jsonSerialization['role'] as String,
      telegramChatId: jsonSerialization['telegramChatId'] as String?,
      notifyInApp: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['notifyInApp'],
      ),
    );
  }

  int? id;

  int workspaceId;

  String name;

  String role;

  String? telegramChatId;

  bool notifyInApp;

  /// Returns a shallow copy of this [Contact]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  Contact copyWith({
    int? id,
    int? workspaceId,
    String? name,
    String? role,
    String? telegramChatId,
    bool? notifyInApp,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Contact',
      if (id != null) 'id': id,
      'workspaceId': workspaceId,
      'name': name,
      'role': role,
      if (telegramChatId != null) 'telegramChatId': telegramChatId,
      'notifyInApp': notifyInApp,
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
      if (telegramChatId != null) 'telegramChatId': telegramChatId,
      'notifyInApp': notifyInApp,
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
    String? telegramChatId,
    required bool notifyInApp,
  }) : super._(
         id: id,
         workspaceId: workspaceId,
         name: name,
         role: role,
         telegramChatId: telegramChatId,
         notifyInApp: notifyInApp,
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
    Object? telegramChatId = _Undefined,
    bool? notifyInApp,
  }) {
    return Contact(
      id: id is int? ? id : this.id,
      workspaceId: workspaceId ?? this.workspaceId,
      name: name ?? this.name,
      role: role ?? this.role,
      telegramChatId: telegramChatId is String?
          ? telegramChatId
          : this.telegramChatId,
      notifyInApp: notifyInApp ?? this.notifyInApp,
    );
  }
}
