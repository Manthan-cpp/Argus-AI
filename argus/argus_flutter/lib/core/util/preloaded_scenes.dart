class PreloadedScene {
  final String id;
  final String name;
  final String description;
  final String imageUrl;

  const PreloadedScene({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });
}

const List<PreloadedScene> kPreloadedScenes = [
  PreloadedScene(
    id: 'demo_s1_lab_entry.mp4',
    name: 'Chemical Lab 01 · Entrance',
    description: 'Cleanroom doorway, analytical benches, fume hood corridor',
    imageUrl: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=1280&q=80',
  ),
  PreloadedScene(
    id: 'demo_s2_fall_stairs.mp4',
    name: 'Staircase East · Flight & Landing',
    description: 'Emergency exit staircase, step risers, safety handrails',
    imageUrl: 'https://images.unsplash.com/photo-1513694203232-719a280e022f?w=1280&q=80',
  ),
  PreloadedScene(
    id: 'demo_s3_restricted_zone.json',
    name: 'Restricted Hazard Zone · Factory Floor',
    description: 'Heavy equipment perimeter, yellow caution boundary',
    imageUrl: 'https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?w=1280&q=80',
  ),
  PreloadedScene(
    id: 'demo_s4_ppe_check.mp4',
    name: 'Construction Bay North · Machinery Dock',
    description: 'Loading bay, scaffolding zones, personal protective gear checkpoint',
    imageUrl: 'https://images.unsplash.com/photo-1541888946425-d0fbb186156f?w=1280&q=80',
  ),
];

String getPreloadedSceneFrame(String? sourceRef) {
  if (sourceRef == null || sourceRef.isEmpty) {
    return kPreloadedScenes.first.imageUrl;
  }
  for (final scene in kPreloadedScenes) {
    if (sourceRef.contains(scene.id) || scene.id.contains(sourceRef)) {
      return scene.imageUrl;
    }
  }
  // Fallback to first scene image
  return kPreloadedScenes.first.imageUrl;
}
