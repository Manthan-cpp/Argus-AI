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

abstract class BBoxN
    implements _is.SerializableModel, _is.ProtocolSerialization {
  BBoxN._({
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });

  factory BBoxN({
    required double x,
    required double y,
    required double w,
    required double h,
  }) = _BBoxNImpl;

  factory BBoxN.fromJson(Map<String, dynamic> jsonSerialization) {
    return BBoxN(
      x: (jsonSerialization['x'] as num).toDouble(),
      y: (jsonSerialization['y'] as num).toDouble(),
      w: (jsonSerialization['w'] as num).toDouble(),
      h: (jsonSerialization['h'] as num).toDouble(),
    );
  }

  double x;

  double y;

  double w;

  double h;

  /// Returns a shallow copy of this [BBoxN]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  BBoxN copyWith({
    double? x,
    double? y,
    double? w,
    double? h,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'BBoxN',
      'x': x,
      'y': y,
      'w': w,
      'h': h,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'BBoxN',
      'x': x,
      'y': y,
      'w': w,
      'h': h,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _BBoxNImpl extends BBoxN {
  _BBoxNImpl({
    required double x,
    required double y,
    required double w,
    required double h,
  }) : super._(
         x: x,
         y: y,
         w: w,
         h: h,
       );

  /// Returns a shallow copy of this [BBoxN]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  BBoxN copyWith({
    double? x,
    double? y,
    double? w,
    double? h,
  }) {
    return BBoxN(
      x: x ?? this.x,
      y: y ?? this.y,
      w: w ?? this.w,
      h: h ?? this.h,
    );
  }
}
