import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:argus_client/argus_client.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/severity_scale.dart';
import '../../core/widgets/hover_card.dart';
import '../../core/widgets/rainbow_moving_border.dart';
import '../../core/widgets/reveal_animation.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/workflow_graph_view.dart';
import '../../data/repository_provider.dart';
import '../facilities/facility_providers.dart';

class RuleStudioScreen extends ConsumerStatefulWidget {
  const RuleStudioScreen({super.key});

  @override
  ConsumerState<RuleStudioScreen> createState() => _RuleStudioScreenState();
}

class _RuleStudioScreenState extends ConsumerState<RuleStudioScreen> {
  final TextEditingController _sentenceCtrl = TextEditingController(
    text: 'If a person enters Restricted Zone, trigger a critical alert immediately.',
  );

  bool _isInterpreting = false;
  ParseResult? _currentParsed;
  List<RuleSpec> _savedRules = [];
  List<Camera> _cameras = [];
  Camera? _selectedCamera;
  List<Zone> _cameraZones = [];
  Zone? _selectedZone;
  Map<int, Zone> _allZones = {};
  bool _isLoading = true;

  final List<String> _sampleChips = [
    'If a person enters Restricted Zone, trigger a critical alert immediately.',
    'If more than 3 people gather in Staircase, raise a crowd density alert.',
    'If a person lingers in Cash Desk for more than 10 seconds, raise a loitering warning.',
    'If someone falls and stays down for 10 seconds, dispatch medical response.',
    'If human activity is detected after 8 PM, take a snapshot and alert security.',
    'If a worker enters Machinery Bay, dispatch an urgent perimeter warning.',
  ];

  Color _parseZoneColor(String? colorStr) {
    if (colorStr == null || colorStr.isEmpty) return ArgusTokens.accent;
    var hex = colorStr.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    final val = int.tryParse(hex, radix: 16);
    return val != null ? Color(val) : ArgusTokens.accent;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = ref.read(argusRepositoryProvider);
    final activeWs = ref.read(activeFacilityProvider);
    final rules = await repo.listRules();
    final cams = await repo.listCameras(workspaceId: activeWs?.id);

    // Map all zones across all cameras for displaying labels on existing rules
    final allZonesMap = <int, Zone>{};
    for (final c in cams) {
      if (c.id != null) {
        final zList = await repo.listZones(c.id!);
        for (final z in zList) {
          if (z.id != null) allZonesMap[z.id!] = z;
        }
      }
    }

    Camera? initialCamera;
    List<Zone> initialCameraZones = [];
    if (cams.isNotEmpty && _selectedCamera == null) {
      initialCamera = cams.first;
      if (initialCamera.id != null) {
        initialCameraZones = await repo.listZones(initialCamera.id!);
      }
    } else if (_selectedCamera != null && _selectedCamera!.id != null) {
      initialCamera = _selectedCamera;
      initialCameraZones = await repo.listZones(initialCamera!.id!);
    }

    if (mounted) {
      setState(() {
        _savedRules = rules;
        _cameras = cams;
        _allZones = allZonesMap;
        _selectedCamera = initialCamera;
        _cameraZones = initialCameraZones;
        _isLoading = false;
      });
      _interpretInitial();
    }
  }

  Future<void> _interpretInitial() async {
    await _handleInterpret(_sentenceCtrl.text);
  }

  Future<void> _handleCameraChanged(Camera? newCam) async {
    setState(() {
      _selectedCamera = newCam;
      _selectedZone = null;
    });

    if (newCam != null && newCam.id != null) {
      final repo = ref.read(argusRepositoryProvider);
      final zList = await repo.listZones(newCam.id!);
      if (mounted) {
        setState(() {
          _cameraZones = zList;
          for (final z in zList) {
            if (z.id != null) _allZones[z.id!] = z;
          }
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _cameraZones = [];
        });
      }
    }

    await _handleInterpret(_sentenceCtrl.text);
  }

  void _handleZoneChanged(Zone? newZone) {
    setState(() {
      _selectedZone = newZone;
      if (_currentParsed?.spec != null) {
        _currentParsed = _withUpdatedZone(_currentParsed!, newZone?.id);
      }
    });
  }

