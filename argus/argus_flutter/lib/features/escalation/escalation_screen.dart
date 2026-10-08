import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:argus_client/argus_client.dart';
import '../../app/theme/tokens.dart';
import '../../core/widgets/rainbow_moving_border.dart';
import '../../core/widgets/reveal_animation.dart';
import '../../data/repository_provider.dart';

class EscalationScreen extends ConsumerStatefulWidget {
  const EscalationScreen({super.key});

  @override
  ConsumerState<EscalationScreen> createState() => _EscalationScreenState();
}

class _EscalationScreenState extends ConsumerState<EscalationScreen> {
  List<Contact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final repo = ref.read(argusRepositoryProvider);
    final c = await repo.listContacts();
    if (mounted) setState(() { _contacts = c; _isLoading = false; });
  }

  void _showAddContactDialog() {
    final nameCtrl = TextEditingController();
    final roleCtrl = TextEditingController(text: 'Safety Officer');
    final tgCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ArgusTokens.bgOverlay,
        title: Text('Add Escalation Contact', style: GoogleFonts.sora(fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name', hintText: 'Jane Doe')),
            const SizedBox(height: 12),
            TextField(controller: roleCtrl, decoration: const InputDecoration(labelText: 'Role', hintText: 'Supervisor')),
            const SizedBox(height: 12),
            TextField(controller: tgCtrl, decoration: const InputDecoration(labelText: 'Telegram Handle', hintText: '@safety_bot')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              final repo = ref.read(argusRepositoryProvider);
              await repo.saveContact(Contact(
                workspaceId: 1,
                name: nameCtrl.text,
                role: roleCtrl.text,
                telegramChatId: tgCtrl.text.isNotEmpty ? tgCtrl.text : null,
                notifyInApp: true,
              ));
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) _loadContacts();
            },
            child: const Text('Save Contact'),
          ),
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
          constraints: const BoxConstraints(maxWidth: 1100),
          padding: const EdgeInsets.symmetric(horizontal: ArgusTokens.space24, vertical: ArgusTokens.space32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text('Escalation & Notification Policies', style: GoogleFonts.sora(fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Serverpod Future Calls trigger automated alerts if an incident remains unacknowledged.', style: GoogleFonts.inter(fontSize: 14, color: ArgusTokens.textSecondary)),
              const SizedBox(height: 28),

              // Telegram Integration Card
              RevealAnimation(
                child: RainbowMovingBorder(
                  padding: const EdgeInsets.all(ArgusTokens.space20),
                  borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
                  borderWidth: 1.4,
                  baseBorderColor: Colors.white,
                  backgroundColor: ArgusTokens.bgRaised,
                  isLive: true,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFF229ED9).withValues(alpha: 0.15), shape: BoxShape.circle),
                        child: const Icon(Icons.send_rounded, color: Color(0xFF229ED9), size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Telegram Emergency Bot', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('Link supervisors to receive instant high-severity incident alerts and verification links.', style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textSecondary)),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Telegram link code: ARGUS-7829-TG')),
                          );
                        },
                        child: const Text('Generate Link Code'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Contacts Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Contact Directory (${_contacts.length})', style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w600)),
                  ElevatedButton.icon(
                    onPressed: _showAddContactDialog,
                    icon: const Icon(Icons.person_add_rounded, size: 16),
                    label: const Text('Add Contact'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _contacts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, idx) {
                  final c = _contacts[idx];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: ArgusTokens.bgRaised,
                      borderRadius: BorderRadius.circular(ArgusTokens.radiusSm),
                      border: Border.all(color: ArgusTokens.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: ArgusTokens.accent.withValues(alpha: 0.15),
                          child: Text(c.name.substring(0, 1), style: const TextStyle(color: ArgusTokens.accent, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600)),
                              Text('${c.role} · ${c.telegramChatId ?? "No Telegram linked"}', style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textTertiary)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: ArgusTokens.textTertiary, size: 18),
                          onPressed: () async {
                            await ref.read(argusRepositoryProvider).deleteContact(c.id!);
                            _loadContacts();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
