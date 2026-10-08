import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:web/web.dart' as web;
import 'vision_controller.dart';
import 'vision_types.dart';

VisionController createVisionController() => VisionControllerWeb();

@JS('argusVision')
external ArgusVisionJS? get _argusVision;

@JS('JSON.stringify')
external JSString _jsStringify(JSAny? value);

@JS()
@staticInterop
class ArgusVisionJS {}

extension ArgusVisionJSExt on ArgusVisionJS {
  external JSPromise init([JSAny? options]);
  external JSBoolean attach(JSAny elements);
  external JSPromise start([JSAny? options]);
  external void stop();
  external void setZones(JSAny zones);
  external void setMode(JSString mode);
  external void onSignals(JSFunction callback);
  external void onStatus(JSFunction callback);
  external JSPromise snapshot([JSAny? options]);
  external JSPromise verificationCrop([JSAny? options]);
  external JSAny? getStats();
  external void recordReplay(JSBoolean enable);
  external void loadReplay(JSAny replayData);
  external JSAny? getRecordedReplay();
}

class VisionControllerWeb implements VisionController {
  bool _isRunning = false;
  final VisionStats _stats = const VisionStats();
  void Function(Map<String, dynamic>)? _signalCallback;
  void Function(VisionStatusInfo)? _statusCallback;
  static bool _viewRegistered = false;

  VisionControllerWeb() {
    _registerViewFactory();
  }

  void _registerViewFactory() {
    if (_viewRegistered) return;
    _viewRegistered = true;

    ui_web.platformViewRegistry.registerViewFactory(
      'argus-vision-stage',
      (int viewId) {
        final container = web.document.createElement('div') as web.HTMLDivElement;
        container.id = 'argus-vision-container';
        container.style.position = 'relative';
        container.style.width = '100%';
        container.style.height = '100%';
        container.style.backgroundColor = '#000000';
        container.style.overflow = 'hidden';
        container.style.borderRadius = '12px';

        final video = web.document.createElement('video') as web.HTMLVideoElement;
        video.id = 'argus-video-element';
        video.autoplay = true;
        video.playsInline = true;
        video.muted = true;
        video.style.width = '100%';
        video.style.height = '100%';
        video.style.objectFit = 'contain';

        final canvas = web.document.createElement('canvas') as web.HTMLCanvasElement;
        canvas.id = 'argus-canvas-element';
        canvas.style.position = 'absolute';
        canvas.style.top = '0';
        canvas.style.left = '0';
        canvas.style.width = '100%';
        canvas.style.height = '100%';
        canvas.style.pointerEvents = 'none';

        container.appendChild(video);
        container.appendChild(canvas);

        return container;
      },
    );
  }

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
    final v = _argusVision;
    if (v == null) {
      _statusCallback?.call(const VisionStatusInfo(
        status: 'fallback',
        detail: 'argusVision JS bridge not loaded yet',
      ));
      return;
    }

    // Set callbacks
    v.onSignals(((JSAny batch) {
      try {
        String jsonStr;
        if (batch.isA<JSString>()) {
          jsonStr = (batch as JSString).toDart;
        } else {
          jsonStr = _jsStringify(batch).toDart;
        }
        final decoded = json.decode(jsonStr) as Map<String, dynamic>;
        _signalCallback?.call(decoded);
      } catch (e) {
        web.console.error('VisionController onSignals error: $e'.toJS);
      }
    }).toJS);

    v.onStatus(((JSAny status) {
      try {
        String jsonStr;
        if (status.isA<JSString>()) {
          jsonStr = (status as JSString).toDart;
        } else {
          jsonStr = _jsStringify(status).toDart;
        }
        final decoded = json.decode(jsonStr) as Map<String, dynamic>;
        _statusCallback?.call(VisionStatusInfo.fromJson(decoded));
      } catch (e) {
        web.console.error('VisionController onStatus error: $e'.toJS);
      }
    }).toJS);

