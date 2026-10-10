import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:argus_client/argus_client.dart';
import '../../app/theme/tokens.dart';
import '../../core/util/preloaded_scenes.dart';
import '../../core/util/video_picker.dart';
import '../../core/vision/vision_controller.dart';
import '../../core/widgets/zone_webcam_preview.dart';
import '../../data/repository_provider.dart';
import '../facilities/facility_providers.dart';

enum EditorTool {
  select,   // ✋ Grab & move whole zones or reshape corner vertices
  freehand, // ✏️ Draw freely with real-life neon brush & auto-precision polygon
  polygon,  // 📐 Click point-by-point with magnetic snap-to-close
}

class ZoneEditorScreen extends ConsumerStatefulWidget {
  final int cameraId;

  const ZoneEditorScreen({super.key, required this.cameraId});

  @override
  ConsumerState<ZoneEditorScreen> createState() => _ZoneEditorScreenState();
}

class _ZoneEditorScreenState extends ConsumerState<ZoneEditorScreen>
    with SingleTickerProviderStateMixin {
  Camera? _camera;
  String? _staticFrameUrl;
  bool _isExtractingFrame = false;

  List<Zone> _zones = [];
  Zone? _activeZone;
  bool _isLoading = true;

  // Active Tool Mode
  EditorTool _currentTool = EditorTool.select;

  // Freehand Drawing State
  final List<Offset> _freehandStroke = [];
  bool _isFreehandDrawing = false;

  // Precision Polygon Pen Draft
  final List<PointN> _draftPoints = [];
  final List<PointN> _redoPoints = [];

  // Mouse Hover & Snapping
  Offset? _mouseCursorPos;
  bool _isNearFirstPoint = false;

  // Dragging State (Whole-Zone vs Single Vertex)
  bool _isDraggingWholeZone = false;
  int? _draggedVertexIndex;
  Offset? _dragStartScreenPos;
  List<PointN>? _initialPolygonBeforeDrag;
  Offset? _currentDragDeltaNormalized;

  // Animation Controller for Real Drawing Glow & Pulse
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    // Release any running vision engine from monitor screen to free webcam
    final vision = ref.read(visionControllerProvider);
    if (vision.isRunning) {
      vision.stop();
    }

    _loadZones();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadZones() async {
    final repo = ref.read(argusRepositoryProvider);
    final activeWs = ref.read(activeFacilityProvider);
    var cameras = await repo.listCameras(workspaceId: activeWs?.id);
    var cam = cameras.where((c) => c.id == widget.cameraId).firstOrNull;
    if (cam == null) {
      cameras = await repo.listCameras();
      cam = cameras.where((c) => c.id == widget.cameraId).firstOrNull;
    }
    final list = await repo.listZones(widget.cameraId);

    String? frameUrl;
    final targetCam = cam;
    if (targetCam != null && targetCam.sourceKind != 'webcam') {
      final cache = ref.read(cameraStaticFrameProvider);
      if (cache.containsKey(targetCam.id)) {
        frameUrl = cache[targetCam.id];
      } else if (targetCam.sourceRef.startsWith('blob:') || targetCam.sourceRef.startsWith('http') || targetCam.sourceRef.endsWith('.mp4')) {
        try {
          frameUrl = await extractVideoFirstFrame(targetCam.sourceRef);
          if (frameUrl != null && targetCam.id != null) {
            ref.read(cameraStaticFrameProvider.notifier).update((m) => {...m, targetCam.id!: frameUrl!});
          }
        } catch (_) {}
      }

      frameUrl ??= getPreloadedSceneFrame(targetCam.sourceRef);
      if (targetCam.id != null) {
        ref.read(cameraStaticFrameProvider.notifier).update((m) => {...m, targetCam.id!: frameUrl!});
      }
    }

    if (mounted) {
      setState(() {
        _camera = cam;
        _staticFrameUrl = frameUrl;
        _zones = list;
        if (list.isNotEmpty && _activeZone == null) {
          _activeZone = list.first;
        } else if (_activeZone != null) {
          final found = list.where((z) => z.id == _activeZone!.id);
          _activeZone = found.isNotEmpty ? found.first : (list.isNotEmpty ? list.first : null);
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _pickVideoForCamera() async {
    final file = await pickVideoFile();
    if (file != null) {
      setState(() => _isExtractingFrame = true);
      String? frame = file.firstFrameDataUrl;
      frame ??= await extractVideoFirstFrame(file.url);
      frame ??= getPreloadedSceneFrame(null);

      final current = _camera ?? Camera(
        id: widget.cameraId,
        workspaceId: 1,
        name: file.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''),
        sourceKind: 'file',
        sourceRef: file.url,
        enabled: true,
        createdAt: DateTime.now(),
        status: 'online',
      );
      final updatedCam = current.copyWith(
        sourceRef: file.url,
        sourceKind: 'file',
      );
      final repo = ref.read(argusRepositoryProvider);
      await repo.saveCamera(updatedCam);

      if (updatedCam.id != null) {
        ref.read(cameraStaticFrameProvider.notifier).update(
          (m) => {...m, updatedCam.id!: frame!},
        );
      }

      if (mounted) {
        setState(() {
          _camera = updatedCam;
          _staticFrameUrl = frame;
          _isExtractingFrame = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1E293B),
            content: Text('Loaded "${file.name}". Static first frame updated for zone drawing.'),
          ),
        );
      }
    }
  }

  // ==========================================
  // MATHEMATICAL GEOMETRY & RDP PRECISION
  // ==========================================

  /// Ray-casting test to determine if point is inside polygon
  bool _isPointInPolygon(Offset pt, List<PointN> poly, Size size) {
    if (poly.length < 3) return false;
    final x = pt.dx / size.width;
    final y = pt.dy / size.height;
    bool inside = false;
    for (int i = 0, j = poly.length - 1; i < poly.length; j = i++) {
      final xi = poly[i].x, yi = poly[i].y;
      final xj = poly[j].x, yj = poly[j].y;
      final intersect = ((yi > y) != (yj > y)) &&
          (x < (xj - xi) * (y - yi) / (yj - yi) + xi);
      if (intersect) inside = !inside;
    }
    return inside;
  }

  /// Calculates center of mass (centroid) of polygon in screen coordinates
  Offset _getCentroid(List<PointN> poly, Size size) {
    if (poly.isEmpty) return Offset.zero;
    double cx = 0, cy = 0;
    for (final p in poly) {
      cx += p.x * size.width;
      cy += p.y * size.height;
    }
    return Offset(cx / poly.length, cy / poly.length);
  }

  /// Perpendicular distance from PointN to segment AB
  double _perpendicularDistance(PointN p, PointN a, PointN b) {
    final dx = b.x - a.x;
    final dy = b.y - a.y;
    if (dx == 0 && dy == 0) {
      return math.sqrt(math.pow(p.x - a.x, 2) + math.pow(p.y - a.y, 2));
    }
    final num = (dy * p.x - dx * p.y + b.x * a.y - b.y * a.x).abs();
    final den = math.sqrt(dx * dx + dy * dy);
    return num / den;
  }

  /// Ramer-Douglas-Peucker polygon simplification algorithm
  List<PointN> _rdp(List<PointN> points, double epsilon) {
    if (points.length < 3) return points;

    double maxDist = 0.0;
    int maxIdx = 0;
    final start = points.first;
    final end = points.last;

    for (int i = 1; i < points.length - 1; i++) {
      final dist = _perpendicularDistance(points[i], start, end);
      if (dist > maxDist) {
        maxDist = dist;
        maxIdx = i;
      }
    }

    if (maxDist > epsilon) {
      final left = _rdp(points.sublist(0, maxIdx + 1), epsilon);
      final right = _rdp(points.sublist(maxIdx), epsilon);
      return [...left.sublist(0, left.length - 1), ...right];
    } else {
      return [start, end];
    }
  }

  /// Downsamples a freehand hand-drawn stroke into an optimal precision polygon
  List<PointN> _simplifyFreehandStroke(List<Offset> stroke, Size size) {
    if (stroke.length < 4) return [];

    // 1. Convert to normalized PointN coordinates
    final rawPoints = stroke
        .map((o) => PointN(
              x: (o.dx / size.width).clamp(0.0, 1.0),
              y: (o.dy / size.height).clamp(0.0, 1.0),
            ))
        .toList();

    // 2. Auto-close if start and end are close or ensure closed loop
    final start = rawPoints.first;
    final end = rawPoints.last;
    final dist = math.sqrt(math.pow(start.x - end.x, 2) + math.pow(start.y - end.y, 2));
    if (dist > 0.03) {
      rawPoints.add(PointN(x: start.x, y: start.y));
    } else {
      rawPoints[rawPoints.length - 1] = PointN(x: start.x, y: start.y);
    }

    // 3. Find apex (point furthest from origin) to split closed loop cleanly
    int apexIdx = 0;
    double maxApexDist = 0.0;
    for (int i = 1; i < rawPoints.length; i++) {
      final d = math.sqrt(math.pow(rawPoints[i].x - start.x, 2) + math.pow(rawPoints[i].y - start.y, 2));
      if (d > maxApexDist) {
        maxApexDist = d;
        apexIdx = i;
      }
    }

    // If gesture has insufficient area, discard
    if (maxApexDist < 0.04) return [];

    // 4. Run RDP on both halves with precision threshold epsilon = 0.015
    const double epsilon = 0.014;
    final half1 = _rdp(rawPoints.sublist(0, apexIdx + 1), epsilon);
    final half2 = _rdp(rawPoints.sublist(apexIdx), epsilon);

    final merged = [...half1.sublist(0, half1.length - 1), ...half2];

    // Remove closing duplicate at the end if present
    if (merged.length > 3 &&
        (merged.first.x - merged.last.x).abs() < 0.005 &&
        (merged.first.y - merged.last.y).abs() < 0.005) {
      merged.removeLast();
    }

    return merged;
  }

  // ==========================================
  // GESTURE & INTERACTION HANDLERS
  // ==========================================

  void _onPointerHover(PointerHoverEvent event, Size canvasSize) {
    setState(() {
      _mouseCursorPos = event.localPosition;

      // Check magnetic snap to first point in polygon mode
      if (_currentTool == EditorTool.polygon && _draftPoints.isNotEmpty) {
        final firstPos = Offset(_draftPoints.first.x * canvasSize.width, _draftPoints.first.y * canvasSize.height);
        final dist = (event.localPosition - firstPos).distance;
        _isNearFirstPoint = dist <= 22.0 && _draftPoints.length >= 3;
      } else {
        _isNearFirstPoint = false;
      }
    });
  }

  void _onCanvasTap(TapUpDetails details, Size canvasSize) {
    final isGuard = ref.read(activeFacilityRoleProvider).toLowerCase() == 'guard';
    if (_currentTool == EditorTool.polygon) {
      if (isGuard) return;
      final normX = (details.localPosition.dx / canvasSize.width).clamp(0.0, 1.0);
      final normY = (details.localPosition.dy / canvasSize.height).clamp(0.0, 1.0);

      // Snap to close if clicked near first point and has at least 3 points
      if (_draftPoints.length >= 3 && _isNearFirstPoint) {
        _showSaveZoneDialog(isFreehand: false);
        return;
      }

      setState(() {
        _draftPoints.add(PointN(x: normX, y: normY));
        _redoPoints.clear();
      });
    } else if (_currentTool == EditorTool.select && !_isDraggingWholeZone && _draggedVertexIndex == null) {
      // Direct zone selection: tap inside any zone to select it immediately
      for (final z in _zones.reversed) {
        if (_isPointInPolygon(details.localPosition, z.polygon, canvasSize)) {
          setState(() {
            _activeZone = z;
          });
          break;
        }
      }
    }
  }

  void _onPanStart(DragStartDetails details, Size canvasSize) {
    final isGuard = ref.read(activeFacilityRoleProvider).toLowerCase() == 'guard';
    if (isGuard) return;

    final localPos = details.localPosition;
    _mouseCursorPos = localPos;

    // --- MODE 1: FREEHAND BRUSH ---
    if (_currentTool == EditorTool.freehand) {
      setState(() {
        _isFreehandDrawing = true;
        _freehandStroke.clear();
        _freehandStroke.add(localPos);
      });
      return;
    }

    // --- MODE 2: SELECT & MOVE (WHOLE-ZONE OR VERTICES) ---
    if (_currentTool == EditorTool.select) {
      // 1. Check if near any vertex in the active zone (within 20px)
      if (_activeZone != null) {
        for (int i = 0; i < _activeZone!.polygon.length; i++) {
          final vx = _activeZone!.polygon[i].x * canvasSize.width;
          final vy = _activeZone!.polygon[i].y * canvasSize.height;
          if ((localPos.dx - vx).abs() < 20 && (localPos.dy - vy).abs() < 20) {
            setState(() {
              _draggedVertexIndex = i;
              _isDraggingWholeZone = false;
            });
            return;
          }
        }

        // 2. Check if touching inside the active zone OR near its centroid handle
        final centroid = _getCentroid(_activeZone!.polygon, canvasSize);
        final distToCentroid = (localPos - centroid).distance;
        final insideActive = _isPointInPolygon(localPos, _activeZone!.polygon, canvasSize);

        if (insideActive || distToCentroid <= 32.0) {
          setState(() {
            _isDraggingWholeZone = true;
            _draggedVertexIndex = null;
            _dragStartScreenPos = localPos;
            _initialPolygonBeforeDrag = _activeZone!.polygon.map((p) => PointN(x: p.x, y: p.y)).toList();
            _currentDragDeltaNormalized = Offset.zero;
          });
          return;
        }
      }

      // 3. Check if user clicked inside ANY other zone: switch active zone & start dragging whole area!
      for (final z in _zones.reversed) {
        if (_isPointInPolygon(localPos, z.polygon, canvasSize)) {
          setState(() {
            _activeZone = z;
            _isDraggingWholeZone = true;
            _draggedVertexIndex = null;
            _dragStartScreenPos = localPos;
            _initialPolygonBeforeDrag = z.polygon.map((p) => PointN(x: p.x, y: p.y)).toList();
            _currentDragDeltaNormalized = Offset.zero;
          });
          return;
        }
      }

      _isDraggingWholeZone = false;
      _draggedVertexIndex = null;
    }
  }

  void _onPanUpdate(DragUpdateDetails details, Size canvasSize) {
    final localPos = details.localPosition;
    _mouseCursorPos = localPos;

    // --- FREEHAND BRUSH STROKE ACCUMULATION ---
    if (_currentTool == EditorTool.freehand && _isFreehandDrawing) {
      if (_freehandStroke.isEmpty || (localPos - _freehandStroke.last).distance >= 2.5) {
        setState(() {
          _freehandStroke.add(localPos);
        });
      }
      return;
    }

    // --- WHOLE-ZONE RIGID TRANSLATION ---
    if (_currentTool == EditorTool.select && _isDraggingWholeZone && _initialPolygonBeforeDrag != null) {
      final dx = (localPos.dx - _dragStartScreenPos!.dx) / canvasSize.width;
      final dy = (localPos.dy - _dragStartScreenPos!.dy) / canvasSize.height;

      // Calculate bounds of initial polygon to safely clamp within [0.0, 1.0]
      double minX = 1.0, maxX = 0.0, minY = 1.0, maxY = 0.0;
      for (final p in _initialPolygonBeforeDrag!) {
        if (p.x < minX) minX = p.x;
        if (p.x > maxX) maxX = p.x;
        if (p.y < minY) minY = p.y;
        if (p.y > maxY) maxY = p.y;
      }

      final clampedDx = dx.clamp(-minX, 1.0 - maxX);
      final clampedDy = dy.clamp(-minY, 1.0 - maxY);

      final updatedPoly = _initialPolygonBeforeDrag!.map((p) => PointN(
            x: (p.x + clampedDx).clamp(0.0, 1.0),
            y: (p.y + clampedDy).clamp(0.0, 1.0),
          )).toList();

      final updatedZone = Zone(
        id: _activeZone!.id,
        cameraId: _activeZone!.cameraId,
        name: _activeZone!.name,
        kind: _activeZone!.kind,
        color: _activeZone!.color,
        polygon: updatedPoly,
        createdAt: _activeZone!.createdAt,
      );

      // Keep both _activeZone and _zones list in sync so painter redraws moving polygon
      final idx = _zones.indexWhere((z) => z.id == _activeZone!.id);
      if (idx != -1) {
        _zones[idx] = updatedZone;
      }

      setState(() {
        _currentDragDeltaNormalized = Offset(clampedDx, clampedDy);
        _activeZone = updatedZone;
      });
      return;
    }

    // --- SINGLE VERTEX DRAGGING ---
    if (_currentTool == EditorTool.select && _draggedVertexIndex != null && _activeZone != null) {
      final normX = (localPos.dx / canvasSize.width).clamp(0.0, 1.0);
      final normY = (localPos.dy / canvasSize.height).clamp(0.0, 1.0);

      final newPoly = List<PointN>.from(_activeZone!.polygon);
      newPoly[_draggedVertexIndex!] = PointN(x: normX, y: normY);

      final updatedZone = Zone(
        id: _activeZone!.id,
        cameraId: _activeZone!.cameraId,
        name: _activeZone!.name,
        kind: _activeZone!.kind,
        color: _activeZone!.color,
        polygon: newPoly,
        createdAt: _activeZone!.createdAt,
      );

      final idx = _zones.indexWhere((z) => z.id == _activeZone!.id);
      if (idx != -1) {
        _zones[idx] = updatedZone;
      }

      setState(() {
        _activeZone = updatedZone;
      });
    }
  }

  Future<void> _onPanEnd(DragEndDetails details, Size canvasSize) async {
    // --- FREEHAND FINISHED: CONVERT TO PRECISION POLYGON ---
    if (_currentTool == EditorTool.freehand && _isFreehandDrawing) {
      _isFreehandDrawing = false;
      if (_freehandStroke.length >= 8) {
        final polygon = _simplifyFreehandStroke(_freehandStroke, canvasSize);
        if (polygon.length >= 3) {
          setState(() {
            _draftPoints.clear();
            _draftPoints.addAll(polygon);
            _freehandStroke.clear();
          });
          _showSaveZoneDialog(isFreehand: true);
          return;
        }
      }
      // If stroke was too short, clear
      setState(() {
        _freehandStroke.clear();
      });
      return;
    }

    // --- WHOLE-ZONE TRANSLATION FINISHED: AUTO-PERSIST ---
    if (_isDraggingWholeZone && _activeZone != null) {
      final zoneToSave = _activeZone!;
      setState(() {
        _isDraggingWholeZone = false;
        _initialPolygonBeforeDrag = null;
        _dragStartScreenPos = null;
        _currentDragDeltaNormalized = null;
      });
      final repo = ref.read(argusRepositoryProvider);
      await repo.saveZone(zoneToSave);
      _loadZones();
      return;
    }

    // --- VERTEX ADJUSTMENT FINISHED: AUTO-PERSIST ---
    if (_draggedVertexIndex != null && _activeZone != null) {
      final zoneToSave = _activeZone!;
      setState(() {
        _draggedVertexIndex = null;
      });
      final repo = ref.read(argusRepositoryProvider);
      await repo.saveZone(zoneToSave);
      _loadZones();
    }
  }

  // ==========================================
  // PRESETS & INSTANT WHOLE-ZONE CREATION
  // ==========================================

  void _applyPreset(String preset) async {
    List<PointN> points = [];
    String kind = 'restricted';
    String color = '#F43F5E';

    if (preset == 'Staircase') {
      points = [
        PointN(x: 0.35, y: 0.30),
        PointN(x: 0.65, y: 0.30),
        PointN(x: 0.65, y: 0.70),
        PointN(x: 0.35, y: 0.70),
      ];
      kind = 'stairs';
      color = '#A78BFA';
    } else if (preset == 'Doorway') {
      points = [
        PointN(x: 0.40, y: 0.25),
        PointN(x: 0.60, y: 0.25),
        PointN(x: 0.60, y: 0.75),
        PointN(x: 0.40, y: 0.75),
      ];
      kind = 'restricted';
      color = '#F43F5E';
    } else if (preset == 'Perimeter Line') {
      points = [
        PointN(x: 0.12, y: 0.12),
        PointN(x: 0.88, y: 0.12),
        PointN(x: 0.88, y: 0.88),
        PointN(x: 0.12, y: 0.88),
      ];
      kind = 'sterile';
      color = '#38BDF8';
    } else {
      // Danger Area: Compact centered bounding box
      points = [
        PointN(x: 0.35, y: 0.35),
        PointN(x: 0.65, y: 0.35),
        PointN(x: 0.65, y: 0.65),
        PointN(x: 0.35, y: 0.65),
      ];
      kind = 'work';
      color = '#FBBF24';
    }

    final repo = ref.read(argusRepositoryProvider);
    final newZone = Zone(
      cameraId: widget.cameraId,
      name: '$preset Zone ${_zones.length + 1}',
      kind: kind,
      color: color,
      polygon: points,
      createdAt: DateTime.now(),
    );

    final saved = await repo.saveZone(newZone);
    if (!mounted) return;

    setState(() {
      _zones.add(saved);
      _activeZone = saved;
      _currentTool = EditorTool.select;
      _draftPoints.clear();
      _redoPoints.clear();
      _freehandStroke.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: ArgusTokens.accent, width: 1),
        ),
        content: Row(
          children: [
            const Icon(Icons.open_with_rounded, color: ArgusTokens.accent, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Template applied! Grab anywhere inside to move the entire zone, or drag corner handles to resize.',
                style: GoogleFonts.inter(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ==========================================
  // ZONE CONFIGURATION & SAVE DIALOG
  // ==========================================

  void _showSaveZoneDialog({bool isFreehand = false}) {
    if (_draftPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A zone polygon must have at least 3 points.')),
      );
      return;
    }

    final nameCtrl = TextEditingController(
      text: isFreehand ? 'Drawn Zone ${_zones.length + 1}' : 'Polygon Zone ${_zones.length + 1}',
    );
    String kind = 'restricted';
    String color = '#F43F5E';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: ArgusTokens.bgOverlay,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Colors.white24, width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ArgusTokens.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isFreehand ? Icons.gesture_rounded : Icons.polyline_rounded,
                  color: ArgusTokens.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Save Restricted Area', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(
                    '${_draftPoints.length} precision points generated',
                    style: GoogleFonts.jetBrainsMono(fontSize: 11, color: ArgusTokens.textTertiary),
                  ),
                ],
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameCtrl,
                autofocus: true,
                style: GoogleFonts.inter(color: ArgusTokens.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Zone Name',
                  hintText: 'e.g. Danger Line, Cash Counter, High Drop',
                  prefixIcon: const Icon(Icons.label_outline_rounded, size: 18),
                  filled: true,
                  fillColor: ArgusTokens.bgRaised,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: kind,
                dropdownColor: ArgusTokens.bgRaised,
                style: GoogleFonts.inter(color: ArgusTokens.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Security Category',
                  filled: true,
                  fillColor: ArgusTokens.bgRaised,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
                items: const [
                  DropdownMenuItem(value: 'restricted', child: Text('Restricted Security Zone')),
                  DropdownMenuItem(value: 'work', child: Text('Hazard / Machinery Sector')),
                  DropdownMenuItem(value: 'stairs', child: Text('Stairwell / Elevated Drop')),
                  DropdownMenuItem(value: 'sterile', child: Text('Sterile Perimeter Line')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setDlgState(() {
                      kind = val;
                      if (val == 'restricted') color = '#F43F5E';
                      if (val == 'work') color = '#FBBF24';
                      if (val == 'stairs') color = '#A78BFA';
                      if (val == 'sterile') color = '#38BDF8';
                    });
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                setState(() {
                  _draftPoints.clear();
                  _redoPoints.clear();
                });
              },
              child: const Text('Discard', style: TextStyle(color: ArgusTokens.textSecondary)),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.check_rounded, size: 18, color: Colors.black),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);

                final repo = ref.read(argusRepositoryProvider);
                final newZone = Zone(
                  cameraId: widget.cameraId,
                  name: nameCtrl.text.trim(),
                  kind: kind,
                  color: color,
                  polygon: List.from(_draftPoints),
                  createdAt: DateTime.now(),
                );

                final messenger = ScaffoldMessenger.of(context);
                final saved = await repo.saveZone(newZone);
                if (!mounted) return;
                setState(() {
                  _zones.add(saved);
                  _activeZone = saved;
                  _draftPoints.clear();
                  _redoPoints.clear();
                  _currentTool = EditorTool.select;
                });

                messenger.showSnackBar(
                  SnackBar(
                    content: Text('Zone "${saved.name}" successfully created with ${saved.polygon.length} points.'),
                  ),
                );
              },
              label: const Text('Save & Activate', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteZoneDialog(Zone z) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: ArgusTokens.bgOverlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white24, width: 1),
        ),
        title: Text('Delete Zone', style: GoogleFonts.sora(fontSize: 16, color: Colors.white)),
        content: Text('Delete zone "${z.name}"?', style: GoogleFonts.inter(color: ArgusTokens.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(c);
              await ref.read(argusRepositoryProvider).deleteZone(z.id!);
              _loadZones();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _undoPoint() {
    if (_draftPoints.isNotEmpty) {
      setState(() {
        _redoPoints.add(_draftPoints.removeLast());
      });
    }
  }

  void _redoPoint() {
    if (_redoPoints.isNotEmpty) {
      setState(() {
        _draftPoints.add(_redoPoints.removeLast());
      });
    }
  }

  void _clearDraft() {
    setState(() {
      _draftPoints.clear();
      _redoPoints.clear();
      _freehandStroke.clear();
    });
  }

  // ==========================================
  // MAIN SCREEN BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: ArgusTokens.accent));
    }

    return Scaffold(
      backgroundColor: ArgusTokens.bgBase,
      body: Row(
        children: [
          // Left Area: Canvas Stage & Tooling
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.all(ArgusTokens.space24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back & Control Header
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: ArgusTokens.textSecondary),
                        onPressed: () => context.go('/app/cameras'),
                        tooltip: 'Back to Cameras',
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                _camera?.name ?? 'Camera #${widget.cameraId}',
                                style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(width: 12),
                              if (_camera?.sourceKind == 'webcam')
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.fiber_manual_record_rounded, size: 8, color: Colors.greenAccent),
                                      const SizedBox(width: 5),
                                      Text('LIVE WEBCAM', style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                                    ],
                                  ),
                                )
                              else
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.amberAccent.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.4)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.pause_circle_outline_rounded, size: 10, color: Colors.amberAccent),
                                          const SizedBox(width: 5),
                                          Text('STATIC FIRST FRAME', style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amberAccent)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      onPressed: _pickVideoForCamera,
                                      icon: const Icon(Icons.upload_file_rounded, size: 14),
                                      label: const Text('Change MP4 / Scene', style: TextStyle(fontSize: 11)),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          Text(
                            _camera?.sourceKind == 'webcam'
                                ? 'Live webcam active in background · Draw detection zones over physical space'
                                : 'Static video first frame frozen in background · Draw detection zones over scene structures',
                            style: GoogleFonts.inter(fontSize: 11, color: ArgusTokens.textTertiary),
                          ),
                        ],
                      ),
                      const Spacer(),

                      // Tool Mode Selector Pills
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: ArgusTokens.bgRaised,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildToolButton(
                              tool: EditorTool.select,
                              icon: ref.watch(activeFacilityRoleProvider).toLowerCase() == 'guard' ? Icons.visibility_outlined : Icons.open_with_rounded,
                              label: ref.watch(activeFacilityRoleProvider).toLowerCase() == 'guard' ? 'View Zones' : 'Select & Move',
                              tooltip: ref.watch(activeFacilityRoleProvider).toLowerCase() == 'guard' ? 'View zones on this camera' : 'Hold & drag anywhere inside to move whole area, or drag corners',
                            ),
                            if (ref.watch(activeFacilityRoleProvider).toLowerCase() != 'guard') ...[
                              const SizedBox(width: 4),
                              _buildToolButton(
                                tool: EditorTool.freehand,
                                icon: Icons.gesture_rounded,
                                label: 'Freehand Draw',
                                tooltip: 'Draw freely with laser brush — auto-closes & downsamples to precision area',
                              ),
                              const SizedBox(width: 4),
                              _buildToolButton(
                                tool: EditorTool.polygon,
                                icon: Icons.polyline_rounded,
                                label: 'Polygon Pen',
                                tooltip: 'Click point-by-point with magnetic snap-to-close',
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Dynamic Instruction & Action Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: ArgusTokens.bgOverlay,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ArgusTokens.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _currentTool == EditorTool.freehand
                              ? Icons.draw_rounded
                              : _currentTool == EditorTool.polygon
                                  ? Icons.timeline_rounded
                                  : Icons.pan_tool_alt_rounded,
                          size: 18,
                          color: ArgusTokens.accent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _currentTool == EditorTool.freehand
                                ? 'Freehand Mode: Click and drag across the camera to sketch your restricted area. Release when done to auto-generate polygon.'
                                : _currentTool == EditorTool.polygon
                                    ? 'Polygon Pen Mode: Click anywhere to place vertices. Connect at least 3 points, then click the start point or "Save Area".'
                                    : 'Select & Move Mode: Click any zone to select. Hold anywhere inside the area to drag the whole zone, or drag corner handles to reshape.',
                            style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textSecondary),
                          ),
                        ),

                        // Action Controls based on tool
                        if (_currentTool == EditorTool.polygon) ...[
                          IconButton(
                            tooltip: 'Undo Last Point',
                            onPressed: _draftPoints.isNotEmpty ? _undoPoint : null,
                            icon: const Icon(Icons.undo_rounded, size: 18),
                            color: _draftPoints.isNotEmpty ? Colors.white : Colors.white24,
                          ),
                          IconButton(
                            tooltip: 'Redo Point',
                            onPressed: _redoPoints.isNotEmpty ? _redoPoint : null,
                            icon: const Icon(Icons.redo_rounded, size: 18),
                            color: _redoPoints.isNotEmpty ? Colors.white : Colors.white24,
                          ),
                          TextButton(
                            onPressed: _clearDraft,
                            child: const Text('Clear', style: TextStyle(color: ArgusTokens.textTertiary, fontSize: 12)),
                          ),
                          const SizedBox(width: 4),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            onPressed: _draftPoints.length >= 3 ? () => _showSaveZoneDialog(isFreehand: false) : null,
                            icon: const Icon(Icons.check_rounded, size: 16, color: Colors.black),
                            label: Text(
                              'Save Area (${_draftPoints.length} pts)',
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ] else if (_currentTool == EditorTool.freehand && _draftPoints.isNotEmpty) ...[
                          TextButton(
                            onPressed: _clearDraft,
                            child: const Text('Clear', style: TextStyle(color: ArgusTokens.textTertiary, fontSize: 12)),
                          ),
                          const SizedBox(width: 4),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            ),
                            onPressed: () => _showSaveZoneDialog(isFreehand: true),
                            icon: const Icon(Icons.check_rounded, size: 16, color: Colors.black),
                            label: Text(
                              'Save Area (${_draftPoints.length} pts)',
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Interactive Studio Canvas (Strict 16:9 Camera FOV Locked)
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF070A0F),
                            borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
                            border: Border.all(color: Colors.white24, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.6),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // 1. Background Feed Layer: Webcam (Live) OR Video (Static First Frame)
                              if (_camera?.sourceKind == 'webcam')
                                const Positioned.fill(
                                  child: ZoneWebcamPreview(),
                                )
                              else if (_staticFrameUrl != null)
                                Positioned.fill(
                                  child: Image.network(
                                    _staticFrameUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: const Color(0xFF070A0F),
                                      child: const Center(
                                        child: Icon(Icons.movie_outlined, size: 48, color: Colors.white24),
                                      ),
                                    ),
                                  ),
                                ),

                              // Loading indicator when extracting new video frame
                              if (_isExtractingFrame)
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black87,
                                    child: Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const CircularProgressIndicator(color: ArgusTokens.accent),
                                          const SizedBox(height: 12),
                                          Text('Extracting static first frame...', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                              // 2. High-contrast tint overlay so neon drawing lines pop sharply
                              if (_camera?.sourceKind == 'webcam' || _staticFrameUrl != null)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: Container(
                                      color: Colors.black.withValues(alpha: 0.22),
                                    ),
                                  ),
                                ),

                              // 3. Camera FOV Grid & Aspect-Ratio Guides
                              IgnorePointer(
                                child: CustomPaint(
                                  painter: _CameraGridPainter(),
                                ),
                              ),

                              // 4. Interactive Gesture Layer & Zone Editor Painter
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final size = Size(constraints.maxWidth, constraints.maxHeight);

                                  return MouseRegion(
                                    cursor: _getCursorForState(),
                                    onHover: (e) => _onPointerHover(e, size),
                                    child: GestureDetector(
                                      onTapUp: (details) => _onCanvasTap(details, size),
                                      onPanStart: (details) => _onPanStart(details, size),
                                      onPanUpdate: (details) => _onPanUpdate(details, size),
                                      onPanEnd: (details) => _onPanEnd(details, size),
                                      child: AnimatedBuilder(
                                        animation: _animController,
                                        builder: (context, child) {
                                          return CustomPaint(
                                            size: size,
                                            painter: _ZoneEditorPainter(
                                              zones: _zones,
                                              activeZone: _activeZone,
                                              draftPoints: _draftPoints,
                                              freehandStroke: _freehandStroke,
                                              isFreehandDrawing: _isFreehandDrawing,
                                              currentTool: _currentTool,
                                              draggedVertexIndex: _draggedVertexIndex,
                                              isDraggingWholeZone: _isDraggingWholeZone,
                                              mouseCursorPos: _mouseCursorPos,
                                              isNearFirstPoint: _isNearFirstPoint,
                                              animValue: _animController.value,
                                              currentDragDelta: _currentDragDeltaNormalized,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Sidebar: Zones Management & Instant Presets
          SizedBox(
            width: 340,
            child: Container(
              padding: const EdgeInsets.all(ArgusTokens.space20),
              decoration: const BoxDecoration(
                color: ArgusTokens.bgRaised,
                border: Border(left: BorderSide(color: Colors.white12)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (ref.watch(activeFacilityRoleProvider).toLowerCase() == 'guard') ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ArgusTokens.bgOverlay,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ArgusTokens.borderSubtle),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_rounded, size: 16, color: ArgusTokens.success),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Guard clearance active: Zones are read-only and cannot be altered or removed.',
                              style: GoogleFonts.inter(fontSize: 11, color: ArgusTokens.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ] else ...[
                    Text('Quick Zone Templates', style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      'Places an instant draggable template. Grab anywhere inside to position it.',
                      style: GoogleFonts.inter(fontSize: 11, color: ArgusTokens.textTertiary),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildTemplateChip(
                                icon: Icons.warning_amber_rounded,
                                color: const Color(0xFFFBBF24),
                                label: 'Danger Box',
                                onTap: () => _applyPreset('Danger Area'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildTemplateChip(
                                icon: Icons.door_front_door_outlined,
                                color: const Color(0xFFF43F5E),
                                label: 'Doorway Box',
                                onTap: () => _applyPreset('Doorway'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTemplateChip(
                                icon: Icons.stairs_rounded,
                                color: const Color(0xFFA78BFA),
                                label: 'Staircase',
                                onTap: () => _applyPreset('Staircase'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _buildTemplateChip(
                                icon: Icons.crop_square_rounded,
                                color: const Color(0xFF38BDF8),
                                label: 'Perimeter Line',
                                onTap: () => _applyPreset('Perimeter Line'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                  const Divider(color: ArgusTokens.borderSubtle),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Text('Configured Zones (${_zones.length})', style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600)),
                      const Spacer(),
                      if (_activeZone != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: ArgusTokens.accent.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Active Zone Selected',
                            style: GoogleFonts.inter(fontSize: 10, color: ArgusTokens.accent, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Expanded(
                    child: _zones.isEmpty
                        ? Center(
                            child: Text(
                              'No zones yet.\nDraw a freehand shape or add a template.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textTertiary),
                            ),
                          )
                        : ListView.separated(
                            itemCount: _zones.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, idx) {
                              final z = _zones[idx];
                              final isSel = _activeZone?.id == z.id;
                              final zColor = Color(int.parse(z.color.replaceFirst('#', '0xFF')));

                              return InkWell(
                                onTap: () => setState(() {
                                  _activeZone = z;
                                  _currentTool = EditorTool.select;
                                }),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSel ? zColor.withValues(alpha: 0.15) : ArgusTokens.bgOverlay,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSel ? Colors.white : ArgusTokens.borderSubtle,
                                      width: isSel ? 1.5 : 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: zColor,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            if (isSel)
                                              BoxShadow(
                                                color: zColor.withValues(alpha: 0.6),
                                                blurRadius: 6,
                                              ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              z.name,
                                              style: GoogleFonts.inter(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: ArgusTokens.textPrimary,
                                              ),
                                            ),
                                            Text(
                                              '${z.polygon.length} points · ${z.kind.toUpperCase()}',
                                              style: GoogleFonts.jetBrainsMono(fontSize: 10, color: ArgusTokens.textTertiary),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSel)
                                        const Tooltip(
                                          message: 'Ready to Drag & Move',
                                          child: Icon(Icons.open_with_rounded, size: 16, color: Colors.white70),
                                        ),
                                      if (ref.watch(activeFacilityRoleProvider).toLowerCase() != 'guard')
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: ArgusTokens.textTertiary),
                                          tooltip: 'Delete Zone',
                                          onPressed: () => _showDeleteZoneDialog(z),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required EditorTool tool,
    required IconData icon,
    required String label,
    required String tooltip,
  }) {
    final isSelected = _currentTool == tool;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: () {
          setState(() {
            _currentTool = tool;
            if (tool != EditorTool.freehand && tool != EditorTool.polygon) {
              _freehandStroke.clear();
            }
          });
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: isSelected ? Colors.black : ArgusTokens.textSecondary),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? Colors.black : ArgusTokens.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateChip({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: ArgusTokens.bgOverlay,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '+ $label',
                style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  MouseCursor _getCursorForState() {
    if (_currentTool == EditorTool.freehand) {
      return SystemMouseCursors.precise;
    }
    if (_currentTool == EditorTool.polygon) {
      return _isNearFirstPoint ? SystemMouseCursors.click : SystemMouseCursors.precise;
    }
    if (_isDraggingWholeZone) {
      return SystemMouseCursors.grabbing;
    }
    if (_draggedVertexIndex != null) {
      return SystemMouseCursors.grab;
    }
    return SystemMouseCursors.basic;
  }
}

// ==========================================
// HIGH-PERFORMANCE CUSTOM PAINTER
// ==========================================

class _ZoneEditorPainter extends CustomPainter {
  final List<Zone> zones;
  final Zone? activeZone;
  final List<PointN> draftPoints;
  final List<Offset> freehandStroke;
  final bool isFreehandDrawing;
  final EditorTool currentTool;
  final int? draggedVertexIndex;
  final bool isDraggingWholeZone;
  final Offset? mouseCursorPos;
  final bool isNearFirstPoint;
  final double animValue;
  final Offset? currentDragDelta;

  _ZoneEditorPainter({
    required this.zones,
    required this.activeZone,
    required this.draftPoints,
    required this.freehandStroke,
    required this.isFreehandDrawing,
    required this.currentTool,
    required this.draggedVertexIndex,
    required this.isDraggingWholeZone,
    required this.mouseCursorPos,
    required this.isNearFirstPoint,
    required this.animValue,
    this.currentDragDelta,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // ----------------------------------------------------
    // 1. DRAW EXISTING CONFIGURED ZONES
    // ----------------------------------------------------
    for (final z in zones) {
      final isActive = activeZone?.id == z.id;
      final poly = isActive && activeZone != null ? activeZone!.polygon : z.polygon;
      if (poly.length < 3) continue;
      final col = Color(int.parse(z.color.replaceFirst('#', '0xFF')));

      final path = Path();
      path.moveTo(poly.first.x * size.width, poly.first.y * size.height);
      for (int i = 1; i < poly.length; i++) {
        path.lineTo(poly[i].x * size.width, poly[i].y * size.height);
      }
      path.close();

      // Translucent area fill
      final fillAlpha = isActive ? 0.32 : 0.16;
      canvas.drawPath(path, Paint()..color = col.withValues(alpha: fillAlpha)..style = PaintingStyle.fill);

      // Glowing border stroke
      if (isActive) {
        // Neon pulse halo
        final pulseWidth = 3.5 + 1.5 * math.sin(animValue * 2 * math.pi);
        canvas.drawPath(
          path,
          Paint()
            ..color = col.withValues(alpha: 0.35)
            ..style = PaintingStyle.stroke
            ..strokeWidth = pulseWidth * 2
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
        // Solid crisp boundary
        canvas.drawPath(
          path,
          Paint()
            ..color = col
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );
      } else {
        canvas.drawPath(
          path,
          Paint()
            ..color = col.withValues(alpha: 0.8)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.6,
        );
      }

      // Compute Centroid
      double cx = 0, cy = 0;
      for (final p in poly) {
        cx += p.x * size.width;
        cy += p.y * size.height;
      }
      cx /= poly.length;
      cy /= poly.length;

      // Centroid Handle & Whole-Zone Move Indicator for Active Zone
      if (isActive && currentTool == EditorTool.select) {
        _drawCentroidMoveHandle(canvas, Offset(cx, cy), col);
      } else {
        // Simple Zone Label
        _drawZoneLabel(canvas, Offset(cx, cy), z.name, col);
      }

      // Draw Draggable Corner Handles for Active Zone
      if (isActive && currentTool == EditorTool.select) {
        for (int i = 0; i < poly.length; i++) {
          final p = poly[i];
          final pos = Offset(p.x * size.width, p.y * size.height);
          final isDragged = draggedVertexIndex == i;

          // Outer ring
          canvas.drawCircle(
            pos,
            isDragged ? 9.5 : 7.0,
            Paint()..color = Colors.white..style = PaintingStyle.fill,
          );
          // Inner core
          canvas.drawCircle(
            pos,
            isDragged ? 6.5 : 4.5,
            Paint()..color = col..style = PaintingStyle.fill,
          );

          if (isDragged) {
            canvas.drawCircle(
              pos,
              14.0,
              Paint()
                ..color = Colors.white.withValues(alpha: 0.3)
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.5,
            );
          }
        }
      } else {
        // Non-active subtle points
        for (final p in poly) {
          canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), 3.0, Paint()..color = col);
        }
      }
    }

    // ----------------------------------------------------
    // 2. DRAW LIVE FREEHAND STROKE (REAL-LIFE NEON DRAWING)
    // ----------------------------------------------------
    if (freehandStroke.isNotEmpty) {
      _drawFreehandStroke(canvas, size);
    }

    // ----------------------------------------------------
    // 3. DRAW POLYGON PEN DRAFT & RUBBER-BAND LINE
    // ----------------------------------------------------
    if (draftPoints.isNotEmpty) {
      _drawPolygonPenDraft(canvas, size);
    }

    // ----------------------------------------------------
    // 4. DRAW ACTIVE DRAG DELTA BADGE
    // ----------------------------------------------------
    if (isDraggingWholeZone && currentDragDelta != null && activeZone != null) {
      _drawDragDeltaBadge(canvas, size);
    }
  }

  void _drawCentroidMoveHandle(Canvas canvas, Offset centroid, Color col) {
    final isMoving = isDraggingWholeZone;

    // Glowing halo around centroid
    final haloRadius = isMoving ? 26.0 : 18.0 + 3.0 * math.sin(animValue * 2 * math.pi);
    canvas.drawCircle(
      centroid,
      haloRadius,
      Paint()
        ..color = isMoving ? ArgusTokens.accent.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill,
    );

    // Centroid Disc
    canvas.drawCircle(
      centroid,
      14.0,
      Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      centroid,
      14.0,
      Paint()
        ..color = isMoving ? ArgusTokens.accent : Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // 4-Directional Move Glyph (Arrows)
    final arrowPaint = Paint()
      ..color = isMoving ? ArgusTokens.accent : Colors.white
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    // Cross axes
    canvas.drawLine(Offset(centroid.dx - 8, centroid.dy), Offset(centroid.dx + 8, centroid.dy), arrowPaint);
    canvas.drawLine(Offset(centroid.dx, centroid.dy - 8), Offset(centroid.dx, centroid.dy + 8), arrowPaint);

    // Arrowheads
    canvas.drawLine(Offset(centroid.dx - 8, centroid.dy), Offset(centroid.dx - 5, centroid.dy - 3), arrowPaint);
    canvas.drawLine(Offset(centroid.dx - 8, centroid.dy), Offset(centroid.dx - 5, centroid.dy + 3), arrowPaint);
    canvas.drawLine(Offset(centroid.dx + 8, centroid.dy), Offset(centroid.dx + 5, centroid.dy - 3), arrowPaint);
    canvas.drawLine(Offset(centroid.dx + 8, centroid.dy), Offset(centroid.dx + 5, centroid.dy + 3), arrowPaint);
    canvas.drawLine(Offset(centroid.dx, centroid.dy - 8), Offset(centroid.dx - 3, centroid.dy - 5), arrowPaint);
    canvas.drawLine(Offset(centroid.dx, centroid.dy - 8), Offset(centroid.dx + 3, centroid.dy - 5), arrowPaint);
    canvas.drawLine(Offset(centroid.dx, centroid.dy + 8), Offset(centroid.dx - 3, centroid.dy + 5), arrowPaint);
    canvas.drawLine(Offset(centroid.dx, centroid.dy + 8), Offset(centroid.dx + 3, centroid.dy + 5), arrowPaint);

    // Floating text label
    final labelText = isMoving ? 'MOVING WHOLE ZONE' : 'DRAG TO MOVE';
    final tp = TextPainter(
      text: TextSpan(
        text: labelText,
        style: TextStyle(
          color: isMoving ? ArgusTokens.accent : Colors.white70,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          backgroundColor: Colors.black.withValues(alpha: 0.75),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(centroid.dx - tp.width / 2, centroid.dy + 18));
  }

  void _drawZoneLabel(Canvas canvas, Offset centroid, String name, Color col) {
    final tp = TextPainter(
      text: TextSpan(
        text: name,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.black.withValues(alpha: 0.65),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(centroid.dx - tp.width / 2, centroid.dy - tp.height / 2));
  }

  void _drawFreehandStroke(Canvas canvas, Size size) {
    if (freehandStroke.length < 2) return;

    // 1. Build smooth Bezier path across stroke points
    final smoothPath = Path();
    smoothPath.moveTo(freehandStroke.first.dx, freehandStroke.first.dy);

    for (int i = 1; i < freehandStroke.length - 1; i++) {
      final midX = (freehandStroke[i].dx + freehandStroke[i + 1].dx) / 2;
      final midY = (freehandStroke[i].dy + freehandStroke[i + 1].dy) / 2;
      smoothPath.quadraticBezierTo(freehandStroke[i].dx, freehandStroke[i].dy, midX, midY);
    }
    smoothPath.lineTo(freehandStroke.last.dx, freehandStroke.last.dy);

    // 2. Translucent Closed Area Preview while drawing
    final previewAreaPath = Path.from(smoothPath);
    previewAreaPath.lineTo(freehandStroke.first.dx, freehandStroke.first.dy);
    previewAreaPath.close();

    canvas.drawPath(
      previewAreaPath,
      Paint()
        ..color = ArgusTokens.accent.withValues(alpha: 0.12)
        ..style = PaintingStyle.fill,
    );

    // 3. Multi-layer Neon Laser Brush Trail
    // Layer A: Outer Neon Glow
    canvas.drawPath(
      smoothPath,
      Paint()
        ..color = ArgusTokens.accent.withValues(alpha: 0.45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );

    // Layer B: Mid Laser Core
    canvas.drawPath(
      smoothPath,
      Paint()
        ..color = ArgusTokens.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Layer C: Hot White Center
    canvas.drawPath(
      smoothPath,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // 4. Stylus / Pen Tip Animation at current cursor
    final tipPos = freehandStroke.last;
    final startPos = freehandStroke.first;
    final distToStart = (tipPos - startPos).distance;
    final isClosing = distToStart <= 26.0 && freehandStroke.length > 15;

    // Outer Tip Pulse
    canvas.drawCircle(
      tipPos,
      isClosing ? 12.0 : 8.0,
      Paint()
        ..color = isClosing ? const Color(0xFF10B981) : Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Center Hot Spot
    canvas.drawCircle(
      tipPos,
      3.5,
      Paint()..color = isClosing ? const Color(0xFF10B981) : ArgusTokens.accent..style = PaintingStyle.fill,
    );

    if (isClosing) {
      final tp = TextPainter(
        text: const TextSpan(
          text: 'RELEASE TO CLOSE',
          style: TextStyle(
            color: Color(0xFF10B981),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            backgroundColor: Color(0xCC000000),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(tipPos.dx + 12, tipPos.dy - 10));
    }
  }

  void _drawPolygonPenDraft(Canvas canvas, Size size) {
    // 1. Draw completed draft segments
    final draftPath = Path();
    draftPath.moveTo(draftPoints.first.x * size.width, draftPoints.first.y * size.height);
    for (int i = 1; i < draftPoints.length; i++) {
      draftPath.lineTo(draftPoints[i].x * size.width, draftPoints[i].y * size.height);
    }

    // Outer neon glow
    canvas.drawPath(
      draftPath,
      Paint()
        ..color = ArgusTokens.accent.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Solid line
    canvas.drawPath(
      draftPath,
      Paint()
        ..color = ArgusTokens.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2,
    );

    // 2. Live Rubber-Band Line from last point to cursor
    if (mouseCursorPos != null && currentTool == EditorTool.polygon) {
      final lastPos = Offset(draftPoints.last.x * size.width, draftPoints.last.y * size.height);
      final targetPos = isNearFirstPoint
          ? Offset(draftPoints.first.x * size.width, draftPoints.first.y * size.height)
          : mouseCursorPos!;

      // Dashed guide line
      final rubberPaint = Paint()
        ..color = isNearFirstPoint ? const Color(0xFF10B981) : Colors.white70
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8;

      canvas.drawLine(lastPos, targetPos, rubberPaint);
    }

    // 3. Draw placed draft vertices with number badges
    for (int i = 0; i < draftPoints.length; i++) {
      final p = draftPoints[i];
      final pos = Offset(p.x * size.width, p.y * size.height);
      final isFirst = i == 0;

      if (isFirst && isNearFirstPoint) {
        // Pulsing magnetic snap target
        canvas.drawCircle(
          pos,
          14.0 + 3.0 * math.sin(animValue * 4 * math.pi),
          Paint()
            ..color = const Color(0xFF10B981).withValues(alpha: 0.4)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5,
        );
      }

      canvas.drawCircle(pos, 6.5, Paint()..color = Colors.white);
      canvas.drawCircle(pos, 4.5, Paint()..color = isFirst ? const Color(0xFF10B981) : ArgusTokens.accent);

      final tp = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(pos.dx + 8, pos.dy - 12));
    }

    // Magnetic snap badge text
    if (isNearFirstPoint && draftPoints.length >= 3) {
      final firstPos = Offset(draftPoints.first.x * size.width, draftPoints.first.y * size.height);
      final tp = TextPainter(
        text: const TextSpan(
          text: 'CLICK TO CLOSE AREA',
          style: TextStyle(
            color: Color(0xFF10B981),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            backgroundColor: Color(0xCC000000),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(firstPos.dx + 14, firstPos.dy + 8));
    }
  }

  void _drawDragDeltaBadge(Canvas canvas, Size size) {
    if (currentDragDelta == null) return;
    final dxStr = (currentDragDelta!.dx >= 0 ? '+' : '') + currentDragDelta!.dx.toStringAsFixed(3);
    final dyStr = (currentDragDelta!.dy >= 0 ? '+' : '') + currentDragDelta!.dy.toStringAsFixed(3);

    final tp = TextPainter(
      text: TextSpan(
        text: 'MOVING AREA · ΔX: $dxStr  ΔY: $dyStr',
        style: const TextStyle(
          color: Color(0xFF38BDF8),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          backgroundColor: Color(0xDD0F172A),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, const Offset(16, 16));
  }

  @override
  bool shouldRepaint(covariant _ZoneEditorPainter oldDelegate) => true;
}

// ==========================================
// CAMERA 16:9 PERSPECTIVE FOV GRID PAINTER
// ==========================================

class _CameraGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Grid lines (rule of thirds)
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(w / 3, 0), Offset(w / 3, h), gridPaint);
    canvas.drawLine(Offset(2 * w / 3, 0), Offset(2 * w / 3, h), gridPaint);
    canvas.drawLine(Offset(0, h / 3), Offset(w, h / 3), gridPaint);
    canvas.drawLine(Offset(0, 2 * h / 3), Offset(w, 2 * h / 3), gridPaint);

    // 2. Corner brackets
    final cornerPaint = Paint()
      ..color = Colors.white38
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const len = 24.0;
    // Top-left
    canvas.drawLine(const Offset(12, 12), const Offset(12 + len, 12), cornerPaint);
    canvas.drawLine(const Offset(12, 12), const Offset(12, 12 + len), cornerPaint);
    // Top-right
    canvas.drawLine(Offset(w - 12, 12), Offset(w - 12 - len, 12), cornerPaint);
    canvas.drawLine(Offset(w - 12, 12), Offset(w - 12, 12 + len), cornerPaint);
    // Bottom-left
    canvas.drawLine(Offset(12, h - 12), Offset(12 + len, h - 12), cornerPaint);
    canvas.drawLine(Offset(12, h - 12), Offset(12, h - 12 - len), cornerPaint);
    // Bottom-right
    canvas.drawLine(Offset(w - 12, h - 12), Offset(w - 12 - len, h - 12), cornerPaint);
    canvas.drawLine(Offset(w - 12, h - 12), Offset(w - 12, h - 12 - len), cornerPaint);

    // 3. 16:9 Cam FOV badge
    final tp = TextPainter(
      text: const TextSpan(
        text: 'CAM 16:9 PERSPECTIVE FOV (1280 × 720) · NORMALIZED [0.0 → 1.0]',
        style: TextStyle(
          color: Colors.white24,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(16, h - 22));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
