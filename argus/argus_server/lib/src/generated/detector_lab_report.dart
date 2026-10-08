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
import 'lab_clip_result.dart' as _ie6zb0fp;

abstract class DetectorLabReport
    implements _is.SerializableModel, _is.ProtocolSerialization {
  DetectorLabReport._({
    required this.clips,
    required this.precision,
    required this.recall,
    required this.generatedAt,
    required this.notes,
  });

  factory DetectorLabReport({
    required List<_ie6zb0fp.LabClipResult> clips,
    required double precision,
    required double recall,
    required DateTime generatedAt,
    required String notes,
  }) = _DetectorLabReportImpl;

  factory DetectorLabReport.fromJson(Map<String, dynamic> jsonSerialization) {
    return DetectorLabReport(
      clips: _iggnejrg.Protocol().deserialize<List<_ie6zb0fp.LabClipResult>>(
        jsonSerialization['clips'],
      ),
      precision: (jsonSerialization['precision'] as num).toDouble(),
      recall: (jsonSerialization['recall'] as num).toDouble(),
      generatedAt: _is.DateTimeJsonExtension.fromJson(
        jsonSerialization['generatedAt'],
      ),
      notes: jsonSerialization['notes'] as String,
    );
  }

  List<_ie6zb0fp.LabClipResult> clips;

  double precision;

  double recall;

  DateTime generatedAt;

  String notes;

  /// Returns a shallow copy of this [DetectorLabReport]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  DetectorLabReport copyWith({
    List<_ie6zb0fp.LabClipResult>? clips,
    double? precision,
    double? recall,
    DateTime? generatedAt,
    String? notes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'DetectorLabReport',
      'clips': clips.toJson(valueToJson: (v) => v.toJson()),
      'precision': precision,
      'recall': recall,
      'generatedAt': generatedAt.toJson(),
      'notes': notes,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'DetectorLabReport',
      'clips': clips.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'precision': precision,
      'recall': recall,
      'generatedAt': generatedAt.toJson(),
      'notes': notes,
    };
  }

  @override
  String toString() {
    return _is.SerializationManager.encode(this);
  }
}

class _DetectorLabReportImpl extends DetectorLabReport {
  _DetectorLabReportImpl({
    required List<_ie6zb0fp.LabClipResult> clips,
    required double precision,
    required double recall,
    required DateTime generatedAt,
    required String notes,
  }) : super._(
         clips: clips,
         precision: precision,
         recall: recall,
         generatedAt: generatedAt,
         notes: notes,
       );

  /// Returns a shallow copy of this [DetectorLabReport]
  /// with some or all fields replaced by the given arguments.
  @_is.useResult
  @override
  DetectorLabReport copyWith({
    List<_ie6zb0fp.LabClipResult>? clips,
    double? precision,
    double? recall,
    DateTime? generatedAt,
    String? notes,
  }) {
    return DetectorLabReport(
      clips: clips ?? this.clips.map((e0) => e0.copyWith()).toList(),
      precision: precision ?? this.precision,
      recall: recall ?? this.recall,
      generatedAt: generatedAt ?? this.generatedAt,
      notes: notes ?? this.notes,
    );
  }
}
