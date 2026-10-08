import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:crypto/crypto.dart';
import 'package:argus_client/argus_client.dart';
import '../../app/theme/tokens.dart';
import '../../core/copy/strings.dart';
import '../../data/repository_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  WorkspaceSettings _settings = WorkspaceSettings(
    cloudVerification: false,
    blurEvidence: true,
    retentionDays: 7,
    browserNotifications: true,
    telegramLinked: false,
    timezone: 'UTC',
  );
  List<AuditEntry> _auditEntries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repo = ref.read(argusRepositoryProvider);
    final ws = await repo.ensureWorkspace();
    final audit = await repo.listAudit(limit: 30);
    if (mounted) {
      setState(() {
        _settings = ws.settings;
        _auditEntries = audit;
        _isLoading = false;
      });
    }
  }

  Future<void> _updateSettings(WorkspaceSettings newSettings) async {
    final repo = ref.read(argusRepositoryProvider);
    final updated = await repo.updateSettings(newSettings);
    if (mounted) setState(() => _settings = updated);
  }

  void _exportAuditLog() {
    final buffer = StringBuffer();
    buffer.writeln('ARGUS CCTV SAFETY PLATFORM — AUDIT TRAIL LOG');
    buffer.writeln('Export Generated: ${DateTime.now().toUtc().toIso8601String()}');
    buffer.writeln('---------------------------------------------------------');
    for (final a in _auditEntries) {
      buffer.writeln('${a.at.toIso8601String()} | [${a.actor}] ${a.action} -> ${a.targetKind} #${a.targetId}: ${a.detail}');
    }
    final bytes = utf8.encode(buffer.toString());
    final digest = sha256.convert(bytes);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ArgusTokens.bgOverlay,
        title: Row(
          children: [
            const Icon(Icons.verified_user_rounded, color: ArgusTokens.accent, size: 20),
            const SizedBox(width: 8),
            Text('Audit Trail Compliance Export', style: GoogleFonts.sora(fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: 600,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cryptographic Chain-of-Custody Hash (SHA-256):', style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textTertiary)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: ArgusTokens.bgRaised,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: ArgusTokens.borderSubtle),
                ),
                child: SelectableText(
                  digest.toString(),
                  style: GoogleFonts.jetBrainsMono(fontSize: 12, color: ArgusTokens.accent, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              Text('Log Content (${_auditEntries.length} chronological actions):', style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textTertiary)),
              const SizedBox(height: 6),
              Container(
                height: 180,
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ArgusTokens.bgRaised,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: ArgusTokens.borderSubtle),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    buffer.toString(),
                    style: GoogleFonts.jetBrainsMono(fontSize: 11, color: ArgusTokens.textSecondary, height: 1.4),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  void _showDeleteDataDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ArgusTokens.bgOverlay,
        title: Text('Delete Workspace Data?', style: GoogleFonts.sora(fontSize: 16, color: ArgusTokens.severityCritical)),
        content: Text(
          'This will permanently delete all cameras, configured zones, rules, and incident evidence for this workspace.',
          style: GoogleFonts.inter(fontSize: 13, color: ArgusTokens.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ArgusTokens.severityCritical, foregroundColor: Colors.white),
            onPressed: () async {
              await ref.read(argusRepositoryProvider).deleteWorkspaceData();
              if (ctx.mounted) Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All workspace data permanently deleted.')),
                );
              }
            },
            child: const Text('Delete Permanently'),
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
          constraints: const BoxConstraints(maxWidth: 900),
          padding: const EdgeInsets.symmetric(horizontal: ArgusTokens.space24, vertical: ArgusTokens.space32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('System Settings & Privacy', style: GoogleFonts.sora(fontSize: 26, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text('Configure on-device blurring, cloud verification consent, and retention policies.', style: GoogleFonts.inter(fontSize: 14, color: ArgusTokens.textSecondary)),
              const SizedBox(height: 28),

              // Privacy Controls
              Container(
                padding: const EdgeInsets.all(ArgusTokens.space20),
                decoration: BoxDecoration(
                  color: ArgusTokens.bgRaised,
                  borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
                  border: Border.all(color: ArgusTokens.borderSubtle),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Privacy & Inference Consent', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 16),

                    SwitchListTile(
                      title: const Text('Blur Evidence Snapshots'),
                      subtitle: const Text('Automatically blur head/facial regions using pose landmarks before saving.'),
                      value: _settings.blurEvidence,
                      activeThumbColor: ArgusTokens.accent,
                      onChanged: (val) {
                        _updateSettings(WorkspaceSettings(
                          cloudVerification: _settings.cloudVerification,
                          blurEvidence: val,
                          retentionDays: _settings.retentionDays,
                          browserNotifications: _settings.browserNotifications,
                          telegramLinked: _settings.telegramLinked,
                          timezone: _settings.timezone,
                        ));
                      },
                    ),
                    const Divider(color: ArgusTokens.borderSubtle),

                    SwitchListTile(
                      title: const Text('Cloud Multimodal Verification (Gemini)'),
                      subtitle: Text(
                        ArgusStrings.cloudConsentNotice,
                        style: GoogleFonts.inter(color: ArgusTokens.textTertiary, fontSize: 12),
                      ),
                      value: _settings.cloudVerification,
                      activeThumbColor: ArgusTokens.accent,
                      onChanged: (val) {
                        _updateSettings(WorkspaceSettings(
                          cloudVerification: val,
                          blurEvidence: _settings.blurEvidence,
                          retentionDays: _settings.retentionDays,
                          browserNotifications: _settings.browserNotifications,
                          telegramLinked: _settings.telegramLinked,
                          timezone: _settings.timezone,
                        ));
                      },
                    ),
                    const Divider(color: ArgusTokens.borderSubtle),

                    ListTile(
                      title: const Text('Evidence Retention Period'),
                      subtitle: Text('${_settings.retentionDays} Days (Automatic Serverpod Hourly Retention Sweep)'),
                      trailing: DropdownButton<int>(
                        value: _settings.retentionDays,
                        dropdownColor: ArgusTokens.bgOverlay,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('1 Day')),
                          DropdownMenuItem(value: 3, child: Text('3 Days')),
                          DropdownMenuItem(value: 7, child: Text('7 Days (Default)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            _updateSettings(WorkspaceSettings(
                              cloudVerification: _settings.cloudVerification,
                              blurEvidence: _settings.blurEvidence,
                              retentionDays: val,
                              browserNotifications: _settings.browserNotifications,
                              telegramLinked: _settings.telegramLinked,
                              timezone: _settings.timezone,
                            ));
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Audit Trail & Compliance Section
              Container(
                padding: const EdgeInsets.all(ArgusTokens.space20),
                decoration: BoxDecoration(
                  color: ArgusTokens.bgRaised,
                  borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
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
                            Text('Audit Trail & Chain-of-Custody', style: GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text('Tamper-evident record of safety events, rule changes, and operator actions.', style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textTertiary)),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: _exportAuditLog,
                          icon: const Icon(Icons.download_rounded, size: 16),
                          label: const Text('Export Audit Log'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ArgusTokens.bgOverlay,
                            foregroundColor: ArgusTokens.accent,
                            side: const BorderSide(color: ArgusTokens.accent),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_auditEntries.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text('No audit events recorded in this session yet.', style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textTertiary)),
                      )
                    else
                      Container(
                        constraints: const BoxConstraints(maxHeight: 220),
                        decoration: BoxDecoration(
                          color: ArgusTokens.bgBase,
                          borderRadius: BorderRadius.circular(ArgusTokens.radiusSm),
                          border: Border.all(color: ArgusTokens.borderSubtle),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: _auditEntries.length,
                          separatorBuilder: (_, __) => const Divider(height: 1, color: ArgusTokens.borderSubtle),
                          itemBuilder: (ctx, i) {
                            final a = _auditEntries[i];
                            return ListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              leading: Text(
                                a.action,
                                style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.w600, color: ArgusTokens.accent),
                              ),
                              title: Text(
                                a.detail,
                                style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textPrimary),
                              ),
                              subtitle: Text(
                                'Actor: ${a.actor} • ${a.at.toLocal().toString().split('.').first}',
                                style: GoogleFonts.inter(fontSize: 10, color: ArgusTokens.textTertiary),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Danger Zone
              Container(
                padding: const EdgeInsets.all(ArgusTokens.space20),
                decoration: BoxDecoration(
                  color: ArgusTokens.bgRaised,
                  borderRadius: BorderRadius.circular(ArgusTokens.radiusMd),
                  border: Border.all(color: ArgusTokens.severityCritical.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: ArgusTokens.severityCritical, size: 24),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Delete All Workspace Data', style: GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: ArgusTokens.severityCritical)),
                          Text('Wipe all cameras, zones, rules, and stored incident evidence.', style: GoogleFonts.inter(fontSize: 12, color: ArgusTokens.textTertiary)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: ArgusTokens.severityCritical, foregroundColor: Colors.white),
                      onPressed: _showDeleteDataDialog,
                      child: const Text('Delete All Data'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
