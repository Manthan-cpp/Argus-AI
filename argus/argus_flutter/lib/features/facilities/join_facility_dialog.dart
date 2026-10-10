import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:argus_client/argus_client.dart';
import '../../app/theme/tokens.dart';
import '../../data/repository_provider.dart';
import 'facility_providers.dart';

class JoinFacilityDialog extends ConsumerStatefulWidget {
  final UserProfile currentUser;

  const JoinFacilityDialog({super.key, required this.currentUser});

  static Future<void> show(BuildContext context, UserProfile currentUser) {
    return showDialog(
      context: context,
      builder: (_) => JoinFacilityDialog(currentUser: currentUser),
    );
  }

  @override
  ConsumerState<JoinFacilityDialog> createState() => _JoinFacilityDialogState();
}

class _JoinFacilityDialogState extends ConsumerState<JoinFacilityDialog> {
  final _codeCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _joinFacility() async {
    final rawCode = _codeCtrl.text.trim();
    if (rawCode.isEmpty) return;
    final cleanCode = rawCode.toUpperCase();

    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(argusRepositoryProvider);
      final facility = await repo.joinFacility(
        cleanCode,
        userName: widget.currentUser.fullName,
      );

      if (facility == null) {
        if (mounted) {
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid code "$cleanCode" or facility not found.')),
          );
        }
        return;
      }

      ref.invalidate(userFacilitiesProvider);
      ref.read(activeFacilityProvider.notifier).state = facility;

      if (mounted) {
        Navigator.pop(context);
        context.go('/app/monitor');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join facility: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ArgusTokens.bgOverlay,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ArgusTokens.radiusLg),
        side: const BorderSide(color: ArgusTokens.borderSubtle),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: ArgusTokens.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.vpn_key_rounded, color: ArgusTokens.accent, size: 20),
          ),
          const SizedBox(width: 10),
          Text('Join Facility with Code', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter the invite code from your facility organizer. The code securely determines whether you join as an Organizer, Supervisor, or Guard.',
              style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 16),
            Text('Facility Access Code', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _codeCtrl,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              style: GoogleFonts.jetBrainsMono(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.2),
              decoration: InputDecoration(
                hintText: 'e.g. GRD-9214, SUP-5801, ORG-3042',
                hintStyle: GoogleFonts.jetBrainsMono(color: ArgusTokens.textTertiary, fontSize: 13),
                filled: true,
                fillColor: ArgusTokens.bgRaised,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onSubmitted: (_) => _joinFacility(),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ArgusTokens.bgRaised,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: ArgusTokens.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 14, color: ArgusTokens.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Joining as "${widget.currentUser.fullName}". Permissions are locked to this code.',
                      style: GoogleFonts.inter(fontSize: 11, color: ArgusTokens.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _joinFacility,
          style: ElevatedButton.styleFrom(
            backgroundColor: ArgusTokens.accent,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          ),
          child: _isSubmitting
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
              : const Text('Join Facility'),
        ),
      ],
    );
  }
}
