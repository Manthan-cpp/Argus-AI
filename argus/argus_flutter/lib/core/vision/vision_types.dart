class VisionStats {
  final double fps;
  final int latencyMs;
  final int trackCount;
  final String mode;
  final int degradeLevel;
  final bool isMediaPipeLoaded;

  const VisionStats({
    this.fps = 0.0,
    this.latencyMs = 0,
    this.trackCount = 0,
    this.mode = 'live',
    this.degradeLevel = 0,
    this.isMediaPipeLoaded = false,
  });

  factory VisionStats.fromJson(Map<String, dynamic> json) {
    return VisionStats(
      fps: (json['fps'] as num?)?.toDouble() ?? 0.0,
      latencyMs: (json['latencyMs'] as num?)?.toInt() ?? 0,
      trackCount: (json['trackCount'] as num?)?.toInt() ?? 0,
      mode: json['mode'] as String? ?? 'live',
      degradeLevel: (json['degradeLevel'] as num?)?.toInt() ?? 0,
      isMediaPipeLoaded: json['isMediaPipeLoaded'] as bool? ?? false,
    );
  }
}

class VisionStatusInfo {
  final String status;
  final String detail;
  final double fps;
  final int latencyMs;

  const VisionStatusInfo({
    required this.status,
    required this.detail,
    this.fps = 0.0,
    this.latencyMs = 0,
  });

  factory VisionStatusInfo.fromJson(Map<String, dynamic> json) {
    return VisionStatusInfo(
      status: json['status'] as String? ?? 'idle',
      detail: json['detail'] as String? ?? '',
      fps: (json['fps'] as num?)?.toDouble() ?? 0.0,
      latencyMs: (json['latencyMs'] as num?)?.toInt() ?? 0,
    );
  }
}
