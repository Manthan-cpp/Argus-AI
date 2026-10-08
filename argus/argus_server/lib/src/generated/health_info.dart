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
import 'package:serverpod/serverpod.dart' as _is;

abstract class HealthInfo
    implements _is.SerializableModel, _is.ProtocolSerialization {
  HealthInfo._({
    required this.version,
    required this.engineVersion,
    required this.geminiState,
    required this.quotaNote,
    required this.queueDepth,
  });

  factory HealthInfo({
    required String version,
    required String engineVersion,
    required String geminiState,
    required String quotaNote,
    required int queueDepth,
  }) = _HealthInfoImpl;

  factory HealthInfo.fromJson(Map<String, dynamic> jsonSerialization) {
    return HealthInfo(
      version: jsonSerialization['version'] as String,
      engineVersion: jsonSerialization['engineVersion'] as String,
      geminiState: jsonSerialization['geminiState'] as String,
      quotaNote: jsonSerialization['quotaNote'] as String,
      queueDepth: jsonSerialization['queueDepth'] as int,
    );
  }

  String version;

  String engineVersion;

  String geminiState;

  String quotaNote;

  int queueDepth;

  /// Returns a shallow copy of this [HealthInfo]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  HealthInfo copyWith({
    String? version,
    String? engineVersion,
    String? geminiState,
    String? quotaNote,
    int? queueDepth,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HealthInfo',
      'version': version,
      'engineVersion': engineVersion,
      'geminiState': geminiState,
      'quotaNote': quotaNote,
      'queueDepth': queueDepth,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'HealthInfo',
      'version': version,
      'engineVersion': engineVersion,
      'geminiState': geminiState,
      'quotaNote': quotaNote,
      'queueDepth': queueDepth,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _HealthInfoImpl extends HealthInfo {
  _HealthInfoImpl({
    required String version,
    required String engineVersion,
    required String geminiState,
    required String quotaNote,
    required int queueDepth,
  }) : super._(
         version: version,
         engineVersion: engineVersion,
         geminiState: geminiState,
         quotaNote: quotaNote,
         queueDepth: queueDepth,
       );

  /// Returns a shallow copy of this [HealthInfo]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  HealthInfo copyWith({
    String? version,
    String? engineVersion,
    String? geminiState,
    String? quotaNote,
    int? queueDepth,
  }) {
    return HealthInfo(
      version: version ?? this.version,
      engineVersion: engineVersion ?? this.engineVersion,
      geminiState: geminiState ?? this.geminiState,
      quotaNote: quotaNote ?? this.quotaNote,
      queueDepth: queueDepth ?? this.queueDepth,
    );
  }
}
