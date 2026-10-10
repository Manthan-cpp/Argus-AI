import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme/tokens.dart';

/// Reusable barrier shown when a user tries to access a protected screen while unauthenticated.
class AuthRequiredBarrier extends StatelessWidget {
  final String title;
  final String description;

  const AuthRequiredBarrier({
    super.key,
    this.title = 'Authentication Required',
    this.description =
        'Operations dispatch rooms are private, sovereign communication channels. You must sign in or create an account to view your rooms, create a room, or join with an invite code.',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(ArgusTokens.space24),
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
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: ArgusTokens.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: ArgusTokens.accent.withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.lock_outline_rounded, size: 36, color: ArgusTokens.accent),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: GoogleFonts.sora(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: ArgusTokens.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                description,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: ArgusTokens.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/auth'),
                icon: const Icon(Icons.login_rounded, size: 16),
                label: const Text('Sign In or Create Account'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ArgusTokens.accent,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(44),
                  textStyle: GoogleFonts.inter(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
