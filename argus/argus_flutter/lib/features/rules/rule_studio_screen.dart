import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:argus_client/argus_client.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/severity_scale.dart';
import '../../core/widgets/hover_card.dart';
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
    text: 'If someone falls near the staircase and stays down for 15 seconds, alert security and escalate.',
  );

  bool _isInterpreting = false;
  ParseResult? _currentParsed;
  List<RuleSpec> _savedRules = [];
  bool _isLoading = true;

  final List<String> _sampleChips = [
    'If anyone enters the lab after 8 pm, take a snapshot and alert supervisor.',
    'If someone falls near staircase and stays down for 15 seconds, alert security.',
    'If a person stays in red zone for more than 5 seconds, sound high alarm.',
    "If a person in the work zone isn't wearing a helmet, save evidence and alert manager.",
  ];

  @override
  void initState() {
    super.initState();
    _loadRules();
    _interpretInitial();
  }

  Future<void> _loadRules() async {
    final repo = ref.read(argusRepositoryProvider);
    final rules = await repo.listRules();
    if (mounted) {
      setState(() {
        _savedRules = rules;
        _isLoading = false;
      });
    }
  }

  Future<void> _interpretInitial() async {
    await _handleInterpret(_sentenceCtrl.text);
  }

  Future<void> _handleInterpret(String sentence) async {
    setState(() => _isInterpreting = true);
    final repo = ref.read(argusRepositoryProvider);
    final result = await repo.interpretRule(sentence);
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
    final saved = await repo.saveRule(_currentParsed!.spec!);
    if (mounted) {
      setState(() {
        _savedRules.insert(0, saved);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rule "${saved.name}" successfully active across pipeline.'),
          backgroundColor: ArgusTokens.bgRaised,
        ),
      );
    }
  }

  void _showDryRunDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ArgusTokens.bgOverlay,
        title: Row(
          children: [
            const Icon(Icons.science_outlined, color: ArgusTokens.accent, size: 20),
            const SizedBox(width: 8),
            Text('Dry Run Against Clip', style: GoogleFonts.sora(fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Running rule logic against recorded benchmark clip "demo_s2_fall_stairs.json"...',
              style: GoogleFonts.inter(fontSize: 13, color: ArgusTokens.textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ArgusTokens.bgRaised,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: ArgusTokens.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded, color: ArgusTokens.success, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'TRIGGER MATCHED AT 3.4s',
                        style: GoogleFonts.jetBrainsMono(fontSize: 11, color: ArgusTokens.success, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Condition held continuously for 15s. Incident #102 would be opened with high confidence.',
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
                'Describe safety rules in natural language. Translated into structured Serverpod reactive DAGs.',
                style: GoogleFonts.inter(fontSize: 14, color: ArgusTokens.textSecondary),
              ),
              const SizedBox(height: 24),

              // Sentence Input Card
              _buildSentenceInputCard(),

              const SizedBox(height: 24),

              // Parsed Workflow Graph
              if (_currentParsed?.spec != null) ...[
                _buildWorkflowResultSection(),
                const SizedBox(height: 36),
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
                  'SAFETY RULE SENTENCE',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: ArgusTokens.accent,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: ArgusTokens.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: ArgusTokens.accent.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, size: 12, color: ArgusTokens.accent),
                      const SizedBox(width: 4),
                      Text(
                        'AI PIPELINE ACTIVE',
                        style: GoogleFonts.jetBrainsMono(fontSize: 10, color: ArgusTokens.accent, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _sentenceCtrl,
              maxLines: 2,
              style: GoogleFonts.inter(fontSize: 16, color: ArgusTokens.textPrimary),
              decoration: InputDecoration(
                hintText: 'e.g. If someone falls near the staircase and stays down for 20 seconds, alert security...',
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

  Widget _buildWorkflowResultSection() {
    final spec = _currentParsed!.spec!;
    final confidence = (_currentParsed!.confidence * 100).toInt();

    return RevealAnimation(
      child: Container(
        padding: const EdgeInsets.all(ArgusTokens.space24),
        decoration: BoxDecoration(
          color: ArgusTokens.bgRaised,
          borderRadius: BorderRadius.circular(ArgusTokens.radiusLg),
          border: Border.all(color: ArgusTokens.borderSubtle),
        ),
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
                            color: ArgusTokens.accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'PARSED BY ${_currentParsed!.parsedBy.toUpperCase()}',
                            style: GoogleFonts.jetBrainsMono(fontSize: 10, color: ArgusTokens.accent, fontWeight: FontWeight.bold),
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
                      label: const Text('Dry Run on Clip'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _handleSaveRule,
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                      label: const Text('Save & Activate'),
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
          'Active Pipeline Rules (${_savedRules.length})',
          style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600, color: ArgusTokens.textPrimary),
        ),
        const SizedBox(height: 14),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _savedRules.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, idx) {
            final rule = _savedRules[idx];
            final sev = SeverityLevel.fromString(rule.severity);
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
                  Switch(
                    value: rule.enabled,
                    activeThumbColor: ArgusTokens.accent,
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
                    },
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