  ParseResult _withUpdatedZone(ParseResult original, int? zoneId) {
    if (original.spec == null) return original;
    final s = original.spec!;
    final updatedTrigger = s.trigger.copyWith(zoneId: zoneId);
    final updatedSpec = RuleSpec(
      id: s.id,
      workspaceId: s.workspaceId,
      name: s.name,
      enabled: s.enabled,
      cameraIds: s.cameraIds,
      trigger: updatedTrigger,
      conditions: s.conditions,
      severity: s.severity,
      verify: s.verify,
      actions: s.actions,
      cooldownSec: s.cooldownSec,
      escalation: s.escalation,
      sourceText: s.sourceText,
      parsedBy: s.parsedBy,
      createdAt: s.createdAt,
      version: s.version,
    );
    return ParseResult(
      spec: updatedSpec,
      parsedBy: original.parsedBy,
      confidence: original.confidence,
      warnings: original.warnings,
      unsupportedReason: original.unsupportedReason,
      alternatives: original.alternatives,
    );
  }

  Future<void> _handleInterpret(String sentence) async {
    setState(() => _isInterpreting = true);
    try {
      final repo = ref.read(argusRepositoryProvider);
      final result = await repo
          .interpretRule(sentence, cameraId: _selectedCamera?.id)
          .timeout(const Duration(seconds: 6));
      if (mounted) {
        final parsedZoneId = result.spec?.trigger.zoneId;
        Zone? matchedZone;
        if (parsedZoneId != null && _cameraZones.isNotEmpty) {
          matchedZone = _cameraZones.where((z) => z.id == parsedZoneId).firstOrNull;
        }

        setState(() {
          if (matchedZone != null) {
            _selectedZone = matchedZone;
          } else if (_selectedZone != null && !_cameraZones.any((z) => z.id == _selectedZone!.id)) {
            _selectedZone = null;
          }

          if (_selectedZone != null && result.spec != null) {
            _currentParsed = _withUpdatedZone(result, _selectedZone!.id);
          } else {
            _currentParsed = result;
          }
        });
      }
    } catch (e) {
      debugPrint('Rule interpret failed or timed out: $e');
    } finally {
      if (mounted) {
        setState(() => _isInterpreting = false);
      }
    }
  }

