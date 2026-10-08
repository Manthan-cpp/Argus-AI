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

abstract class ClientConfig
    implements _is.SerializableModel, _is.ProtocolSerialization {
  ClientConfig._({
    required this.limitsJson,
    required this.featuresJson,
  });

  factory ClientConfig({
    required String limitsJson,
    required String featuresJson,
  }) = _ClientConfigImpl;

  factory ClientConfig.fromJson(Map<String, dynamic> jsonSerialization) {
    return ClientConfig(
      limitsJson: jsonSerialization['limitsJson'] as String,
      featuresJson: jsonSerialization['featuresJson'] as String,
    );
  }

  String limitsJson;

  String featuresJson;

  /// Returns a shallow copy of this [ClientConfig]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ClientConfig copyWith({
    String? limitsJson,
    String? featuresJson,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ClientConfig',
      'limitsJson': limitsJson,
      'featuresJson': featuresJson,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ClientConfig',
      'limitsJson': limitsJson,
      'featuresJson': featuresJson,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _ClientConfigImpl extends ClientConfig {
  _ClientConfigImpl({
    required String limitsJson,
    required String featuresJson,
  }) : super._(
         limitsJson: limitsJson,
         featuresJson: featuresJson,
       );

  /// Returns a shallow copy of this [ClientConfig]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ClientConfig copyWith({
    String? limitsJson,
    String? featuresJson,
  }) {
    return ClientConfig(
      limitsJson: limitsJson ?? this.limitsJson,
      featuresJson: featuresJson ?? this.featuresJson,
    );
  }
}
