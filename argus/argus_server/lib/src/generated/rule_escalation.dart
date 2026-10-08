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

abstract class RuleEscalation
    implements _is.SerializableModel, _is.ProtocolSerialization {
  RuleEscalation._({
    required this.afterSec,
    required this.notify,
    required this.message,
  });

  factory RuleEscalation({
    required int afterSec,
    required String notify,
    required String message,
  }) = _RuleEscalationImpl;

  factory RuleEscalation.fromJson(Map<String, dynamic> jsonSerialization) {
    return RuleEscalation(
      afterSec: jsonSerialization['afterSec'] as int,
      notify: jsonSerialization['notify'] as String,
      message: jsonSerialization['message'] as String,
    );
  }

  int afterSec;

  String notify;

  String message;

  /// Returns a shallow copy of this [RuleEscalation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RuleEscalation copyWith({
    int? afterSec,
    String? notify,
    String? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RuleEscalation',
      'afterSec': afterSec,
      'notify': notify,
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RuleEscalation',
      'afterSec': afterSec,
      'notify': notify,
      'message': message,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _RuleEscalationImpl extends RuleEscalation {
  _RuleEscalationImpl({
    required int afterSec,
    required String notify,
    required String message,
  }) : super._(
         afterSec: afterSec,
         notify: notify,
         message: message,
       );

  /// Returns a shallow copy of this [RuleEscalation]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RuleEscalation copyWith({
    int? afterSec,
    String? notify,
    String? message,
  }) {
    return RuleEscalation(
      afterSec: afterSec ?? this.afterSec,
      notify: notify ?? this.notify,
      message: message ?? this.message,
    );
  }
}
