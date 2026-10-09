import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web/web.dart' as web;

@JS('argusStartWebcamPreview')
external JSPromise<JSBoolean>? _jsStartWebcamPreview(JSString elementId);

@JS('argusStopWebcamPreview')
external void _jsStopWebcamPreview(JSString elementId);

class ZoneWebcamPreview extends StatefulWidget {
  const ZoneWebcamPreview({super.key});

  @override
  State<ZoneWebcamPreview> createState() => _ZoneWebcamPreviewWebState();
}

class _ZoneWebcamPreviewWebState extends State<ZoneWebcamPreview> {
  static bool _factoryRegistered = false;
  static const String _viewType = 'argus-zone-webcam-view';
  static const String _elementId = 'argus-zone-webcam-element';

  bool _isConnecting = true;
  bool _hasError = false;
  Timer? _connectTimer;

  @override
  void initState() {
    super.initState();
    _ensureViewFactory();
    _initWebcam();
  }

  void _ensureViewFactory() {
    if (_factoryRegistered) return;
    _factoryRegistered = true;

    ui_web.platformViewRegistry.registerViewFactory(
      _viewType,
      (int viewId) {
        final video = web.document.createElement('video') as web.HTMLVideoElement;
        video.id = _elementId;
        video.autoplay = true;
        video.playsInline = true;
        video.muted = true;
        video.style.width = '100%';
        video.style.height = '100%';
        video.style.objectFit = 'cover';
        video.style.pointerEvents = 'none';
        return video;
      },
    );
  }

  void _initWebcam() {
    // Small delay to allow the HtmlElementView to mount into the DOM tree
    _connectTimer = Timer(const Duration(milliseconds: 300), () async {
      if (!mounted) return;
      try {
        final promise = _jsStartWebcamPreview(_elementId.toJS);
        if (promise != null) {
          final res = await promise.toDart;
          if (mounted) {
            setState(() {
              _isConnecting = false;
              _hasError = !res.toDart;
            });
          }
        } else {
          if (mounted) {
            setState(() {
              _isConnecting = false;
              _hasError = false;
            });
          }
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _isConnecting = false;
            _hasError = true;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _connectTimer?.cancel();
    try {
      _jsStopWebcamPreview(_elementId.toJS);
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Live HTML video element with pointer-events disabled
        const IgnorePointer(
          child: HtmlElementView(viewType: _viewType),
        ),

        // Connecting spinner overlay
        if (_isConnecting)
          Container(
            color: const Color(0xFF070A0F),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.cyanAccent),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Connecting live webcam feed...',
                    style: GoogleFonts.inter(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),

        // Error message if access denied
        if (_hasError)
          Container(
            color: const Color(0xFF0F172A),
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.videocam_off_rounded, size: 40, color: Colors.amberAccent),
                  const SizedBox(height: 10),
                  Text(
                    'Webcam feed unavailable',
                    style: GoogleFonts.sora(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Please grant camera permissions or ensure no other app is using your webcam.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(color: Colors.white60, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
