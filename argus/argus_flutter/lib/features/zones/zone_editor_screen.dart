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
  bool _isDrawing = false;
  bool _isLoading = true;

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
        if (list.isNotEmpty) _activeZone = list.first;
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
    });
  }

  Future<void> _finishPolygon() async {
    if (_draftPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A zone must have at least 3 points.')),
      );
      return;
    }

    final repo = ref.read(argusRepositoryProvider);
    final newZone = Zone(
      cameraId: widget.cameraId,
      name: 'Custom Zone ${_zones.length + 1}',
      kind: 'restricted',
      color: '#F43F5E',
      polygon: List.from(_draftPoints),
      createdAt: DateTime.now(),
    );

    final saved = await repo.saveZone(newZone);
    setState(() {
      _zones.add(saved);
      _activeZone = saved;
      _draftPoints.clear();
      _isDrawing = false;
    });
  }

  void _applyPreset(String preset) {
    List<PointN> points = [];
    String kind = 'restricted';
    String color = '#F43F5E';

    if (preset == 'Staircase') {
      points = [PointN(x: 0.2, y: 0.3), PointN(x: 0.8, y: 0.3), PointN(x: 0.8, y: 0.9), PointN(x: 0.2, y: 0.9)];
      kind = 'stairs';
      color = '#A78BFA';
    } else if (preset == 'Doorway') {
      points = [PointN(x: 0.4, y: 0.2), PointN(x: 0.6, y: 0.2), PointN(x: 0.6, y: 0.8), PointN(x: 0.4, y: 0.8)];
      kind = 'restricted';
      color = '#F43F5E';
    } else {
      points = [PointN(x: 0.1, y: 0.1), PointN(x: 0.9, y: 0.1), PointN(x: 0.9, y: 0.9), PointN(x: 0.1, y: 0.9)];
      kind = 'work';
      color = '#FBBF24';
    }

    ref.read(argusRepositoryProvider).saveZone(Zone(
      cameraId: widget.cameraId,
      name: '$preset Zone',
      kind: kind,
      color: color,
      polygon: points,
      createdAt: DateTime.now(),
    )).then((z) {
      setState(() {
        _zones.add(z);
        _activeZone = z;
      });
    });
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
                      Text('Zone Polygon Editor · Camera #${widget.cameraId}', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700)),
                      const Spacer(),
                      if (!_isDrawing)
                        ElevatedButton.icon(
                          onPressed: () => setState(() => _isDrawing = true),
                          icon: const Icon(Icons.draw_rounded, size: 16),
                          label: const Text('Draw New Polygon'),
                        )
                      else ...[
                        OutlinedButton(
                          onPressed: () => setState(() { _isDrawing = false; _draftPoints.clear(); }),
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _finishPolygon,
                          icon: const Icon(Icons.check_rounded, size: 16),
                          label: Text('Close & Save (${_draftPoints.length} pts)'),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Interactive Polygon Canvas
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
                        border: Border.all(color: ArgusTokens.borderSubtle),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final size = Size(constraints.maxWidth, constraints.maxHeight);
                          return GestureDetector(
                            onTapUp: (details) => _onCanvasTap(details, size),
                            child: CustomPaint(
                              size: size,
                              painter: _ZoneEditorPainter(
                                zones: _zones,
                                activeZone: _activeZone,
                                draftPoints: _draftPoints,
                                isDrawing: _isDrawing,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Sidebar: Zones Management & Presets
          SizedBox(
            width: 320,
            child: Container(
              padding: const EdgeInsets.all(ArgusTokens.space20),
              decoration: const BoxDecoration(
                color: ArgusTokens.bgRaised,
                border: Border(left: BorderSide(color: ArgusTokens.borderSubtle)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Zone Presets', style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ActionChip(label: const Text('Staircase'), onPressed: () => _applyPreset('Staircase')),
                      ActionChip(label: const Text('Doorway'), onPressed: () => _applyPreset('Doorway')),
                      ActionChip(label: const Text('Danger Area'), onPressed: () => _applyPreset('Danger Area')),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: ArgusTokens.borderSubtle),
                  const SizedBox(height: 16),

                  Text('Configured Zones (${_zones.length})', style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _zones.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, idx) {
                        final z = _zones[idx];
                        final isSel = _activeZone?.id == z.id;
                        return InkWell(
                          onTap: () => setState(() => _activeZone = z),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSel ? ArgusTokens.accent.withValues(alpha: 0.12) : ArgusTokens.bgOverlay,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isSel ? ArgusTokens.accent.withValues(alpha: 0.6) : ArgusTokens.borderSubtle,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: Color(int.parse(z.color.replaceFirst('#', '0xFF'))),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    z.name,
                                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: ArgusTokens.textTertiary),
                                  onPressed: () async {
                                    await ref.read(argusRepositoryProvider).deleteZone(z.id!);
                                    _loadZones();
                                  },
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

  _ZoneEditorPainter({
    required this.zones,
    required this.activeZone,
    required this.draftPoints,
    required this.isDrawing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw saved zones
    for (final z in zones) {
      if (z.polygon.length < 3) continue;

      final path = Path();
      path.moveTo(z.polygon.first.x * size.width, z.polygon.first.y * size.height);
      for (int i = 1; i < z.polygon.length; i++) {
        path.lineTo(z.polygon[i].x * size.width, z.polygon[i].y * size.height);
      }
      path.close();

      final col = Color(int.parse(z.color.replaceFirst('#', '0xFF')));
      canvas.drawPath(path, Paint()..color = col.withValues(alpha: 0.2)..style = PaintingStyle.fill);
      canvas.drawPath(path, Paint()..color = col..style = PaintingStyle.stroke..strokeWidth = 2.0);

      // Draw handles
      for (final p in z.polygon) {
        canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), 4, Paint()..color = col);
      }
    }

    // 2. Draw draft points while drawing
    if (isDrawing && draftPoints.isNotEmpty) {
      final draftPaint = Paint()..color = ArgusTokens.accent..style = PaintingStyle.stroke..strokeWidth = 2.0;

      for (int i = 0; i < draftPoints.length - 1; i++) {
        canvas.drawLine(
          Offset(draftPoints[i].x * size.width, draftPoints[i].y * size.height),
          Offset(draftPoints[i + 1].x * size.width, draftPoints[i + 1].y * size.height),
          draftPaint,
        );
      }

      for (final p in draftPoints) {
        canvas.drawCircle(Offset(p.x * size.width, p.y * size.height), 5, Paint()..color = ArgusTokens.accent);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ZoneEditorPainter oldDelegate) => true;
}
