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
import 'point_n.dart' as _ixjrd72v;

abstract class Zone
    implements _is.SerializableModel, _is.ProtocolSerialization {
  Zone._({
    this.id,
    required this.cameraId,
    required this.name,
    required this.kind,
    required this.color,
    required this.polygon,
    required this.createdAt,
  });

  factory Zone({
    int? id,
    required int cameraId,
    required String name,
    required String kind,
    required String color,
    required List<_ixjrd72v.PointN> polygon,
    required DateTime createdAt,
  }) = _ZoneImpl;

  factory Zone.fromJson(Map<String, dynamic> jsonSerialization) {
    return Zone(
      id: jsonSerialization['id'] as int?,
      cameraId: jsonSerialization['cameraId'] as int,
      name: jsonSerialization['name'] as String,
      kind: jsonSerialization['kind'] as String,
      color: jsonSerialization['color'] as String,
      polygon: _iggnejrg.Protocol().deserialize<List<_ixjrd72v.PointN>>(
        jsonSerialization['polygon'],
      ),
      createdAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  int? id;

  int cameraId;

  String name;

  String kind;

  String color;

  List<_ixjrd72v.PointN> polygon;

  DateTime createdAt;

  /// Returns a shallow copy of this [Zone]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  Zone copyWith({
    int? id,
    int? cameraId,
    String? name,
    String? kind,
    String? color,
    List<_ixjrd72v.PointN>? polygon,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Zone',
      if (id != null) 'id': id,
      'cameraId': cameraId,
      'name': name,
      'kind': kind,
      'color': color,
      'polygon': polygon.toJson(valueToJson: (v) => v.toJson()),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'Zone',
      if (id != null) 'id': id,
      'cameraId': cameraId,
      'name': name,
      'kind': kind,
      'color': color,
      'polygon': polygon.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ZoneImpl extends Zone {
  _ZoneImpl({
    int? id,
    required int cameraId,
    required String name,
    required String kind,
    required String color,
    required List<_ixjrd72v.PointN> polygon,
    required DateTime createdAt,
  }) : super._(
         id: id,
         cameraId: cameraId,
         name: name,
         kind: kind,
         color: color,
         polygon: polygon,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Zone]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  Zone copyWith({
    Object? id = _Undefined,
    int? cameraId,
    String? name,
    String? kind,
    String? color,
    List<_ixjrd72v.PointN>? polygon,
    DateTime? createdAt,
  }) {
    return Zone(
      id: id is int? ? id : this.id,
      cameraId: cameraId ?? this.cameraId,
      name: name ?? this.name,
      kind: kind ?? this.kind,
      color: color ?? this.color,
      polygon: polygon ?? this.polygon.map((e0) => e0.copyWith()).toList(),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
