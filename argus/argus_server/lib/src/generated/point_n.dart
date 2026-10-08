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

abstract class PointN
    implements _is.SerializableModel, _is.ProtocolSerialization {
  PointN._({
    required this.x,
    required this.y,
  });

  factory PointN({
    required double x,
    required double y,
  }) = _PointNImpl;

  factory PointN.fromJson(Map<String, dynamic> jsonSerialization) {
    return PointN(
      x: (jsonSerialization['x'] as num).toDouble(),
      y: (jsonSerialization['y'] as num).toDouble(),
    );
  }

  double x;

  double y;

  /// Returns a shallow copy of this [PointN]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PointN copyWith({
    double? x,
    double? y,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PointN',
      'x': x,
      'y': y,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PointN',
      'x': x,
      'y': y,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _PointNImpl extends PointN {
  _PointNImpl({
    required double x,
    required double y,
  }) : super._(
         x: x,
         y: y,
       );

  /// Returns a shallow copy of this [PointN]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PointN copyWith({
    double? x,
    double? y,
  }) {
    return PointN(
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}
