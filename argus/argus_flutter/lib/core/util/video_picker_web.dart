import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

class SelectedVideoFile {
  final String name;
  final String url;
  final int size;
  final String? firstFrameDataUrl;

  const SelectedVideoFile({
    required this.name,
    required this.url,
    required this.size,
    this.firstFrameDataUrl,
  });
}

Future<String?> extractVideoFirstFrame(String videoUrl) {
  if (videoUrl.isEmpty || videoUrl == 'local') return Future.value(null);

  // If already a data URL or image URL
  if (videoUrl.startsWith('data:image/') ||
      videoUrl.endsWith('.jpg') ||
      videoUrl.endsWith('.jpeg') ||
      videoUrl.endsWith('.png') ||
      videoUrl.startsWith('http://images.') ||
      videoUrl.startsWith('https://images.')) {
    return Future.value(videoUrl);
  }

  final completer = Completer<String?>();
  final video = web.document.createElement('video') as web.HTMLVideoElement;
  video.src = videoUrl;
  video.crossOrigin = 'anonymous';
  video.preload = 'auto';
  video.muted = true;
  video.playsInline = true;

  bool finished = false;

  void capture() {
    if (finished) return;
    finished = true;
    try {
      final canvas = web.document.createElement('canvas') as web.HTMLCanvasElement;
      final w = video.videoWidth > 0 ? video.videoWidth : 1280;
      final h = video.videoHeight > 0 ? video.videoHeight : 720;
      canvas.width = w;
      canvas.height = h;
      final ctx = canvas.getContext('2d') as web.CanvasRenderingContext2D;
      ctx.drawImage(video, 0, 0);
      final dataUrl = canvas.toDataURL('image/jpeg', 0.92.toJS);
      completer.complete(dataUrl);
    } catch (_) {
      completer.complete(null);
    }
  }

  video.onseeked = ((web.Event _) {
    capture();
  }).toJS;

  video.onloadeddata = ((web.Event _) {
    video.currentTime = 0.05;
  }).toJS;

  video.onerror = ((web.Event _) {
    if (!finished) {
      finished = true;
      completer.complete(null);
    }
  }).toJS;

  // Fallback timeout in case onloadeddata was slow or didn't trigger
  Future.delayed(const Duration(milliseconds: 3000), () {
    if (!finished) {
      finished = true;
      try {
        if (video.readyState >= 2) {
          capture();
        } else {
          completer.complete(null);
        }
      } catch (_) {
        completer.complete(null);
      }
    }
  });

  return completer.future;
}

Future<SelectedVideoFile?> pickVideoFile() {
  final completer = Completer<SelectedVideoFile?>();
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = 'video/mp4,video/webm,video/ogg';

  input.onChange.listen((event) async {
    final files = input.files;
    if (files != null && files.length > 0) {
      final file = files.item(0)!;
      final url = web.URL.createObjectURL(file);
      final frameUrl = await extractVideoFirstFrame(url);
      completer.complete(SelectedVideoFile(
        name: file.name,
        url: url,
        size: file.size,
        firstFrameDataUrl: frameUrl,
      ));
    } else {
      completer.complete(null);
    }
  });

  input.click();
  return completer.future;
}
