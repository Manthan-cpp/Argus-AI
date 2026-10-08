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
import 'bbox_n.dart' as _izkg6gr4;
import 'point_n.dart' as _ixjrd72v;

abstract class PersonSignal
    implements _is.SerializableModel, _is.ProtocolSerialization {
  PersonSignal._({
    required this.trackId,
    required this.bboxN,
    required this.footN,
    required this.zoneIds,
    this.torsoAngleDeg,
    this.hipDropRatio,
    required this.aspect,
    required this.motionScore,
    required this.fallScore,
    required this.motionlessMs,
    required this.confidence,
  });

  factory PersonSignal({
    required int trackId,
    required _izkg6gr4.BBoxN bboxN,
    required _ixjrd72v.PointN footN,
    required List<int> zoneIds,
    double? torsoAngleDeg,
    double? hipDropRatio,
    required double aspect,
    required double motionScore,
    required double fallScore,
    required int motionlessMs,
    required double confidence,
  }) = _PersonSignalImpl;

  factory PersonSignal.fromJson(Map<String, dynamic> jsonSerialization) {
    return PersonSignal(
      trackId: jsonSerialization['trackId'] as int,
      bboxN: _iggnejrg.Protocol().deserialize<_izkg6gr4.BBoxN>(
        jsonSerialization['bboxN'],
      ),
      footN: _iggnejrg.Protocol().deserialize<_ixjrd72v.PointN>(
        jsonSerialization['footN'],
      ),
      zoneIds: _iggnejrg.Protocol().deserialize<List<int>>(
        jsonSerialization['zoneIds'],
      ),
      torsoAngleDeg: (jsonSerialization['torsoAngleDeg'] as num?)?.toDouble(),
      hipDropRatio: (jsonSerialization['hipDropRatio'] as num?)?.toDouble(),
      aspect: (jsonSerialization['aspect'] as num).toDouble(),
      motionScore: (jsonSerialization['motionScore'] as num).toDouble(),
      fallScore: (jsonSerialization['fallScore'] as num).toDouble(),
      motionlessMs: jsonSerialization['motionlessMs'] as int,
      confidence: (jsonSerialization['confidence'] as num).toDouble(),
    );
  }

  int trackId;

  _izkg6gr4.BBoxN bboxN;

  _ixjrd72v.PointN footN;

  List<int> zoneIds;

  double? torsoAngleDeg;

  double? hipDropRatio;

  double aspect;

  double motionScore;

  double fallScore;

  int motionlessMs;

  double confidence;

  /// Returns a shallow copy of this [PersonSignal]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  PersonSignal copyWith({
    int? trackId,
    _izkg6gr4.BBoxN? bboxN,
    _ixjrd72v.PointN? footN,
    List<int>? zoneIds,
    double? torsoAngleDeg,
    double? hipDropRatio,
    double? aspect,
    double? motionScore,
    double? fallScore,
    int? motionlessMs,
    double? confidence,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PersonSignal',
      'trackId': trackId,
      'bboxN': bboxN.toJson(),
      'footN': footN.toJson(),
      'zoneIds': zoneIds.toJson(),
      if (torsoAngleDeg != null) 'torsoAngleDeg': torsoAngleDeg,
      if (hipDropRatio != null) 'hipDropRatio': hipDropRatio,
      'aspect': aspect,
      'motionScore': motionScore,
      'fallScore': fallScore,
      'motionlessMs': motionlessMs,
      'confidence': confidence,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PersonSignal',
      'trackId': trackId,
      'bboxN': bboxN.toJsonForProtocol(),
      'footN': footN.toJsonForProtocol(),
      'zoneIds': zoneIds.toJson(),
      if (torsoAngleDeg != null) 'torsoAngleDeg': torsoAngleDeg,
      if (hipDropRatio != null) 'hipDropRatio': hipDropRatio,
      'aspect': aspect,
      'motionScore': motionScore,
      'fallScore': fallScore,
      'motionlessMs': motionlessMs,
      'confidence': confidence,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PersonSignalImpl extends PersonSignal {
  _PersonSignalImpl({
    required int trackId,
    required _izkg6gr4.BBoxN bboxN,
    required _ixjrd72v.PointN footN,
    required List<int> zoneIds,
    double? torsoAngleDeg,
    double? hipDropRatio,
    required double aspect,
    required double motionScore,
    required double fallScore,
    required int motionlessMs,
    required double confidence,
  }) : super._(
         trackId: trackId,
         bboxN: bboxN,
         footN: footN,
         zoneIds: zoneIds,
         torsoAngleDeg: torsoAngleDeg,
         hipDropRatio: hipDropRatio,
         aspect: aspect,
         motionScore: motionScore,
         fallScore: fallScore,
         motionlessMs: motionlessMs,
         confidence: confidence,
       );

  /// Returns a shallow copy of this [PersonSignal]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  PersonSignal copyWith({
    int? trackId,
    _izkg6gr4.BBoxN? bboxN,
    _ixjrd72v.PointN? footN,
    List<int>? zoneIds,
    Object? torsoAngleDeg = _Undefined,
    Object? hipDropRatio = _Undefined,
    double? aspect,
    double? motionScore,
    double? fallScore,
    int? motionlessMs,
    double? confidence,
  }) {
    return PersonSignal(
      trackId: trackId ?? this.trackId,
      bboxN: bboxN ?? this.bboxN.copyWith(),
      footN: footN ?? this.footN.copyWith(),
      zoneIds: zoneIds ?? this.zoneIds.map((e0) => e0).toList(),
      torsoAngleDeg: torsoAngleDeg is double?
          ? torsoAngleDeg
          : this.torsoAngleDeg,
      hipDropRatio: hipDropRatio is double? ? hipDropRatio : this.hipDropRatio,
      aspect: aspect ?? this.aspect,
      motionScore: motionScore ?? this.motionScore,
      fallScore: fallScore ?? this.fallScore,
      motionlessMs: motionlessMs ?? this.motionlessMs,
      confidence: confidence ?? this.confidence,
    );
  }
}
