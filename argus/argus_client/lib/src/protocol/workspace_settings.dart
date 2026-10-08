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

abstract class WorkspaceSettings
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  WorkspaceSettings._({
    required this.cloudVerification,
    required this.blurEvidence,
    required this.retentionDays,
    required this.browserNotifications,
    required this.telegramLinked,
    required this.timezone,
  });

  factory WorkspaceSettings({
    required bool cloudVerification,
    required bool blurEvidence,
    required int retentionDays,
    required bool browserNotifications,
    required bool telegramLinked,
    required String timezone,
  }) = _WorkspaceSettingsImpl;

  factory WorkspaceSettings.fromJson(Map<String, dynamic> jsonSerialization) {
    return WorkspaceSettings(
      cloudVerification: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['cloudVerification'],
      ),
      blurEvidence: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['blurEvidence'],
      ),
      retentionDays: jsonSerialization['retentionDays'] as int,
      browserNotifications: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['browserNotifications'],
      ),
      telegramLinked: _isc.BoolJsonExtension.fromJson(
        jsonSerialization['telegramLinked'],
      ),
      timezone: jsonSerialization['timezone'] as String,
    );
  }

  bool cloudVerification;

  bool blurEvidence;

  int retentionDays;

  bool browserNotifications;

  bool telegramLinked;

  String timezone;

  /// Returns a shallow copy of this [WorkspaceSettings]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  WorkspaceSettings copyWith({
    bool? cloudVerification,
    bool? blurEvidence,
    int? retentionDays,
    bool? browserNotifications,
    bool? telegramLinked,
    String? timezone,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'WorkspaceSettings',
      'cloudVerification': cloudVerification,
      'blurEvidence': blurEvidence,
      'retentionDays': retentionDays,
      'browserNotifications': browserNotifications,
      'telegramLinked': telegramLinked,
      'timezone': timezone,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'WorkspaceSettings',
      'cloudVerification': cloudVerification,
      'blurEvidence': blurEvidence,
      'retentionDays': retentionDays,
      'browserNotifications': browserNotifications,
      'telegramLinked': telegramLinked,
      'timezone': timezone,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _WorkspaceSettingsImpl extends WorkspaceSettings {
  _WorkspaceSettingsImpl({
    required bool cloudVerification,
    required bool blurEvidence,
    required int retentionDays,
    required bool browserNotifications,
    required bool telegramLinked,
    required String timezone,
  }) : super._(
         cloudVerification: cloudVerification,
         blurEvidence: blurEvidence,
         retentionDays: retentionDays,
         browserNotifications: browserNotifications,
         telegramLinked: telegramLinked,
         timezone: timezone,
       );

  /// Returns a shallow copy of this [WorkspaceSettings]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  WorkspaceSettings copyWith({
    bool? cloudVerification,
    bool? blurEvidence,
    int? retentionDays,
    bool? browserNotifications,
    bool? telegramLinked,
    String? timezone,
  }) {
    return WorkspaceSettings(
      cloudVerification: cloudVerification ?? this.cloudVerification,
      blurEvidence: blurEvidence ?? this.blurEvidence,
      retentionDays: retentionDays ?? this.retentionDays,
      browserNotifications: browserNotifications ?? this.browserNotifications,
      telegramLinked: telegramLinked ?? this.telegramLinked,
      timezone: timezone ?? this.timezone,
    );
  }
}
