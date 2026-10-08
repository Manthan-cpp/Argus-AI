import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/tokens.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArgusTokens.bgBase,
      body: Center(
        child: Container(
          width: 440,
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
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: ArgusTokens.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.remove_red_eye_rounded, size: 18, color: ArgusTokens.accent),
                  ),
                  const SizedBox(width: 10),
                  Text('Argus Access', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Argus operates with zero-friction anonymous guest sessions by default. No password or email required to explore the demo.',
                style: GoogleFonts.inter(fontSize: 13, color: ArgusTokens.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/app/monitor'),
                icon: const Icon(Icons.login_rounded, size: 16),
                label: const Text('Continue as Anonymous Guest'),
                style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
