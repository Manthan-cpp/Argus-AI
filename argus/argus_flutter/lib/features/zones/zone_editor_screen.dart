import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:argus_client/argus_client.dart';
import '../../app/theme/tokens.dart';
import '../../data/repository_provider.dart';

class ZoneEditorScreen extends ConsumerStatefulWidget {
  final int cameraId;

  const ZoneEditorScreen({super.key, required this.cameraId});

  @override
  ConsumerState<ZoneEditorScreen> createState() => _ZoneEditorScreenState();
}

class _ZoneEditorScreenState extends ConsumerState<ZoneEditorScreen> {
  List<Zone> _zones = [];
  Zone? _activeZone;
  final List<PointN> _draftPoints = [];
  final List<PointN> _redoPoints = [];
  bool _isDrawing = false;
  bool _isLoading = true;

  // Vertex Dragging
  int? _draggedVertexIndex;

  @override
  void initState() {
    super.initState();
    _loadZones();
  }

  Future<void> _loadZones() async {
    final repo = ref.read(argusRepositoryProvider);
    final list = await repo.listZones(widget.cameraId);
    if (mounted) {
      setState(() {
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

  void _onCanvasTap(TapUpDetails details, Size canvasSize) {
    if (!_isDrawing) return;

    final normX = (details.localPosition.dx / canvasSize.width).clamp(0.0, 1.0);
    final normY = (details.localPosition.dy / canvasSize.height).clamp(0.0, 1.0);

    setState(() {
      _draftPoints.add(PointN(x: normX, y: normY));
      _redoPoints.clear();
    });
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
    });
  }

  void _onPanStart(DragStartDetails details, Size canvasSize) {
    if (_isDrawing || _activeZone == null) return;

    final touchX = details.localPosition.dx;
    final touchY = details.localPosition.dy;

    // Check if near any vertex in active zone (within 22px)
    for (int i = 0; i < _activeZone!.polygon.length; i++) {
      final vx = _activeZone!.polygon[i].x * canvasSize.width;
      final vy = _activeZone!.polygon[i].y * canvasSize.height;
      if ((touchX - vx).abs() < 22 && (touchY - vy).abs() < 22) {
        setState(() {
          _draggedVertexIndex = i;
        });
        return;
      }
    }
    _draggedVertexIndex = null;
  }

  void _onPanUpdate(DragUpdateDetails details, Size canvasSize) {
    if (_isDrawing || _activeZone == null || _draggedVertexIndex == null) return;

    final normX = (details.localPosition.dx / canvasSize.width).clamp(0.0, 1.0);
    final normY = (details.localPosition.dy / canvasSize.height).clamp(0.0, 1.0);

    final newPoly = List<PointN>.from(_activeZone!.polygon);
    newPoly[_draggedVertexIndex!] = PointN(x: normX, y: normY);

    setState(() {
      _activeZone = Zone(
        id: _activeZone!.id,
        cameraId: _activeZone!.cameraId,
        name: _activeZone!.name,
        kind: _activeZone!.kind,
        color: _activeZone!.color,
        polygon: newPoly,
        createdAt: _activeZone!.createdAt,
      );
    });
  }

  Future<void> _onPanEnd(DragEndDetails details) async {
    if (_draggedVertexIndex != null && _activeZone != null) {
      _draggedVertexIndex = null;
      final repo = ref.read(argusRepositoryProvider);
      await repo.saveZone(_activeZone!);
      _loadZones();
    }
  }

  void _showSaveZoneDialog() {
    if (_draftPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A zone polygon must have at least 3 points.')),
      );
      return;
    }

    final nameCtrl = TextEditingController(text: 'Restricted Zone ${_zones.length + 1}');
    String kind = 'restricted';
    String color = '#F43F5E';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: ArgusTokens.bgOverlay,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white, width: 1),
          ),
          title: Text('Name & Configure Zone', style: GoogleFonts.sora(fontSize: 16, color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameCtrl,
                style: GoogleFonts.inter(color: ArgusTokens.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Zone Name',
                  hintText: 'e.g. Vault Door, Cash Counter, Hazard Area',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: kind,
                dropdownColor: ArgusTokens.bgRaised,
                style: GoogleFonts.inter(color: ArgusTokens.textPrimary),
                decoration: const InputDecoration(labelText: 'Zone Category'),
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
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: ArgusTokens.textSecondary)),
            ),
            ElevatedButton(
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

                final saved = await repo.saveZone(newZone);
                setState(() {
                  _zones.add(saved);
                  _activeZone = saved;
                  _draftPoints.clear();
                  _redoPoints.clear();
                  _isDrawing = false;
                });
              },
              child: const Text('Save Zone'),
            ),
          ],
        ),
      ),
    );
  }

  void _applyPreset(String preset) {
    List<PointN> points = [];
    String kind = 'restricted';
    String color = '#F43F5E';

    // Sensible compact proportions: ~25% to 30% of canvas, perfectly positioned for interactive vertex adjustment
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
        PointN(x: 0.40, y: 0.30),
        PointN(x: 0.60, y: 0.30),
        PointN(x: 0.60, y: 0.75),
        PointN(x: 0.40, y: 0.75),
      ];
      kind = 'restricted';
      color = '#F43F5E';
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

    final nameCtrl = TextEditingController(text: '$preset Zone ${_zones.length + 1}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ArgusTokens.bgOverlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white, width: 1),
        ),
        title: Text('Add $preset Template', style: GoogleFonts.sora(fontSize: 16, color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameCtrl,
              style: GoogleFonts.inter(color: ArgusTokens.textPrimary),
              decoration: const InputDecoration(labelText: 'Custom Zone Name'),
            ),
            const SizedBox(height: 12),
            Text(
              'A resizable box will be placed on screen. You can drag any corner handle to resize or reposition it.',
              style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final saved = await ref.read(argusRepositoryProvider).saveZone(Zone(
                cameraId: widget.cameraId,
                name: nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : '$preset Zone',
                kind: kind,
                color: color,
                polygon: points,
                createdAt: DateTime.now(),
              ));
              setState(() {
                _zones.add(saved);
                _activeZone = saved;
                _isDrawing = false;
              });
            },
            child: const Text('Add Template'),
          ),
        ],
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
          side: const BorderSide(color: Colors.white, width: 1),
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: ArgusTokens.accent));
    }

    return Scaffold(
      backgroundColor: ArgusTokens.bgBase,
      body: Row(
        children: [
          // Left Area: Canvas Stage
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
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Zone Polygon Editor · Camera #${widget.cameraId}',
                        style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),

                      if (!_isDrawing) ...[
                        ElevatedButton.icon(
                          onPressed: () => setState(() {
                            _isDrawing = true;
                            _draftPoints.clear();
                            _redoPoints.clear();
                          }),
                          icon: const Icon(Icons.draw_rounded, size: 16),
                          label: const Text('Draw New Polygon'),
                        ),
                      ] else ...[
                        IconButton(
                          tooltip: 'Undo Last Point (Ctrl+Z)',
                          onPressed: _draftPoints.isNotEmpty ? _undoPoint : null,
                          icon: const Icon(Icons.undo_rounded, size: 20),
                          color: _draftPoints.isNotEmpty ? Colors.white : Colors.white24,
                        ),
                        IconButton(
                          tooltip: 'Redo Point (Ctrl+Y)',
                          onPressed: _redoPoints.isNotEmpty ? _redoPoint : null,
                          icon: const Icon(Icons.redo_rounded, size: 20),
                          color: _redoPoints.isNotEmpty ? Colors.white : Colors.white24,
                        ),
                        OutlinedButton(
                          onPressed: _clearDraft,
                          child: const Text('Clear'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => setState(() {
                            _isDrawing = false;
                            _draftPoints.clear();
                            _redoPoints.clear();
                          }),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _showSaveZoneDialog,
                          icon: const Icon(Icons.check_rounded, size: 16),
                          label: Text('Save Polygon (${_draftPoints.length} pts)'),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Helper instructions banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: ArgusTokens.bgOverlay,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: ArgusTokens.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 16, color: ArgusTokens.accent),
                        const SizedBox(width: 8),
                        Text(
                          _isDrawing
                              ? 'Click anywhere to add vertices. Connect at least 3 points, then click "Save Polygon".'
                              : 'Select any zone on the right to edit. Drag the circular corner handles to resize or reshape.',
                          style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Interactive Polygon Canvas (Strict 16:9 Camera FOV Locked)
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF070A0F),
                            borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // 1. Camera FOV Grid & Aspect-Ratio Guides
                              CustomPaint(
                                painter: _CameraGridPainter(),
                              ),

                              // 2. Interactive Gesture Layer & Zone Editor Painter
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final size = Size(constraints.maxWidth, constraints.maxHeight);

                                  return GestureDetector(
                                    onTapUp: (details) => _onCanvasTap(details, size),
                                    onPanStart: (details) => _onPanStart(details, size),
                                    onPanUpdate: (details) => _onPanUpdate(details, size),
                                    onPanEnd: _onPanEnd,
                                    child: CustomPaint(
                                      size: size,
                                      painter: _ZoneEditorPainter(
                                        zones: _zones,
                                        activeZone: _activeZone,
                                        draftPoints: _draftPoints,
                                        isDrawing: _isDrawing,
                                        draggedVertexIndex: _draggedVertexIndex,
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

          // Right Sidebar: Zones Management & Presets
          SizedBox(
            width: 330,
            child: Container(
              padding: const EdgeInsets.all(ArgusTokens.space20),
              decoration: const BoxDecoration(
                color: ArgusTokens.bgRaised,
                border: Border(left: BorderSide(color: Colors.white24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick Zone Templates', style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text('Adds a compact resizable box in the center', style: GoogleFonts.inter(fontSize: 11, color: ArgusTokens.textTertiary)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ActionChip(label: const Text('+ Danger Box'), onPressed: () => _applyPreset('Danger Area')),
                      ActionChip(label: const Text('+ Doorway Box'), onPressed: () => _applyPreset('Doorway')),
                      ActionChip(label: const Text('+ Staircase'), onPressed: () => _applyPreset('Staircase')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: ArgusTokens.borderSubtle),
                  const SizedBox(height: 12),

                  Text('Configured Zones (${_zones.length})', style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _zones.isEmpty
                        ? Center(
                            child: Text(
                              'No zones yet.\nDraw a polygon or add a template.',
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
                                onTap: () => setState(() => _activeZone = z),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSel ? zColor.withValues(alpha: 0.15) : ArgusTokens.bgOverlay,
                                    borderRadius: BorderRadius.circular(6),
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
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              z.name,
                                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
                                            ),
                                            Text(
                                              '${z.polygon.length} points · ${z.kind.toUpperCase()}',
                                              style: GoogleFonts.jetBrainsMono(fontSize: 10, color: ArgusTokens.textTertiary),
                                            ),
                                          ],
                                        ),
                                      ),
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
}

class _ZoneEditorPainter extends CustomPainter {
  final List<Zone> zones;
  final Zone? activeZone;
  final List<PointN> draftPoints;
  final bool isDrawing;
  final int? draggedVertexIndex;

  _ZoneEditorPainter({
    required this.zones,
    required this.activeZone,
    required this.draftPoints,
    required this.isDrawing,
    this.draggedVertexIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw saved zones
    for (final z in zones) {
      if (z.polygon.length < 3) continue;
      final isActive = activeZone?.id == z.id;

      final path = Path();
      path.moveTo(z.polygon.first.x * size.width, z.polygon.first.y * size.height);
      for (int i = 1; i < z.polygon.length; i++) {
        path.lineTo(z.polygon[i].x * size.width, z.polygon[i].y * size.height);
      }
      path.close();

      final col = Color(int.parse(z.color.replaceFirst('#', '0xFF')));
      canvas.drawPath(path, Paint()..color = col.withValues(alpha: isActive ? 0.35 : 0.18)..style = PaintingStyle.fill);
      canvas.drawPath(path, Paint()..color = col..style = PaintingStyle.stroke..strokeWidth = isActive ? 2.5 : 1.5);

      // Draw zone label in center
      double cx = 0, cy = 0;
      for (final p in z.polygon) {
        cx += p.x * size.width;
        cy += p.y * size.height;
      }
      cx /= z.polygon.length;
      cy /= z.polygon.length;

      final tp = TextPainter(
        text: TextSpan(
          text: z.name,
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            backgroundColor: Colors.black.withValues(alpha: 0.6),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));

      // Draw interactive draggable handles for active zone
      if (isActive && !isDrawing) {
        for (int i = 0; i < z.polygon.length; i++) {
          final p = z.polygon[i];
          final pos = Offset(p.x * size.width, p.y * size.height);
          final isDragged = draggedVertexIndex == i;

          // Outer ring
          canvas.drawCircle(
            pos,
            isDragged ? 9 : 7,
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.fill,
          );
          // Inner core
          canvas.drawCircle(
            pos,
            isDragged ? 6 : 4,
            Paint()
              ..color = col
              ..style = PaintingStyle.fill,
          );
        }
      } else {
        // Non-active points
        for (final p in z.polygon) {
          canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), 3.5, Paint()..color = col);
        }
      }
    }

    // 2. Draw draft points while drawing
    if (isDrawing && draftPoints.isNotEmpty) {
      final draftPaint = Paint()
        ..color = ArgusTokens.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      for (int i = 0; i < draftPoints.length - 1; i++) {
        canvas.drawLine(
          Offset(draftPoints[i].x * size.width, draftPoints[i].y * size.height),
          Offset(draftPoints[i + 1].x * size.width, draftPoints[i + 1].y * size.height),
          draftPaint,
        );
      }

      for (int i = 0; i < draftPoints.length; i++) {
        final p = draftPoints[i];
        final pos = Offset(p.x * size.width, p.y * size.height);
        canvas.drawCircle(pos, 6, Paint()..color = Colors.white);
        canvas.drawCircle(pos, 4, Paint()..color = ArgusTokens.accent);

        // Point number badge
        final tp = TextPainter(
          text: TextSpan(
            text: '${i + 1}',
            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(pos.dx + 6, pos.dy - 12));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ZoneEditorPainter oldDelegate) => true;
}

class _CameraGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Grid lines (rule of thirds)
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(w / 3, 0), Offset(w / 3, h), gridPaint);
    canvas.drawLine(Offset(2 * w / 3, 0), Offset(2 * w / 3, h), gridPaint);
    canvas.drawLine(Offset(0, h / 3), Offset(w, h / 3), gridPaint);
    canvas.drawLine(Offset(0, 2 * h / 3), Offset(w, 2 * h / 3), gridPaint);

    // 2. Corner brackets
    final cornerPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const len = 24.0;
    // Top-left
    canvas.drawLine(const Offset(10, 10), const Offset(10 + len, 10), cornerPaint);
    canvas.drawLine(const Offset(10, 10), const Offset(10, 10 + len), cornerPaint);
    // Top-right
    canvas.drawLine(Offset(w - 10, 10), Offset(w - 10 - len, 10), cornerPaint);
    canvas.drawLine(Offset(w - 10, 10), Offset(w - 10, 10 + len), cornerPaint);
    // Bottom-left
    canvas.drawLine(Offset(10, h - 10), Offset(10 + len, h - 10), cornerPaint);
    canvas.drawLine(Offset(10, h - 10), Offset(10, h - 10 - len), cornerPaint);
    // Bottom-right
    canvas.drawLine(Offset(w - 10, h - 10), Offset(w - 10 - len, h - 10), cornerPaint);
    canvas.drawLine(Offset(w - 10, h - 10), Offset(w - 10, h - 10 - len), cornerPaint);

    // 3. 16:9 Cam FOV badge
    final tp = TextPainter(
      text: const TextSpan(
        text: 'CAM 16:9 FOV (1280 × 720) · 100% PERSPECTIVE LOCK',
        style: TextStyle(
          color: Colors.white30,
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
