import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:argus_client/argus_client.dart';
import '../../app/theme/tokens.dart';
import '../../app/theme/severity_scale.dart';
import 'mouse_glow_tracker.dart';

class WorkflowGraphView extends StatefulWidget {
  final RuleSpec rule;
  final VoidCallback? onNodeTap;
  final String? zoneName;

  const WorkflowGraphView({
    super.key,
    required this.rule,
    this.onNodeTap,
    this.zoneName,
  });

  @override
  State<WorkflowGraphView> createState() => _WorkflowGraphViewState();
}

class _WorkflowGraphViewState extends State<WorkflowGraphView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant WorkflowGraphView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rule.id != oldWidget.rule.id ||
        widget.rule.sourceText != oldWidget.rule.sourceText ||
        widget.zoneName != oldWidget.zoneName ||
        widget.rule.trigger.zoneId != oldWidget.rule.trigger.zoneId) {
      _animController.reset();
      _animController.forward();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nodes = _buildNodes();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: ArgusTokens.space16, horizontal: ArgusTokens.space8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (int i = 0; i < nodes.length; i++) ...[
              _buildAnimatedNode(nodes[i], i, nodes.length),
              if (i < nodes.length - 1) _buildConnector(i, nodes.length),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedNode(_GraphNodeData node, int index, int total) {
    final startInterval = (index / total) * 0.6;
    final endInterval = (startInterval + 0.4).clamp(0.0, 1.0);

    final animation = CurvedAnimation(
      parent: _animController,
      curve: Interval(startInterval, endInterval, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(20 * (1 - animation.value), 0),
            child: Transform.scale(
              scale: 0.9 + 0.1 * animation.value,
              child: _NodeCard(node: node, onTap: widget.onNodeTap),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConnector(int index, int total) {
    return Container(
      width: 38,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: const BoxDecoration(
        color: ArgusTokens.borderStrong,
      ),
    );
  }

  List<_GraphNodeData> _buildNodes() {
    final r = widget.rule;
    final sev = SeverityLevel.fromString(r.severity);

    return [
      _GraphNodeData(
        step: '01',
        title: 'CAMERA',
        value: r.cameraIds.isEmpty ? 'All Cameras' : 'Cam #${r.cameraIds.join(", #")}',
        icon: Icons.videocam_outlined,
        color: ArgusTokens.accent,
      ),
      _GraphNodeData(
        step: '02',
        title: 'DETECT',
        value: r.trigger.signal.replaceAll('_', ' ').toUpperCase(),
        icon: Icons.radar_outlined,
        color: ArgusTokens.accent,
      ),
      _GraphNodeData(
        step: '03',
        title: 'ZONE',
        value: widget.zoneName != null
            ? widget.zoneName!
            : (r.trigger.zoneId != null ? 'Zone #${r.trigger.zoneId}' : 'Full Frame / All Zones'),
        icon: Icons.crop_square_outlined,
        color: ArgusTokens.zoneRestricted,
      ),
      _GraphNodeData(
        step: '04',
        title: 'CONDITION',
        value: r.trigger.minDurationSec > 0
            ? 'Dwell ≥ ${r.trigger.minDurationSec}s'
            : r.conditions.timeWindows.isNotEmpty
                ? '${r.conditions.timeWindows.first.start}–${r.conditions.timeWindows.first.end}'
                : 'Immediate',
        icon: Icons.schedule_outlined,
        color: ArgusTokens.severityMedium,
      ),
      _GraphNodeData(
        step: '05',
        title: 'VERIFY',
        value: r.verify.enabled ? 'Gemini (${r.verify.kind})' : 'On-device Only',
        icon: Icons.auto_awesome_outlined,
        color: r.verify.enabled ? ArgusTokens.accent : ArgusTokens.textTertiary,
      ),
      _GraphNodeData(
        step: '06',
        title: 'ACTIONS',
        value: '${r.actions.length} action(s) · ${sev.label}',
        icon: Icons.bolt_outlined,
        color: sev.color,
      ),
      if (r.escalation.isNotEmpty)
        _GraphNodeData(
          step: '07',
          title: 'ESCALATION',
          value: '${r.escalation.first.afterSec}s → ${r.escalation.first.notify}',
          icon: Icons.timer_outlined,
          color: ArgusTokens.severityCritical,
        ),
    ];
  }
}

class _GraphNodeData {
  final String step;
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _GraphNodeData({
    required this.step,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

class _NodeCard extends StatelessWidget {
  final _GraphNodeData node;
  final VoidCallback? onTap;

  const _NodeCard({required this.node, this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseGlowTracker(
      glowColor: node.color,
      radius: 120,
      opacity: 0.18,
      child: Container(
        width: 154,
        padding: const EdgeInsets.all(ArgusTokens.space12),
        decoration: BoxDecoration(
          color: ArgusTokens.bgRaised,
          borderRadius: BorderRadius.circular(ArgusTokens.radiusSm),
          border: Border.all(color: node.color.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  node.step,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    color: ArgusTokens.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(node.icon, size: 14, color: node.color),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              node.title,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: ArgusTokens.textSecondary,
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              node.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: ArgusTokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
