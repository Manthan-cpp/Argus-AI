import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../theme/tokens.dart';

class CommandPalette extends StatefulWidget {
  const CommandPalette({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (_) => const CommandPalette(),
    );
  }

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final TextEditingController _queryCtrl = TextEditingController();
  String _query = '';

  final List<_CommandItem> _allCommands = [
    _CommandItem(
      title: 'Go to Live Monitor',
      subtitle: 'View real-time camera streams & signal telemetry',
      icon: Icons.radar_rounded,
      route: '/app/monitor',
      shortcut: 'G M',
    ),
    _CommandItem(
      title: 'Go to Rule Studio',
      subtitle: 'Compose safety rules in plain English',
      icon: Icons.rule_rounded,
      route: '/app/rules',
      shortcut: 'G R',
    ),
    _CommandItem(
      title: 'View Incidents',
      subtitle: 'Audit and acknowledge active safety events',
      icon: Icons.shield_outlined,
      route: '/app/incidents',
      shortcut: 'G I',
    ),
    _CommandItem(
      title: 'Camera Directory & Zones',
      subtitle: 'Configure camera feeds and draw detection polygons',
      icon: Icons.videocam_outlined,
      route: '/app/cameras',
      shortcut: 'G C',
    ),
    _CommandItem(
      title: 'Escalation Policies',
      subtitle: 'Configure automated notification timeouts and contacts',
      icon: Icons.trending_up_rounded,
      route: '/app/escalation',
    ),
    _CommandItem(
      title: 'Detector Lab',
      subtitle: 'Review precision, recall, and benchmark statistics',
      icon: Icons.science_outlined,
      route: '/app/lab',
    ),
    _CommandItem(
      title: 'System Settings & Privacy',
      subtitle: 'Manage retention, blur filters, and Gemini consent',
      icon: Icons.settings_outlined,
      route: '/app/settings',
    ),
    _CommandItem(
      title: 'About & Methodology',
      subtitle: 'Assistive alerting specifications and WHO statistics',
      icon: Icons.info_outline_rounded,
      route: '/about',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _allCommands.where((c) {
      if (_query.isEmpty) return true;
      return c.title.toLowerCase().contains(_query.toLowerCase()) ||
          c.subtitle.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 580,
          margin: const EdgeInsets.all(ArgusTokens.space24),
          decoration: BoxDecoration(
            color: ArgusTokens.bgOverlay,
            borderRadius: BorderRadius.circular(ArgusTokens.radiusLg),
            border: Border.all(color: ArgusTokens.borderStrong, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 32,
                spreadRadius: 8,
              ),
              BoxShadow(
                color: ArgusTokens.accent.withValues(alpha: 0.15),
                blurRadius: 24,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Search Header
              Padding(
                padding: const EdgeInsets.all(ArgusTokens.space16),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, color: ArgusTokens.accent, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _queryCtrl,
                        autofocus: true,
                        style: GoogleFonts.inter(color: ArgusTokens.textPrimary, fontSize: 15),
                        decoration: const InputDecoration(
                          hintText: 'Type a command or jump to screen...',
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          filled: false,
                        ),
                        onChanged: (val) => setState(() => _query = val),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: ArgusTokens.bgRaised,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: ArgusTokens.borderSubtle),
                      ),
                      child: Text(
                        'ESC',
                        style: GoogleFonts.jetBrainsMono(fontSize: 10, color: ArgusTokens.textTertiary),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: ArgusTokens.borderSubtle),

              // Command List
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 340),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemBuilder: (context, idx) {
                    final item = filtered[idx];
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                        context.go(item.route);
                      },
                      hoverColor: ArgusTokens.accent.withValues(alpha: 0.08),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: ArgusTokens.bgRaised,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: ArgusTokens.borderSubtle),
                              ),
                              child: Icon(item.icon, size: 16, color: ArgusTokens.accent),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: ArgusTokens.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    item.subtitle,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: ArgusTokens.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (item.shortcut != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                decoration: BoxDecoration(
                                  color: ArgusTokens.bgRaised,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: ArgusTokens.borderSubtle),
                                ),
                                child: Text(
                                  item.shortcut!,
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 11,
                                    color: ArgusTokens.textSecondary,
                                  ),
                                ),
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
    );
  }
}

class _CommandItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;
  final String? shortcut;

  _CommandItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
    this.shortcut,
  });
}
