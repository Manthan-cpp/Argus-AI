import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/tokens.dart';
import '../rooms/room_providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final TextEditingController _nameCtrl = TextEditingController(text: 'Chief Operations Officer');
  String _selectedRole = 'organizer';

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user != null) {
      _nameCtrl.text = user.fullName;
      _selectedRole = user.role;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit(String name, String role) async {
    await ref.read(currentUserProvider.notifier).login(name, role);
    if (mounted) {
      context.go('/app/rooms');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArgusTokens.bgBase,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(ArgusTokens.space24),
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(ArgusTokens.space32),
            decoration: BoxDecoration(
              color: ArgusTokens.bgRaised,
              borderRadius: BorderRadius.circular(ArgusTokens.radiusLg),
              border: Border.all(color: ArgusTokens.borderSubtle),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: ArgusTokens.accent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: ArgusTokens.accent.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.security_rounded, size: 20, color: ArgusTokens.accent),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Argus Sovereign Access',
                            style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700)),
                        Text('Role-Based Identity & Operations Dispatch',
                            style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textSecondary)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Select your operational tier to join war rooms, manage live camera polygons, or coordinate emergency guard dispatches.',
                  style: GoogleFonts.inter(fontSize: 13, color: ArgusTokens.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 20),

                // Name input
                Text('Operator Full Name', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                TextField(
                  controller: _nameCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. Officer Marcus',
                    filled: true,
                    fillColor: ArgusTokens.bgOverlay,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 18),

                // 3 Role Cards
                Text('Operational Role', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),

                _buildRoleOption(
                  roleKey: 'organizer',
                  title: 'Organizer (Full Authority)',
                  desc: 'Creates rooms, provisions cameras, selects restricted zones, configures rules & issues invite codes.',
                  icon: Icons.admin_panel_settings_rounded,
                  color: Colors.amberAccent,
                ),
                const SizedBox(height: 8),

                _buildRoleOption(
                  roleKey: 'supervisor',
                  title: 'Supervisor (Command & Control)',
                  desc: 'Monitors vision telemetry, acknowledges/resolves alerts, and directs responder units in real time.',
                  icon: Icons.security_rounded,
                  color: Colors.cyanAccent,
                ),
                const SizedBox(height: 8),

                _buildRoleOption(
                  roleKey: 'member',
                  title: 'Member / Guard (Tactical Field)',
                  desc: 'Joins via room invite code, receives live automated alert cards, and reports ground status.',
                  icon: Icons.shield_rounded,
                  color: ArgusTokens.success,
                ),
                const SizedBox(height: 24),

                // Continue Button
                ElevatedButton.icon(
                  onPressed: () => _submit(_nameCtrl.text.trim(), _selectedRole),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text('Enter Argus Command'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ArgusTokens.accent,
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(48),
                    textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
                  ),
                ),

                const SizedBox(height: 18),
                const Divider(color: ArgusTokens.borderSubtle),
                const SizedBox(height: 12),

                // Quick presets
                Text('Or Quick Switch Demo Identity:',
                    style: GoogleFonts.inter(fontSize: 11, color: ArgusTokens.textTertiary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.admin_panel_settings_rounded, size: 14, color: Colors.amberAccent),
                      label: const Text('Admin Organizer'),
                      onPressed: () => _submit('Chief Operations Officer', 'organizer'),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.security_rounded, size: 14, color: Colors.cyanAccent),
                      label: const Text('Shift Supervisor'),
                      onPressed: () => _submit('Officer Sarah Jenkins', 'supervisor'),
                    ),
                    ActionChip(
                      avatar: const Icon(Icons.shield_rounded, size: 14, color: ArgusTokens.success),
                      label: const Text('Tactical Guard'),
                      onPressed: () => _submit('Marcus Vance', 'member'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleOption({
    required String roleKey,
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedRole == roleKey;

    return InkWell(
      onTap: () => setState(() => _selectedRole = roleKey),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.12) : ArgusTokens.bgOverlay,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : ArgusTokens.borderSubtle,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? ArgusTokens.textPrimary : ArgusTokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: ArgusTokens.textTertiary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}
