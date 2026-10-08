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
import 'package:argus_client/src/protocol/protocol.dart' as _i5naexi9;
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'point_n.dart' as _ixjrd72v;

abstract class Zone
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
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
      polygon: _i5naexi9.Protocol().deserialize<List<_ixjrd72v.PointN>>(
        jsonSerialization['polygon'],
      ),
      createdAt: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  int cameraId;

  String name;

  String kind;

  String color;

  List<_ixjrd72v.PointN> polygon;

  DateTime createdAt;

  /// Returns a shallow copy of this [Zone]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
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
    return _isc.SerializationManager.encode(this);
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
  @_isc.useResult
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
