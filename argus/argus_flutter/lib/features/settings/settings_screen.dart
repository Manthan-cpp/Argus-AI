import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final repo = ref.read(argusRepositoryProvider);
    final ws = await repo.ensureWorkspace();
    if (mounted) setState(() { _settings = ws.settings; _isLoading = false; });
  }

  Future<void> _updateSettings(WorkspaceSettings newSettings) async {
    final repo = ref.read(argusRepositoryProvider);
    final updated = await repo.updateSettings(newSettings);
    if (mounted) setState(() => _settings = updated);
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
