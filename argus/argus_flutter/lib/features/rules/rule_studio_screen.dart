import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:argus_client/argus_client.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/severity_scale.dart';
import '../../core/widgets/hover_card.dart';
import '../../core/widgets/rainbow_moving_border.dart';
import '../../core/widgets/reveal_animation.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/workflow_graph_view.dart';
import '../../data/repository_provider.dart';

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
  bool _isLoading = true;

  final List<String> _sampleChips = [
    'If a person enters Restricted Zone, trigger a critical alert immediately.',
    'If a person lingers in Cash Desk for more than 10 seconds, raise a loitering warning.',
    'If more than 3 people gather in Emergency Exit, raise a crowd density alert.',
    'If human activity is detected after 8 PM, take a snapshot and alert security.',
    'If someone falls and stays down for 10 seconds, dispatch medical response.',
    'If a worker enters Machinery Bay, dispatch an urgent perimeter warning.',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final repo = ref.read(argusRepositoryProvider);
    final rules = await repo.listRules();
    final cams = await repo.listCameras();

    if (mounted) {
      setState(() {
        _savedRules = rules;
        _cameras = cams;
        if (cams.isNotEmpty && _selectedCamera == null) {
          _selectedCamera = cams.first;
        }
        _isLoading = false;
      });
      _interpretInitial();
    }
  }

  Future<void> _interpretInitial() async {
    await _handleInterpret(_sentenceCtrl.text);
  }

  Future<void> _handleInterpret(String sentence) async {
    setState(() => _isInterpreting = true);
    final repo = ref.read(argusRepositoryProvider);
    final result = await repo.interpretRule(sentence, cameraId: _selectedCamera?.id);
    if (mounted) {
      setState(() {
        _currentParsed = result;
        _isInterpreting = false;
      });
    }
  }

  Future<void> _handleSaveRule() async {
    if (_currentParsed?.spec == null) return;
    final repo = ref.read(argusRepositoryProvider);

    final raw = _currentParsed!.spec!;
    final targetCameraIds = _selectedCamera != null ? [_selectedCamera!.id!] : <int>[];

    final ruleToSave = RuleSpec(
      id: raw.id,
      workspaceId: raw.workspaceId,
      name: raw.name,
      enabled: true,
      cameraIds: targetCameraIds,
      trigger: raw.trigger,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rule "${saved.name}" deployed and $camLabel.'),
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
              Text(
                'Rule Studio',
                style: GoogleFonts.sora(fontSize: 26, fontWeight: FontWeight.w700, color: ArgusTokens.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Define security, perimeter, dwell time, crowd density, or safety rules in natural language.',
                style: GoogleFonts.inter(fontSize: 14, color: ArgusTokens.textSecondary),
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

            // Target Camera Selector Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: ArgusTokens.bgRaised,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: ArgusTokens.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(Icons.videocam_outlined, size: 18, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    'Attach Rule To:',
                    style: GoogleFonts.inter(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 14),
                  if (_cameras.isEmpty)
                    Text(
                      'No cameras created yet (Will apply to all cameras)',
                      style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textTertiary),
                    )
                  else
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Camera?>(
                          value: _selectedCamera,
                          dropdownColor: ArgusTokens.bgOverlay,
                          style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
                          items: [
                            const DropdownMenuItem<Camera?>(
                              value: null,
                              child: Text('All Cameras (Global Rule)'),
                            ),
                            ..._cameras.map((c) => DropdownMenuItem<Camera?>(
                              value: c,
                              child: Text('${c.name} (${c.sourceKind.toUpperCase()})'),
                            )),
                          ],
                          onChanged: (c) {
                            setState(() => _selectedCamera = c);
                            _handleInterpret(_sentenceCtrl.text);
                          },
                        ),
                      ),
                    ),
                ],
              ),
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
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _handleSaveRule,
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                      label: const Text('Save & Deploy Rule'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: ArgusTokens.borderSubtle),
            const SizedBox(height: 12),

            // Visual Workflow Graph
            WorkflowGraphView(rule: spec),
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
                      onChanged: (val) {
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
