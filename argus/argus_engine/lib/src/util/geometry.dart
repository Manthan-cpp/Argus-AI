import 'dart:math' as math;

/// 2D normalized coordinate (0.0 .. 1.0)
class Point2D {
  final double x;
  final double y;

  const Point2D(this.x, this.y);

  Map<String, dynamic> toJson() => {'x': x, 'y': y};
  factory Point2D.fromJson(Map<String, dynamic> json) =>
      Point2D((json['x'] as num).toDouble(), (json['y'] as num).toDouble());

  double distanceTo(Point2D other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return math.sqrt(dx * dx + dy * dy);
  }
}

/// Normalized bounding box
class BoundingBox {
  final double x;
  final double y;
  final double w;
  final double h;

  const BoundingBox({
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });

  Point2D get center => Point2D(x + w / 2, y + h / 2);
  Point2D get bottomCenter => Point2D(x + w / 2, y + h);
  double get aspectRatio => h > 0 ? w / h : 1.0;

  Map<String, dynamic> toJson() => {'x': x, 'y': y, 'w': w, 'h': h};
  factory BoundingBox.fromJson(Map<String, dynamic> json) => BoundingBox(
        x: (json['x'] as num).toDouble(),
        y: (json['y'] as num).toDouble(),
        w: (json['w'] as num).toDouble(),
        h: (json['h'] as num).toDouble(),
      );

  double intersectionOverUnion(BoundingBox other) {
    final x1 = math.max(x, other.x);
    final y1 = math.max(y, other.y);
    final x2 = math.min(x + w, other.x + other.w);
    final y2 = math.min(y + h, other.y + other.h);

    final intersectionW = math.max(0.0, x2 - x1);
    final intersectionH = math.max(0.0, y2 - y1);
    final intersectionArea = intersectionW * intersectionH;

    final area1 = w * h;
    final area2 = other.w * other.h;
    final unionArea = area1 + area2 - intersectionArea;

    if (unionArea <= 0) return 0.0;
    return intersectionArea / unionArea;
  }
}

/// Ray-casting algorithm to determine if a normalized point is inside a polygon
bool isPointInPolygon(Point2D point, List<Point2D> polygon) {
  if (polygon.length < 3) return false;

  bool inside = false;
  final n = polygon.length;

  for (int i = 0, j = n - 1; i < n; j = i++) {
    final xi = polygon[i].x;
    final yi = polygon[i].y;
    final xj = polygon[j].x;
    final yj = polygon[j].y;

    final intersect = ((yi > point.y) != (yj > point.y)) &&
        (point.x < (xj - xi) * (point.y - yi) / (yj - yi) + xi);

    if (intersect) {
      inside = !inside;
    }
  }

  return inside;
}
