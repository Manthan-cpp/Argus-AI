import 'dart:async';
import 'package:web/web.dart' as web;

class SelectedVideoFile {
  final String name;
  final String url;
  final int size;

  const SelectedVideoFile({
    required this.name,
    required this.url,
    required this.size,
  });
}

Future<SelectedVideoFile?> pickVideoFile() {
  final completer = Completer<SelectedVideoFile?>();
  final input = web.HTMLInputElement()
    ..type = 'file'
    ..accept = 'video/mp4,video/webm,video/ogg';

  input.onChange.listen((event) {
    final files = input.files;
    if (files != null && files.length > 0) {
      final file = files.item(0)!;
      final url = web.URL.createObjectURL(file);
      completer.complete(SelectedVideoFile(
        name: file.name,
        url: url,
        size: file.size,
      ));
    } else {
      completer.complete(null);
    }
  });

  input.click();
  return completer.future;
}
