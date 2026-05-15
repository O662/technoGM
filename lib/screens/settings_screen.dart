import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_card.dart';
import 'units_preferences_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final profile = provider.data.profile;

    return Scaffold(
      appBar: AppBar(title: const Text('SETTINGS')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Preferences ──────────────────────────────────────────────────────
          _SectionHeader(label: 'PREFERENCES'),
          const SizedBox(height: 8),
          NeonCard(
            padding: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.straighten, color: TechnoColors.textMuted),
              title: Text(
                'Units',
                style: GoogleFonts.rajdhani(color: TechnoColors.textPrimary, fontSize: 15),
              ),
              subtitle: Text(
                () {
                  if (profile.preferKg && profile.preferCm) return 'Metric — cm, kg';
                  if (!profile.preferKg && !profile.preferCm) return 'Imperial — ft & in, lbs';
                  return 'Custom';
                }(),
                style: GoogleFonts.rajdhani(color: TechnoColors.textMuted, fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right, color: TechnoColors.textMuted),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UnitsPreferencesScreen()),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Your Data ────────────────────────────────────────────────────────
          _SectionHeader(label: 'YOUR DATA'),
          const SizedBox(height: 8),
          NeonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your data is stored only on this device — no accounts, no tracking. Export to Google Drive, OneDrive, or any other cloud service to back it up.',
                  style: GoogleFonts.rajdhani(
                    color: TechnoColors.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                NeonButton(
                  label: 'EXPORT DATA',
                  icon: Icons.upload,
                  color: TechnoColors.neonCyan,
                  onTap: () => _export(context, provider),
                ),
                const SizedBox(height: 10),
                NeonButton(
                  label: 'IMPORT DATA',
                  icon: Icons.download,
                  color: TechnoColors.neonPurple,
                  outlined: true,
                  onTap: () => _import(context, provider),
                ),
                if (provider.data.lastExported != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Last exported: ${_fmt(provider.data.lastExported!)}',
                    style: GoogleFonts.rajdhani(
                      color: TechnoColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Danger Zone ──────────────────────────────────────────────────────
          NeonCard(
            borderColor: TechnoColors.neonPink.withValues(alpha: 0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.warning, color: TechnoColors.neonPink, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'DANGER ZONE',
                      style: GoogleFonts.orbitron(
                        color: TechnoColors.neonPink,
                        fontSize: 11,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                NeonButton(
                  label: 'CLEAR ALL DATA',
                  icon: Icons.delete_forever,
                  color: TechnoColors.neonPink,
                  outlined: true,
                  onTap: () => _clearAll(context, provider),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, AppProvider provider) async {
    final success = await provider.exportData();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Data ready to share!' : 'Export failed'),
        backgroundColor: success
            ? TechnoColors.neonGreen.withValues(alpha: 0.2)
            : TechnoColors.neonPink.withValues(alpha: 0.2),
      ));
    }
  }

  Future<void> _import(BuildContext context, AppProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'IMPORT DATA?',
          style: GoogleFonts.orbitron(color: TechnoColors.neonPurple, fontSize: 14),
        ),
        content: Text(
          'This will replace your current data with the imported file.',
          style: GoogleFonts.rajdhani(color: TechnoColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('IMPORT', style: TextStyle(color: TechnoColors.neonPurple)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final success = await provider.importData();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(success ? 'Data imported successfully!' : 'Import failed — invalid file'),
      ));
    }
  }

  Future<void> _clearAll(BuildContext context, AppProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'CLEAR ALL DATA?',
          style: GoogleFonts.orbitron(color: TechnoColors.neonPink, fontSize: 14),
        ),
        content: Text(
          'This will permanently delete ALL your workouts, weight history, and records. This cannot be undone.',
          style: GoogleFonts.rajdhani(color: TechnoColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('DELETE EVERYTHING', style: TextStyle(color: TechnoColors.neonPink)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.clearAllData();
    }
  }

  String _fmt(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) => Text(
        label,
        style: GoogleFonts.orbitron(
          color: TechnoColors.textSecondary,
          fontSize: 11,
          letterSpacing: 2,
        ),
      );
}
