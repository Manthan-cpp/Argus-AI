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

Future<SelectedVideoFile?> pickVideoFile() async => null;
Future<String?> extractVideoFirstFrame(String videoUrl) async => null;
