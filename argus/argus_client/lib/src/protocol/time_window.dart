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

abstract class TimeWindow
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  TimeWindow._({
    required this.start,
    required this.end,
  });

  factory TimeWindow({
    required String start,
    required String end,
  }) = _TimeWindowImpl;

  factory TimeWindow.fromJson(Map<String, dynamic> jsonSerialization) {
    return TimeWindow(
      start: jsonSerialization['start'] as String,
      end: jsonSerialization['end'] as String,
    );
  }

  String start;

  String end;

  /// Returns a shallow copy of this [TimeWindow]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  TimeWindow copyWith({
    String? start,
    String? end,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'TimeWindow',
      'start': start,
      'end': end,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'TimeWindow',
      'start': start,
      'end': end,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _TimeWindowImpl extends TimeWindow {
  _TimeWindowImpl({
    required String start,
    required String end,
  }) : super._(
         start: start,
         end: end,
       );

  /// Returns a shallow copy of this [TimeWindow]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  TimeWindow copyWith({
    String? start,
    String? end,
  }) {
    return TimeWindow(
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }
}
