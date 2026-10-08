import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/copy/strings.dart';
import '../../core/widgets/pulsing_beacon.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/repository_provider.dart';
import '../theme/tokens.dart';
import 'command_palette.dart';

class ControlRoomScaffold extends ConsumerStatefulWidget {
  final Widget child;
  final String currentRoute;

  const ControlRoomScaffold({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  ConsumerState<ControlRoomScaffold> createState() => _ControlRoomScaffoldState();
}

class _ControlRoomScaffoldState extends ConsumerState<ControlRoomScaffold> {
  final FocusNode _keyboardFocusNode = FocusNode();

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent) {
      final isControlOrCmd = HardwareKeyboard.instance.isMetaPressed ||
          HardwareKeyboard.instance.isControlPressed;
      if (isControlOrCmd && event.logicalKey == LogicalKeyboardKey.keyK) {
        CommandPalette.show(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;
    final isMobile = width < 768;
    final isMock = ref.watch(isMockModeProvider);

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKey,
      child: Scaffold(
        backgroundColor: ArgusTokens.bgBase,
        body: Column(
          children: [
            // Top Control Bar
            _buildTopBar(isDesktop, isMock),

            // Main View Area (Rail + Content)
            Expanded(
              child: Row(
                children: [
                  if (!isMobile) _buildNavigationRail(),
                  Expanded(
                    child: Container(
                      color: ArgusTokens.bgBase,
                      child: widget.child,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: isMobile ? _buildBottomNav() : null,
      ),
    );
  }

  Widget _buildTopBar(bool isDesktop, bool isMock) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: ArgusTokens.space16),
      decoration: const BoxDecoration(
        color: ArgusTokens.bgRaised,
        border: Border(bottom: BorderSide(color: ArgusTokens.borderSubtle)),
      ),
      child: Row(
        children: [
          // Brand Logo
          InkWell(
            onTap: () => context.go('/'),
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: ArgusTokens.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: ArgusTokens.accent.withValues(alpha: 0.4)),
                  ),
                  child: const Center(
                    child: Icon(Icons.remove_red_eye_rounded, size: 16, color: ArgusTokens.accent),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  ArgusStrings.appName,
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: ArgusTokens.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          const VerticalDivider(width: 1, indent: 14, endIndent: 14, color: ArgusTokens.borderSubtle),
          const SizedBox(width: 16),

          // Realtime Serverpod Connection Status
          Row(
            children: [
              const PulsingBeacon(color: ArgusTokens.success, size: 8),
              const SizedBox(width: 8),
              Text(
                'STREAMING',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: ArgusTokens.success,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),

          const Spacer(),

          // Mock Data Banner / Badge
          if (isMock) ...[
            StatusBadge.mock(),
            const SizedBox(width: 12),
          ],

          // Command Palette Trigger
          if (isDesktop) ...[
            InkWell(
              onTap: () => CommandPalette.show(context),
              borderRadius: BorderRadius.circular(ArgusTokens.radiusSm),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: ArgusTokens.bgOverlay,
                  borderRadius: BorderRadius.circular(ArgusTokens.radiusSm),
                  border: Border.all(color: ArgusTokens.borderSubtle),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search_rounded, size: 14, color: ArgusTokens.textTertiary),
                    const SizedBox(width: 6),
                    Text(
                      'Search / Jump',
                      style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textTertiary),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: ArgusTokens.bgRaised,
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: ArgusTokens.borderSubtle),
                      ),
                      child: Text(
                        '⌘K',
                        style: GoogleFonts.jetBrainsMono(fontSize: 10, color: ArgusTokens.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Quick Action / Help Link
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, size: 18, color: ArgusTokens.textSecondary),
            tooltip: 'Methodology & Honest Limits',
            onPressed: () => context.go('/about'),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRail() {
    final navItems = [
      _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home', route: '/'),
      _NavItem(icon: Icons.radar_outlined, activeIcon: Icons.radar_rounded, label: 'Monitor', route: '/app/monitor'),
      _NavItem(icon: Icons.videocam_outlined, activeIcon: Icons.videocam_rounded, label: 'Cameras', route: '/app/cameras'),
      _NavItem(icon: Icons.rule_outlined, activeIcon: Icons.rule_rounded, label: 'Rules', route: '/app/rules'),
      _NavItem(icon: Icons.shield_outlined, activeIcon: Icons.shield_rounded, label: 'Incidents', route: '/app/incidents'),
      _NavItem(icon: Icons.trending_up_outlined, activeIcon: Icons.trending_up_rounded, label: 'Escalation', route: '/app/escalation'),
      _NavItem(icon: Icons.science_outlined, activeIcon: Icons.science_rounded, label: 'Lab', route: '/app/lab'),
      _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings_rounded, label: 'Settings', route: '/app/settings'),
      _NavItem(icon: Icons.info_outline_rounded, activeIcon: Icons.info_rounded, label: 'About', route: '/about'),
    ];

    return Container(
      width: 72,
      decoration: const BoxDecoration(
        color: ArgusTokens.bgRaised,
        border: Border(right: BorderSide(color: ArgusTokens.borderSubtle)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          for (final item in navItems) ...[
            _buildRailItem(item),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }

  Widget _buildRailItem(_NavItem item) {
    final isActive = widget.currentRoute == item.route ||
        (item.route != '/' && widget.currentRoute.startsWith(item.route));

    return Tooltip(
      message: item.label,
      waitDuration: const Duration(milliseconds: 300),
      child: InkWell(
        onTap: () => context.go(item.route),
        borderRadius: BorderRadius.circular(ArgusTokens.radiusSm),
        child: Container(
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? ArgusTokens.accent.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(ArgusTokens.radiusSm),
            border: isActive ? Border.all(color: ArgusTokens.accent.withValues(alpha: 0.4)) : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? item.activeIcon : item.icon,
                size: 20,
                color: isActive ? ArgusTokens.accent : ArgusTokens.textTertiary,
              ),
              const SizedBox(height: 3),
              Text(
                item.label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? ArgusTokens.accent : ArgusTokens.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final current = widget.currentRoute;
    int currentIndex = 0;
    if (current.startsWith('/app/monitor')) currentIndex = 1;
    if (current.startsWith('/app/rules')) currentIndex = 2;
    if (current.startsWith('/app/incidents')) currentIndex = 3;

    return Container(
      decoration: const BoxDecoration(
        color: ArgusTokens.bgRaised,
        border: Border(top: BorderSide(color: ArgusTokens.borderSubtle)),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: ArgusTokens.accent,
        unselectedItemColor: ArgusTokens.textTertiary,
        type: BottomNavigationBarType.fixed,
        onTap: (idx) {
          switch (idx) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/app/monitor');
              break;
            case 2:
              context.go('/app/rules');
              break;
            case 3:
              context.go('/app/incidents');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.radar_outlined), activeIcon: Icon(Icons.radar_rounded), label: 'Monitor'),
          BottomNavigationBarItem(icon: Icon(Icons.rule_outlined), activeIcon: Icon(Icons.rule_rounded), label: 'Rules'),
          BottomNavigationBarItem(icon: Icon(Icons.shield_outlined), activeIcon: Icon(Icons.shield_rounded), label: 'Incidents'),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });
}
