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

abstract class EvidenceUpload
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  EvidenceUpload._({
    required this.incidentId,
    required this.snapshotJpegBase64,
    this.verificationCropJpeg,
  });

  factory EvidenceUpload({
    required int incidentId,
    required String snapshotJpegBase64,
    String? verificationCropJpeg,
  }) = _EvidenceUploadImpl;

  factory EvidenceUpload.fromJson(Map<String, dynamic> jsonSerialization) {
    return EvidenceUpload(
      incidentId: jsonSerialization['incidentId'] as int,
      snapshotJpegBase64: jsonSerialization['snapshotJpegBase64'] as String,
      verificationCropJpeg:
          jsonSerialization['verificationCropJpeg'] as String?,
    );
  }

  int incidentId;

  String snapshotJpegBase64;

  String? verificationCropJpeg;

  /// Returns a shallow copy of this [EvidenceUpload]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  EvidenceUpload copyWith({
    int? incidentId,
    String? snapshotJpegBase64,
    String? verificationCropJpeg,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'EvidenceUpload',
      'incidentId': incidentId,
      'snapshotJpegBase64': snapshotJpegBase64,
      if (verificationCropJpeg != null)
        'verificationCropJpeg': verificationCropJpeg,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'EvidenceUpload',
      'incidentId': incidentId,
      'snapshotJpegBase64': snapshotJpegBase64,
      if (verificationCropJpeg != null)
        'verificationCropJpeg': verificationCropJpeg,
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _EvidenceUploadImpl extends EvidenceUpload {
  _EvidenceUploadImpl({
    required int incidentId,
    required String snapshotJpegBase64,
    String? verificationCropJpeg,
  }) : super._(
         incidentId: incidentId,
         snapshotJpegBase64: snapshotJpegBase64,
         verificationCropJpeg: verificationCropJpeg,
       );

  /// Returns a shallow copy of this [EvidenceUpload]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  EvidenceUpload copyWith({
    int? incidentId,
    String? snapshotJpegBase64,
    Object? verificationCropJpeg = _Undefined,
  }) {
    return EvidenceUpload(
      incidentId: incidentId ?? this.incidentId,
      snapshotJpegBase64: snapshotJpegBase64 ?? this.snapshotJpegBase64,
      verificationCropJpeg: verificationCropJpeg is String?
          ? verificationCropJpeg
          : this.verificationCropJpeg,
    );
  }
}
