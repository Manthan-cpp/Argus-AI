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

Future<SelectedVideoFile?> pickVideoFile() async => null;