    final options = <String, dynamic>{
      if (wasmBaseUrl != null) 'wasmBaseUrl': wasmBaseUrl,
      if (detectorModelPath != null) 'detectorModelPath': detectorModelPath,
      if (poseModelPath != null) 'poseModelPath': poseModelPath,
    };

    final jsOpts = json.encode(options).toJS;
    await v.init(jsOpts).toDart;
  }

  @override
  Future<void> start({
    int targetFps = 8,
    String sourceKind = 'webcam',
    String? sourceUrl,
  }) async {
    final v = _argusVision;
    if (v == null) return;

    // Attach to HTML elements created by HtmlElementView or ensure fallback
    var video = web.document.getElementById('argus-video-element') as web.HTMLVideoElement?;
    var canvas = web.document.getElementById('argus-canvas-element') as web.HTMLCanvasElement?;

    if (video == null || canvas == null) {
      final container = web.document.getElementById('argus-vision-container') ?? web.document.createElement('div');
      container.id = 'argus-vision-container';
      if (video == null) {
        video = web.document.createElement('video') as web.HTMLVideoElement;
        video.id = 'argus-video-element';
        video.autoplay = true;
        video.playsInline = true;
        video.muted = true;
        video.style.width = '100%';
        video.style.height = '100%';
        video.style.objectFit = 'contain';
        container.appendChild(video);
      }
      if (canvas == null) {
        canvas = web.document.createElement('canvas') as web.HTMLCanvasElement;
        canvas.id = 'argus-canvas-element';
        canvas.style.position = 'absolute';
        canvas.style.top = '0';
        canvas.style.left = '0';
        canvas.style.width = '100%';
        canvas.style.height = '100%';
        canvas.style.pointerEvents = 'none';
        container.appendChild(canvas);
      }
      if (container.parentElement == null) {
        web.document.body?.appendChild(container);
      }
    }

    final attachPayload = <String, dynamic>{
      'videoId': 'argus-video-element',
      'canvasId': 'argus-canvas-element',
    };
    v.attach(json.encode(attachPayload).toJS);

    final startOpts = <String, dynamic>{
      'targetFps': targetFps,
      'sourceKind': sourceKind,
      if (sourceUrl != null) 'sourceUrl': sourceUrl,
    };

    await v.start(json.encode(startOpts).toJS).toDart;
    _isRunning = true;
  }

  @override
  Future<void> stop() async {
    final v = _argusVision;
    if (v != null) {
      v.stop();
    }
    _isRunning = false;
  }

  @override
  void setZones(List<Map<String, dynamic>> zones) {
    final v = _argusVision;
    if (v != null) {
      v.setZones(json.encode(zones).toJS);
    }
  }

  @override
  void setMode(String mode) {
    final v = _argusVision;
    if (v != null) {
      v.setMode(mode.toJS);
    }
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
    final v = _argusVision;
    if (v == null) return null;
    final opts = <String, dynamic>{'blurHead': blurHead, 'maxWidth': 640, 'quality': 0.75};
    final res = await v.snapshot(json.encode(opts).toJS).toDart;
    return (res as JSString?)?.toDart;
  }

  @override
  Future<String?> captureVerificationCrop(int trackId) async {
    final v = _argusVision;
    if (v == null) return null;
    final opts = <String, dynamic>{'trackId': trackId, 'quality': 0.8};
    final res = await v.verificationCrop(json.encode(opts).toJS).toDart;
    return (res as JSString?)?.toDart;
  }

  @override
  void loadReplay(Map<String, dynamic> replayData) {
    final v = _argusVision;
    if (v != null) {
      v.loadReplay(json.encode(replayData).toJS);
    }
  }

  @override
  void recordReplay(bool enable) {
    final v = _argusVision;
    if (v != null) {
      v.recordReplay(enable.toJS);
    }
  }

  @override
  Map<String, dynamic>? getRecordedReplay() {
    final v = _argusVision;
    if (v == null) return null;
    final res = v.getRecordedReplay();
    if (res == null) return null;
    try {
      final str = (res as JSString).toDart;
      return json.decode(str) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
