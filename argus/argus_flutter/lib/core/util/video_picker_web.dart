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
  bool finished = false;

  void finishWith(String? result) {
    if (finished) return;
    finished = true;
    if (!completer.isCompleted) {
      completer.complete(result);
    }
  }

  try {
    final video = web.document.createElement('video') as web.HTMLVideoElement;
    video.src = videoUrl;
    // Only set crossOrigin for remote http(s) URLs; NEVER for local blob: URLs
    if (videoUrl.startsWith('http://') || videoUrl.startsWith('https://')) {
      video.crossOrigin = 'anonymous';
    }
    video.preload = 'auto';
    video.muted = true;
    video.playsInline = true;

    void capture() {
      if (finished) return;
      try {
        final vw = video.videoWidth > 0 ? video.videoWidth : 640;
        final vh = video.videoHeight > 0 ? video.videoHeight : 360;
        final scale = vw > 640 ? 640.0 / vw : 1.0;
        final w = (vw * scale).round();
        final h = (vh * scale).round();

        final canvas = web.document.createElement('canvas') as web.HTMLCanvasElement;
        canvas.width = w;
        canvas.height = h;
        final ctx = canvas.getContext('2d') as web.CanvasRenderingContext2D?;
        if (ctx != null) {
          ctx.drawImage(video, 0, 0, w, h);
          final dataUrl = canvas.toDataURL('image/jpeg', 0.80.toJS);
          finishWith(dataUrl);
          return;
        }
      } catch (_) {}
      finishWith(null);
    }

    video.onseeked = ((web.Event _) {
      try {
        capture();
      } catch (_) {
        finishWith(null);
      }
    }).toJS;

    video.onloadeddata = ((web.Event _) {
      try {
        video.currentTime = 0.05;
      } catch (_) {
        capture();
      }
    }).toJS;

    video.onerror = ((web.Event _) {
      finishWith(null);
    }).toJS;

    // Safety timeout in case video format cannot seek or decoder is slow
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (!finished) {
        try {
          if (video.readyState >= 2) {
            capture();
          } else {
            finishWith(null);
          }
        } catch (_) {
          finishWith(null);
        }
      }
    });
  } catch (_) {
    finishWith(null);
  }

  return completer.future;
}

Future<SelectedVideoFile?> pickVideoFile() {
  final completer = Completer<SelectedVideoFile?>();

  void finishWith(SelectedVideoFile? result) {
    if (!completer.isCompleted) {
      completer.complete(result);
    }
  }

  try {
    final input = web.HTMLInputElement()
      ..type = 'file'
      ..accept = 'video/mp4,video/webm,video/ogg,video/*';

    input.onChange.listen((event) async {
      try {
        final files = input.files;
        if (files != null && files.length > 0) {
          final file = files.item(0)!;
          final url = web.URL.createObjectURL(file);
          final frameUrl = await extractVideoFirstFrame(url);
          finishWith(SelectedVideoFile(
            name: file.name,
            url: url,
            size: file.size,
            firstFrameDataUrl: frameUrl,
          ));
        } else {
          finishWith(null);
        }
      } catch (_) {
        finishWith(null);
      }
    });

    input.click();
  } catch (_) {
    finishWith(null);
  }

  return completer.future;
}
