import 'dart:async';
import 'vision_controller.dart';
import 'vision_types.dart';

VisionController createVisionController() => VisionControllerStub();

class VisionControllerStub implements VisionController {
  bool _isRunning = false;
  VisionStats _stats = const VisionStats();
  void Function(Map<String, dynamic>)? _signalCallback;
  void Function(VisionStatusInfo)? _statusCallback;
  Timer? _simTimer;

  @override
  bool get isRunning => _isRunning;

  @override
  VisionStats get currentStats => _stats;

  @override
  Future<void> initialize({
    String? wasmBaseUrl,
    String? detectorModelPath,
    String? poseModelPath,
  }) async {
    _statusCallback?.call(const VisionStatusInfo(
      status: 'ready',
      detail: 'Stub/Simulation engine ready',
      fps: 30.0,
      latencyMs: 5,
    ));
  }

  @override
  Future<void> start({
    int targetFps = 8,
    String sourceKind = 'webcam',
    String? sourceUrl,
  }) async {
    _isRunning = true;
    _stats = VisionStats(
      fps: targetFps.toDouble(),
      latencyMs: 12,
      trackCount: 1,
      mode: 'live',
      degradeLevel: 0,
      isMediaPipeLoaded: false,
    );
    _statusCallback?.call(VisionStatusInfo(
      status: 'running',
      detail: 'Simulation feed active ($sourceKind)',
      fps: targetFps.toDouble(),
      latencyMs: 12,
    ));

    _simTimer = Timer.periodic(const Duration(milliseconds: 500), (t) {
      if (!_isRunning) return;
      _signalCallback?.call({
        'cameraId': 1,
        'sentAtMs': DateTime.now().millisecondsSinceEpoch,
        'seq': t.tick,
        'signals': [
          {
            'tsMs': DateTime.now().millisecondsSinceEpoch,
            'kind': 'heartbeat',
            'personCount': 1,
            'persons': [
              {
                'trackId': 1,
                'bboxN': {'x': 0.35, 'y': 0.25, 'w': 0.18, 'h': 0.52},
                'footN': {'x': 0.44, 'y': 0.77},
                'zoneIds': [1],
                'aspect': 0.35,
                'torsoAngleDeg': 6.0,
                'hipDropRatio': 0.0,
                'motionScore': 0.22,
                'fallScore': 0.05,
                'motionlessMs': 0,
                'confidence': 0.94
              }
            ]
          }
        ]
      });
    });
  }

  @override
  Future<void> stop() async {
    _isRunning = false;
    _simTimer?.cancel();
    _statusCallback?.call(const VisionStatusInfo(
      status: 'stopped',
      detail: 'Simulation feed stopped',
    ));
  }

  @override
  void setZones(List<Map<String, dynamic>> zones) {}

  @override
  void setMode(String mode) {
    _stats = VisionStats(mode: mode);
  }

  @override
  void onSignals(void Function(Map<String, dynamic> batchJson) callback) {
    _signalCallback = callback;
  }

  @override
  void onStatus(void Function(VisionStatusInfo status) callback) {
    _statusCallback = callback;
  }

  @override
  Future<String?> captureSnapshot({bool blurHead = true}) async {
    return 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP...';
  }

  @override
  Future<String?> captureVerificationCrop(int trackId) async {
    return 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEASABIAAD/2wBDAP...';
  }

  @override
  void loadReplay(Map<String, dynamic> replayData) {}

  @override
  void recordReplay(bool enable) {}

  @override
  Map<String, dynamic>? getRecordedReplay() => null;
}