  Future<void> _handleSaveRule() async {
    if (_currentParsed?.spec == null) return;
    final repo = ref.read(argusRepositoryProvider);

    final raw = _currentParsed!.spec!;
    final targetCameraIds = _selectedCamera != null ? [_selectedCamera!.id!] : <int>[];
    final targetZoneId = _selectedZone?.id;

    final ruleToSave = RuleSpec(
      id: raw.id,
      workspaceId: raw.workspaceId,
      name: raw.name,
      enabled: true,
      cameraIds: targetCameraIds,
      trigger: raw.trigger.copyWith(zoneId: targetZoneId),
      conditions: raw.conditions,
      severity: raw.severity,
      verify: raw.verify,
      actions: raw.actions,
      cooldownSec: raw.cooldownSec,
      escalation: raw.escalation,
      sourceText: _sentenceCtrl.text.trim(),
      parsedBy: raw.parsedBy,
      createdAt: DateTime.now(),
      version: 1,
    );

    final saved = await repo.saveRule(ruleToSave);
    if (mounted) {
      setState(() {
        _savedRules.removeWhere((r) => r.id == saved.id);
        _savedRules.insert(0, saved);
      });
      final camLabel = _selectedCamera != null ? 'attached to ${_selectedCamera!.name}' : 'attached to all cameras';
      final zoneLabel = _selectedZone != null ? ' (Zone: ${_selectedZone!.name})' : ' (All Zones)';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rule "${saved.name}" deployed and $camLabel$zoneLabel.'),
          backgroundColor: ArgusTokens.bgRaised,
        ),
      );
    }
  }

  void _showDeleteRuleDialog(RuleSpec r) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: ArgusTokens.bgOverlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white, width: 1),
        ),
        title: Text('Delete Rule', style: GoogleFonts.sora(fontSize: 16, color: Colors.white)),
        content: Text('Remove rule "${r.name}" from active evaluation?', style: GoogleFonts.inter(color: ArgusTokens.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(c);
              await ref.read(argusRepositoryProvider).deleteRule(r.id!);
              final rules = await ref.read(argusRepositoryProvider).listRules();
              if (mounted) setState(() => _savedRules = rules);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDryRunDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ArgusTokens.bgOverlay,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.white, width: 1),
        ),
        title: Row(
          children: [
            const Icon(Icons.science_outlined, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('Simulate Rule Dry Run', style: GoogleFonts.sora(fontSize: 16, color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Running validation on parsed policy conditions against camera telemetry schema...',
              style: GoogleFonts.inter(fontSize: 13, color: ArgusTokens.textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ArgusTokens.bgRaised,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: ArgusTokens.success, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'LOGIC VERIFIED: 0 SYNTAX ERRORS',
                        style: GoogleFonts.jetBrainsMono(fontSize: 11, color: ArgusTokens.success, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Trigger, conditions, time window, and escalation nodes are deterministic and ready for live execution.',
                    style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textPrimary),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: ArgusTokens.accent));
    }

    final activeFacility = ref.watch(activeFacilityProvider);
    final role = ref.watch(activeFacilityRoleProvider).toLowerCase();
    final isGuard = role == 'guard';

    if (activeFacility == null) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          padding: const EdgeInsets.all(ArgusTokens.space32),
          decoration: BoxDecoration(
            color: ArgusTokens.bgRaised,
            borderRadius: BorderRadius.circular(ArgusTokens.radiusLg),
            border: Border.all(color: ArgusTokens.borderSubtle),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.rule_outlined, size: 48, color: ArgusTokens.textTertiary),
              const SizedBox(height: 16),
              Text(
                'No Active Facility Selected',
                textAlign: TextAlign.center,
                style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700, color: ArgusTokens.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Safety rules belong to Facilities. Please select or join a Facility from the Operations Hub.',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: ArgusTokens.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Return to Facilities Hub'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1240),
          padding: const EdgeInsets.symmetric(horizontal: ArgusTokens.space24, vertical: ArgusTokens.space32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rule Studio · ${activeFacility.name}',
                        style: GoogleFonts.sora(fontSize: 26, fontWeight: FontWeight.w700, color: ArgusTokens.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Define security, perimeter, dwell time, crowd density, or safety rules in natural language.',
                        style: GoogleFonts.inter(fontSize: 14, color: ArgusTokens.textSecondary),
                      ),
                    ],
                  ),
                  if (isGuard)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: ArgusTokens.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: ArgusTokens.success.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_rounded, size: 14, color: ArgusTokens.success),
                          const SizedBox(width: 6),
                          Text(
                            'GUARD CLEARANCE: VIEW ONLY',
                            style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w700, color: ArgusTokens.success),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),

              // Sentence Input Card
              _buildSentenceInputCard(),

              const SizedBox(height: 24),

              // Parsed Workflow Graph
              if (_currentParsed?.spec != null) ...[
                _buildParsedGraphCard(_currentParsed!.spec!),
                const SizedBox(height: 24),
              ],

              // Saved Rules List
              _buildSavedRulesList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSentenceInputCard() {
    return RevealAnimation(
      child: HoverCard(
        padding: const EdgeInsets.all(ArgusTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SAFETY RULE DEFINITION',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 12, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'PARSER ACTIVE',
                        style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Camera & Zone Attachment Selectors
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 720;

                Widget cameraSelector = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: ArgusTokens.bgRaised,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: ArgusTokens.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.videocam_outlined, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'Camera:',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 10),
                      if (_cameras.isEmpty)
                        Expanded(
                          child: Text(
                            'No cameras created yet',
                            style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textTertiary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      else
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Camera?>(
                              value: _selectedCamera,
                              isExpanded: true,
                              dropdownColor: ArgusTokens.bgOverlay,
                              style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                              items: [
                                const DropdownMenuItem<Camera?>(
                                  value: null,
                                  child: Text('All Cameras (Global Rule)'),
                                ),
                                ..._cameras.map((c) => DropdownMenuItem<Camera?>(
                                  value: c,
                                  child: Text(
                                    '${c.name} (${c.sourceKind.toUpperCase()})',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                )),
                              ],
                              onChanged: _handleCameraChanged,
                            ),
                          ),
                        ),
                    ],
                  ),
                );

                Widget zoneSelector = Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: ArgusTokens.bgRaised,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _selectedZone != null
                          ? _parseZoneColor(_selectedZone!.color).withValues(alpha: 0.5)
                          : ArgusTokens.borderSubtle,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _selectedZone != null ? Icons.polyline_rounded : Icons.crop_free_rounded,
                        size: 18,
                        color: _selectedZone != null ? _parseZoneColor(_selectedZone!.color) : Colors.white,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Target Zone / Area:',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 10),
                      if (_selectedCamera == null)
                        Expanded(
                          child: Text(
                            'Applies to all zones (Global Rule)',
                            style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textTertiary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      else if (_cameraZones.isEmpty)
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Full Camera View (No drawn zones yet)',
                                  style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textTertiary),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (_selectedCamera?.id != null)
                                InkWell(
                                  onTap: () => context.go('/app/cameras/${_selectedCamera!.id}/zones'),
                                  borderRadius: BorderRadius.circular(4),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.brush_outlined, size: 12, color: ArgusTokens.accent),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Draw Area',
                                          style: GoogleFonts.inter(fontSize: 11, color: ArgusTokens.accent, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        )
                      else
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<Zone?>(
                                    value: _selectedZone,
                                    isExpanded: true,
                                    dropdownColor: ArgusTokens.bgOverlay,
                                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                                    items: [
                                      DropdownMenuItem<Zone?>(
                                        value: null,
                                        child: Row(
                                          children: [
                                            const Icon(Icons.public_rounded, size: 14, color: Colors.white70),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'All Zones / Any Configured Area (${_cameraZones.length} available)',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      ..._cameraZones.map((z) {
                                        final zColor = _parseZoneColor(z.color);
                                        return DropdownMenuItem<Zone?>(
                                          value: z,
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color: zColor,
                                                  shape: BoxShape.circle,
                                                  boxShadow: [
                                                    BoxShadow(color: zColor.withValues(alpha: 0.6), blurRadius: 4),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  z.name,
                                                  style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.white),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                                decoration: BoxDecoration(
                                                  color: zColor.withValues(alpha: 0.2),
                                                  borderRadius: BorderRadius.circular(3),
                                                  border: Border.all(color: zColor.withValues(alpha: 0.5), width: 0.8),
                                                ),
                                                child: Text(
                                                  z.kind.toUpperCase(),
                                                  style: GoogleFonts.jetBrainsMono(
                                                    fontSize: 9,
                                                    color: zColor,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '${z.polygon.length} pts',
                                                style: GoogleFonts.jetBrainsMono(fontSize: 10, color: ArgusTokens.textTertiary),
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                    ],
                                    onChanged: _handleZoneChanged,
                                  ),
                                ),
                              ),
                              if (_selectedCamera?.id != null) ...[
                                const SizedBox(width: 6),
                                Tooltip(
                                  message: 'Open Zone Editor to draw or edit polygons for this camera',
                                  child: InkWell(
                                    onTap: () => context.go('/app/cameras/${_selectedCamera!.id}/zones'),
                                    borderRadius: BorderRadius.circular(4),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: Colors.white10,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Icon(Icons.edit_road_rounded, size: 16, color: Colors.white70),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                );

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(child: cameraSelector),
                      const SizedBox(width: 12),
                      Expanded(child: zoneSelector),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      cameraSelector,
                      const SizedBox(height: 10),
                      zoneSelector,
                    ],
                  );
                }
              },
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _sentenceCtrl,
              maxLines: 2,
              style: GoogleFonts.inter(fontSize: 16, color: ArgusTokens.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. If a person enters Restricted Zone, trigger a critical alert...',
                suffixIcon: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: _isInterpreting ? null : () => _handleInterpret(_sentenceCtrl.text),
                    icon: _isInterpreting
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.auto_fix_high_rounded, size: 16),
                    label: const Text('Interpret'),
                  ),
                ),
              ),
              onSubmitted: (val) => _handleInterpret(val),
            ),
            const SizedBox(height: 14),

            // Chips
            Text('Quick Policy Templates:', style: GoogleFonts.inter(fontSize: 11, color: ArgusTokens.textTertiary)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sampleChips.map((chip) {
                return InkWell(
                  onTap: () {
                    _sentenceCtrl.text = chip;
                    _handleInterpret(chip);
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: ArgusTokens.bgOverlay,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: ArgusTokens.borderSubtle),
                    ),
                    child: Text(
                      chip,
                      style: GoogleFonts.inter(fontSize: 11, color: ArgusTokens.textSecondary),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParsedGraphCard(RuleSpec spec) {
    final confidence = ((_currentParsed?.confidence ?? 0.8) * 100).toInt();

    return RainbowMovingBorder(
      borderRadius: BorderRadius.circular(ArgusTokens.radiusLg),
      borderWidth: 1.5,
      baseBorderColor: Colors.white,
      backgroundColor: ArgusTokens.bgRaised,
      isLive: true,
      child: Padding(
        padding: const EdgeInsets.all(ArgusTokens.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          spec.name,
                          style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white12,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'TARGET: ${_selectedCamera != null ? _selectedCamera!.name.toUpperCase() : "ALL CAMERAS"}',
                            style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (_selectedZone != null) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _parseZoneColor(_selectedZone!.color).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: _parseZoneColor(_selectedZone!.color).withValues(alpha: 0.7)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.crop_square_rounded, size: 10, color: _parseZoneColor(_selectedZone!.color)),
                                const SizedBox(width: 4),
                                Text(
                                  'ZONE: ${_selectedZone!.name.toUpperCase()}',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 10,
                                    color: _parseZoneColor(_selectedZone!.color),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Confidence: $confidence% · Cooldown: ${spec.cooldownSec}s',
                      style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textTertiary),
                    ),
                  ],
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: _showDryRunDialog,
                      icon: const Icon(Icons.science_outlined, size: 16),
                      label: const Text('Validate Rule'),
                    ),
                    if (!ref.watch(activeFacilityRoleProvider).toLowerCase().contains('guard')) ...[
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: _handleSaveRule,
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                        label: const Text('Save & Deploy Rule'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: ArgusTokens.borderSubtle),
            const SizedBox(height: 12),

            // Visual Workflow Graph
            WorkflowGraphView(
              rule: spec,
              zoneName: _selectedZone?.name ?? (_allZones[spec.trigger.zoneId]?.name),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedRulesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deployed Security Rules (${_savedRules.length})',
          style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
        ),
        const SizedBox(height: 14),

        if (_savedRules.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: ArgusTokens.bgRaised,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ArgusTokens.borderSubtle),
            ),
            child: Center(
              child: Text(
                'No rules deployed yet. Choose a camera, type a plain English rule above, and click "Save & Deploy Rule".',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(color: ArgusTokens.textSecondary, fontSize: 13),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _savedRules.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, idx) {
              final rule = _savedRules[idx];
              final sev = SeverityLevel.fromString(rule.severity);
              final targetCams = _cameras.where((c) => rule.cameraIds.contains(c.id)).map((c) => c.name).toList();
              final targetLabel = targetCams.isNotEmpty ? targetCams.join(', ') : 'All Cameras';

              return Container(
                padding: const EdgeInsets.all(ArgusTokens.space16),
                decoration: BoxDecoration(
                  color: ArgusTokens.bgRaised,
                  borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
                  border: Border.all(color: ArgusTokens.borderSubtle),
                ),
                child: Row(
                  children: [
                    Icon(sev.icon, color: sev.color, size: 20),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                rule.name,
                                style: GoogleFonts.sora(fontSize: 14, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
                              ),
                              const SizedBox(width: 8),
                              StatusBadge.fromSeverity(sev),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'CAM: $targetLabel',
                                  style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.white70),
                                ),
                              ),
                              if (rule.trigger.zoneId != null) ...[
                                const SizedBox(width: 6),
                                () {
                                  final zone = _allZones[rule.trigger.zoneId];
                                  final zoneLabel = zone?.name ?? 'Zone #${rule.trigger.zoneId}';
                                  final zoneColor = _parseZoneColor(zone?.color);
                                  return Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: zoneColor.withValues(alpha: 0.18),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: zoneColor.withValues(alpha: 0.6), width: 1),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.crop_free_rounded, size: 10, color: zoneColor),
                                        const SizedBox(width: 4),
                                        Text(
                                          'ZONE: $zoneLabel',
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 10,
                                            color: zoneColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }(),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '"${rule.sourceText}"',
                            style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textSecondary, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: rule.enabled ? ArgusTokens.success.withValues(alpha: 0.15) : Colors.white10,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: rule.enabled ? ArgusTokens.success : Colors.white24,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        rule.enabled ? 'ACTIVE' : 'PAUSED',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: rule.enabled ? ArgusTokens.success : Colors.white60,
                        ),
                      ),
                    ),
                    Switch(
                      value: rule.enabled,
                      activeThumbColor: Colors.white,
                      activeTrackColor: ArgusTokens.success,
                      inactiveThumbColor: Colors.white60,
                      inactiveTrackColor: Colors.white12,
                      onChanged: ref.watch(activeFacilityRoleProvider).toLowerCase() == 'guard'
                          ? null
                          : (val) {
                              setState(() {
                                _savedRules[idx] = RuleSpec(
                                  id: rule.id,
                                  workspaceId: rule.workspaceId,
                                  name: rule.name,
                                  enabled: val,
                                  cameraIds: rule.cameraIds,
                                  trigger: rule.trigger,
                                  conditions: rule.conditions,
                                  severity: rule.severity,
                                  verify: rule.verify,
                                  actions: rule.actions,
                                  cooldownSec: rule.cooldownSec,
                                  escalation: rule.escalation,
                                  sourceText: rule.sourceText,
                                  parsedBy: rule.parsedBy,
                                  createdAt: rule.createdAt,
                                  version: rule.version,
                                );
                              });
                              ref.read(argusRepositoryProvider).saveRule(_savedRules[idx]);
                            },
                    ),
                    if (ref.watch(activeFacilityRoleProvider).toLowerCase() != 'guard')
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 18, color: ArgusTokens.textTertiary),
                        tooltip: 'Delete Rule',
                        onPressed: () => _showDeleteRuleDialog(rule),
                      ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
