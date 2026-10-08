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
import 'time_window.dart' as _idjbqmwg;

abstract class RuleConditions
    implements _is.SerializableModel, _is.ProtocolSerialization {
  RuleConditions._({
    required this.timeWindows,
    required this.daysOfWeek,
    required this.timezone,
  });

  factory RuleConditions({
    required List<_idjbqmwg.TimeWindow> timeWindows,
    required List<int> daysOfWeek,
    required String timezone,
  }) = _RuleConditionsImpl;

  factory RuleConditions.fromJson(Map<String, dynamic> jsonSerialization) {
    return RuleConditions(
      timeWindows: _iggnejrg.Protocol().deserialize<List<_idjbqmwg.TimeWindow>>(
        jsonSerialization['timeWindows'],
      ),
      daysOfWeek: _iggnejrg.Protocol().deserialize<List<int>>(
        jsonSerialization['daysOfWeek'],
      ),
      timezone: jsonSerialization['timezone'] as String,
    );
  }

  List<_idjbqmwg.TimeWindow> timeWindows;

  List<int> daysOfWeek;

  String timezone;

  /// Returns a shallow copy of this [RuleConditions]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  RuleConditions copyWith({
    List<_idjbqmwg.TimeWindow>? timeWindows,
    List<int>? daysOfWeek,
    String? timezone,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'RuleConditions',
      'timeWindows': timeWindows.toJson(valueToJson: (v) => v.toJson()),
      'daysOfWeek': daysOfWeek.toJson(),
      'timezone': timezone,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'RuleConditions',
      'timeWindows': timeWindows.toJson(
        valueToJson: (v) => v.toJsonForProtocol(),
      ),
      'daysOfWeek': daysOfWeek.toJson(),
      'timezone': timezone,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _RuleConditionsImpl extends RuleConditions {
  _RuleConditionsImpl({
    required List<_idjbqmwg.TimeWindow> timeWindows,
    required List<int> daysOfWeek,
    required String timezone,
  }) : super._(
         timeWindows: timeWindows,
         daysOfWeek: daysOfWeek,
         timezone: timezone,
       );

  /// Returns a shallow copy of this [RuleConditions]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  RuleConditions copyWith({
    List<_idjbqmwg.TimeWindow>? timeWindows,
    List<int>? daysOfWeek,
    String? timezone,
  }) {
    return RuleConditions(
      timeWindows:
          timeWindows ?? this.timeWindows.map((e0) => e0.copyWith()).toList(),
      daysOfWeek: daysOfWeek ?? this.daysOfWeek.map((e0) => e0).toList(),
      timezone: timezone ?? this.timezone,
    );
  }
}
