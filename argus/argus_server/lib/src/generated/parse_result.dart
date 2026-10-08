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
import 'package:argus_server/src/generated/protocol.dart' as _iggnejrg;
import 'package:serverpod/serverpod.dart' as _is;
import 'rule_spec.dart' as _ixr8yfub;

abstract class ParseResult
    implements _is.SerializableModel, _is.ProtocolSerialization {
  ParseResult._({
    this.spec,
    required this.parsedBy,
    required this.confidence,
    required this.warnings,
    this.unsupportedReason,
    required this.alternatives,
  });

  factory ParseResult({
    _ixr8yfub.RuleSpec? spec,
    required String parsedBy,
    required double confidence,
    required List<String> warnings,
    String? unsupportedReason,
    required List<String> alternatives,
  }) = _ParseResultImpl;

  factory ParseResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return ParseResult(
      spec: jsonSerialization['spec'] == null
          ? null
          : _iggnejrg.Protocol().deserialize<_ixr8yfub.RuleSpec>(
              jsonSerialization['spec'],
            ),
      parsedBy: jsonSerialization['parsedBy'] as String,
      confidence: (jsonSerialization['confidence'] as num).toDouble(),
      warnings: _iggnejrg.Protocol().deserialize<List<String>>(
        jsonSerialization['warnings'],
      ),
      unsupportedReason: jsonSerialization['unsupportedReason'] as String?,
      alternatives: _iggnejrg.Protocol().deserialize<List<String>>(
        jsonSerialization['alternatives'],
      ),
    );
  }

  _ixr8yfub.RuleSpec? spec;

  String parsedBy;

  double confidence;

  List<String> warnings;

  String? unsupportedReason;

  List<String> alternatives;

  /// Returns a shallow copy of this [ParseResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  ParseResult copyWith({
    _ixr8yfub.RuleSpec? spec,
    String? parsedBy,
    double? confidence,
    List<String>? warnings,
    String? unsupportedReason,
    List<String>? alternatives,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ParseResult',
      if (spec != null) 'spec': spec?.toJson(),
      'parsedBy': parsedBy,
      'confidence': confidence,
      'warnings': warnings.toJson(),
      if (unsupportedReason != null) 'unsupportedReason': unsupportedReason,
      'alternatives': alternatives.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ParseResult',
      if (spec != null) 'spec': spec?.toJsonForProtocol(),
      'parsedBy': parsedBy,
      'confidence': confidence,
      'warnings': warnings.toJson(),
      if (unsupportedReason != null) 'unsupportedReason': unsupportedReason,
      'alternatives': alternatives.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ParseResultImpl extends ParseResult {
  _ParseResultImpl({
    _ixr8yfub.RuleSpec? spec,
    required String parsedBy,
    required double confidence,
    required List<String> warnings,
    String? unsupportedReason,
    required List<String> alternatives,
  }) : super._(
         spec: spec,
         parsedBy: parsedBy,
         confidence: confidence,
         warnings: warnings,
         unsupportedReason: unsupportedReason,
         alternatives: alternatives,
       );

  /// Returns a shallow copy of this [ParseResult]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  ParseResult copyWith({
    Object? spec = _Undefined,
    String? parsedBy,
    double? confidence,
    List<String>? warnings,
    Object? unsupportedReason = _Undefined,
    List<String>? alternatives,
  }) {
    return ParseResult(
      spec: spec is _ixr8yfub.RuleSpec? ? spec : this.spec?.copyWith(),
      parsedBy: parsedBy ?? this.parsedBy,
      confidence: confidence ?? this.confidence,
      warnings: warnings ?? this.warnings.map((e0) => e0).toList(),
      unsupportedReason: unsupportedReason is String?
          ? unsupportedReason
          : this.unsupportedReason,
      alternatives: alternatives ?? this.alternatives.map((e0) => e0).toList(),
    );
  }
}
