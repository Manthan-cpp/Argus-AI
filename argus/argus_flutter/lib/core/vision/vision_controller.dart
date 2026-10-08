import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'vision_types.dart';
import 'vision_controller_stub.dart'
    if (dart.library.js_interop) 'vision_controller_web.dart';

abstract class VisionController {
  bool get isRunning;
  VisionStats get currentStats;

  Future<void> initialize({
    String? wasmBaseUrl,
    String? detectorModelPath,
    String? poseModelPath,
  });

  Future<void> start({
    int targetFps = 8,
    String sourceKind = 'webcam',
    String? sourceUrl,
  });

  Future<void> stop();

  void setZones(List<Map<String, dynamic>> zones);

  void setMode(String mode);

  void onSignals(void Function(Map<String, dynamic> batchJson) callback);

  void onStatus(void Function(VisionStatusInfo status) callback);

  Future<String?> captureSnapshot({bool blurHead = true});

  Future<String?> captureVerificationCrop(int trackId);

  void loadReplay(Map<String, dynamic> replayData);

  void recordReplay(bool enable);

  Map<String, dynamic>? getRecordedReplay();

  factory VisionController() => createVisionController();
}

final visionControllerProvider = Provider<VisionController>((ref) {
  final controller = VisionController();
  ref.onDispose(() {
    controller.stop();
  });
  return controller;
});
