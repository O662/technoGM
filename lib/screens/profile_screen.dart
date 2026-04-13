import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _showWeightForm = false;
  final _weightCtrl = TextEditingController();
  final _weightNoteCtrl = TextEditingController();
  @override
  void dispose() {
    _weightCtrl.dispose();
    _weightNoteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final profile = provider.data.profile;
    final latestWeight = provider.latestWeight;

    return Scaffold(
      appBar: AppBar(title: const Text('PROFILE')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── User Info ──────────────────────────────────────────────────────
          _SectionHeader(label: 'USER'),
          const SizedBox(height: 8),
          NeonCard(
            child: Column(
              children: [
                _EditTile(
                  label: 'Name',
                  value: profile.name.isEmpty ? 'Tap to set' : profile.name,
                  icon: Icons.person_outline,
                  onEdit: () => _editName(context, provider, profile),
                ),
                const Divider(height: 1),
                _EditTile(
                  label: 'Height',
                  value: '${profile.heightCm.round()} cm',
                  icon: Icons.height,
                  onEdit: () => _editHeight(context, provider, profile),
                ),
                const Divider(height: 1),
                _FitnessLevelTile(
                  level: profile.fitnessLevel,
                  onChanged: (l) {
                    final updated = UserProfile(
                      name: profile.name,
                      heightCm: profile.heightCm,
                      injuries: profile.injuries,
                      fitnessLevel: l,
                      focusAreas: profile.focusAreas,
                      preferKg: profile.preferKg,
                      preferGym: profile.preferGym,
                    );
                    provider.updateProfile(updated);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Preferences ────────────────────────────────────────────────────
          _SectionHeader(label: 'PREFERENCES'),
          const SizedBox(height: 8),
          NeonCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(
                    'Weight units',
                    style: GoogleFonts.rajdhani(color: TechnoColors.textPrimary, fontSize: 15),
                  ),
                  subtitle: Text(
                    profile.preferKg ? 'Kilograms (kg)' : 'Pounds (lbs)',
                    style: GoogleFonts.rajdhani(color: TechnoColors.textMuted, fontSize: 12),
                  ),
                  value: profile.preferKg,
                  secondary: const Icon(Icons.scale, color: TechnoColors.textMuted),
                  onChanged: (v) {
                    provider.updateProfile(UserProfile(
                      name: profile.name,
                      heightCm: profile.heightCm,
                      injuries: profile.injuries,
                      fitnessLevel: profile.fitnessLevel,
                      focusAreas: profile.focusAreas,
                      preferKg: v,
                      preferGym: profile.preferGym,
                    ));
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: Text(
                    'Default location',
                    style: GoogleFonts.rajdhani(color: TechnoColors.textPrimary, fontSize: 15),
                  ),
                  subtitle: Text(
                    profile.preferGym ? 'Gym' : 'Home',
                    style: GoogleFonts.rajdhani(color: TechnoColors.textMuted, fontSize: 12),
                  ),
                  value: profile.preferGym,
                  secondary: const Icon(Icons.location_on_outlined, color: TechnoColors.textMuted),
                  onChanged: (v) {
                    provider.updateProfile(UserProfile(
                      name: profile.name,
                      heightCm: profile.heightCm,
                      injuries: profile.injuries,
                      fitnessLevel: profile.fitnessLevel,
                      focusAreas: profile.focusAreas,
                      preferKg: profile.preferKg,
                      preferGym: v,
                    ));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Injuries ───────────────────────────────────────────────────────
          _SectionHeader(label: 'INJURIES / LIMITATIONS'),
          const SizedBox(height: 8),
          NeonCard(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: InjuryArea.values.map((injury) {
                  final active = profile.injuries.contains(injury);
                  return GestureDetector(
                    onTap: () {
                      final injuries = List<InjuryArea>.from(profile.injuries);
                      active ? injuries.remove(injury) : injuries.add(injury);
                      provider.updateProfile(UserProfile(
                        name: profile.name,
                        heightCm: profile.heightCm,
                        injuries: injuries,
                        fitnessLevel: profile.fitnessLevel,
                        focusAreas: profile.focusAreas,
                        preferKg: profile.preferKg,
                        preferGym: profile.preferGym,
                      ));
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: active ? TechnoColors.neonPink.withValues(alpha: 0.12) : TechnoColors.bgTertiary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active ? TechnoColors.neonPink : TechnoColors.cardBorder,
                        ),
                      ),
                      child: Text(
                        injury.label,
                        style: GoogleFonts.rajdhani(
                          color: active ? TechnoColors.neonPink : TechnoColors.textSecondary,
                          fontSize: 13,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Body Weight ────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(child: _SectionHeader(label: 'BODY WEIGHT')),
              GestureDetector(
                onTap: () => setState(() => _showWeightForm = !_showWeightForm),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: TechnoColors.neonGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: TechnoColors.neonGreen.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, color: TechnoColors.neonGreen, size: 14),
                      Text(
                        'LOG',
                        style: GoogleFonts.orbitron(
                          color: TechnoColors.neonGreen,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_showWeightForm) ...[
            NeonCard(
              borderColor: TechnoColors.neonGreen.withValues(alpha: 0.5),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _weightCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'Weight (${profile.preferKg ? "kg" : "lbs"})',
                            suffixText: profile.preferKg ? 'kg' : 'lbs',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _weightNoteCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'e.g., Morning, fasted',
                    ),
                  ),
                  const SizedBox(height: 12),
                  NeonButton(
                    label: 'SAVE WEIGHT',
                    color: TechnoColors.neonGreen,
                    onTap: () async {
                      final raw = double.tryParse(_weightCtrl.text);
                      if (raw == null) return;
                      final kg = profile.preferKg ? raw : raw / 2.20462;
                      await provider.addWeightEntry(kg, notes: _weightNoteCtrl.text);
                      _weightCtrl.clear();
                      _weightNoteCtrl.clear();
                      setState(() => _showWeightForm = false);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          if (latestWeight != null)
            NeonCard(
              child: Row(
                children: [
                  const Icon(Icons.monitor_weight_outlined, color: TechnoColors.neonGreen),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CURRENT WEIGHT',
                        style: GoogleFonts.orbitron(
                          color: TechnoColors.textMuted,
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        profile.preferKg
                            ? '${latestWeight.toStringAsFixed(1)} kg'
                            : '${(latestWeight * 2.20462).toStringAsFixed(1)} lbs',
                        style: GoogleFonts.orbitron(
                          color: TechnoColors.neonGreen,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),

          // ── Streak Settings ────────────────────────────────────────────────
          _SectionHeader(label: 'WEEKLY GOAL'),
          const SizedBox(height: 8),
          _StreakSettings(provider: provider),
          const SizedBox(height: 20),

          // ── Data Export / Import ───────────────────────────────────────────
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

          // ── Danger Zone ────────────────────────────────────────────────────
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
        backgroundColor: success ? TechnoColors.neonGreen.withValues(alpha: 0.2) : TechnoColors.neonPink.withValues(alpha: 0.2),
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

  void _editName(BuildContext context, AppProvider provider, UserProfile profile) {
    final ctrl = TextEditingController(text: profile.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('YOUR NAME', style: GoogleFonts.orbitron(fontSize: 13, color: TechnoColors.neonCyan)),
        content: TextField(controller: ctrl, decoration: const InputDecoration(hintText: 'Enter your name')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              provider.updateProfile(UserProfile(
                name: ctrl.text.trim(),
                heightCm: profile.heightCm,
                injuries: profile.injuries,
                fitnessLevel: profile.fitnessLevel,
                focusAreas: profile.focusAreas,
                preferKg: profile.preferKg,
                preferGym: profile.preferGym,
              ));
              Navigator.pop(ctx);
            },
            child: Text('SAVE', style: TextStyle(color: TechnoColors.neonCyan)),
          ),
        ],
      ),
    );
  }

  void _editHeight(BuildContext context, AppProvider provider, UserProfile profile) {
    final ctrl = TextEditingController(text: profile.heightCm.round().toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('HEIGHT (CM)', style: GoogleFonts.orbitron(fontSize: 13, color: TechnoColors.neonCyan)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter height in cm'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              final h = double.tryParse(ctrl.text) ?? profile.heightCm;
              provider.updateProfile(UserProfile(
                name: profile.name,
                heightCm: h,
                injuries: profile.injuries,
                fitnessLevel: profile.fitnessLevel,
                focusAreas: profile.focusAreas,
                preferKg: profile.preferKg,
                preferGym: profile.preferGym,
              ));
              Navigator.pop(ctx);
            },
            child: Text('SAVE', style: TextStyle(color: TechnoColors.neonCyan)),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ── Streak Settings ───────────────────────────────────────────────────────────

class _StreakSettings extends StatelessWidget {
  final AppProvider provider;
  const _StreakSettings({required this.provider});

  @override
  Widget build(BuildContext context) {
    final streak = provider.data.streak;

    return NeonCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Sessions per week',
                  style: GoogleFonts.rajdhani(color: TechnoColors.textPrimary, fontSize: 15),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: streak.weeklySessionGoal > 1
                        ? () => provider.updateStreakSettings(sessions: streak.weeklySessionGoal - 1)
                        : null,
                    icon: const Icon(Icons.remove, size: 18),
                    color: TechnoColors.neonCyan,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  SizedBox(
                    width: 32,
                    child: Text(
                      '${streak.weeklySessionGoal}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.orbitron(
                        color: TechnoColors.neonCyan,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: streak.weeklySessionGoal < 7
                        ? () => provider.updateStreakSettings(sessions: streak.weeklySessionGoal + 1)
                        : null,
                    icon: const Icon(Icons.add, size: 18),
                    color: TechnoColors.neonCyan,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Minutes per week',
                  style: GoogleFonts.rajdhani(color: TechnoColors.textPrimary, fontSize: 15),
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: streak.weeklyMinutesGoal > 30
                        ? () => provider.updateStreakSettings(minutes: streak.weeklyMinutesGoal - 30)
                        : null,
                    icon: const Icon(Icons.remove, size: 18),
                    color: TechnoColors.neonPurple,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  SizedBox(
                    width: 48,
                    child: Text(
                      '${streak.weeklyMinutesGoal}',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.orbitron(
                        color: TechnoColors.neonPurple,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: streak.weeklyMinutesGoal < 600
                        ? () => provider.updateStreakSettings(minutes: streak.weeklyMinutesGoal + 30)
                        : null,
                    icon: const Icon(Icons.add, size: 18),
                    color: TechnoColors.neonPurple,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Hit EITHER goal to earn weekly streak credit',
            style: GoogleFonts.rajdhani(
              color: TechnoColors.textMuted,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

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

class _EditTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onEdit;

  const _EditTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: TechnoColors.textMuted, size: 20),
      title: Text(label, style: GoogleFonts.rajdhani(color: TechnoColors.textSecondary, fontSize: 13)),
      subtitle: Text(value, style: GoogleFonts.rajdhani(color: TechnoColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.edit_outlined, color: TechnoColors.neonCyan, size: 18),
      onTap: onEdit,
    );
  }
}

class _FitnessLevelTile extends StatelessWidget {
  final FitnessLevel level;
  final ValueChanged<FitnessLevel> onChanged;

  const _FitnessLevelTile({required this.level, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const labels = ['Beginner', 'Intermediate', 'Advanced'];
    const colors = [TechnoColors.neonGreen, TechnoColors.neonYellow, TechnoColors.neonPink];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.fitness_center, color: TechnoColors.textMuted, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Fitness Level', style: GoogleFonts.rajdhani(color: TechnoColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 6),
                Row(
                  children: List.generate(3, (i) {
                    final lvl = FitnessLevel.values[i];
                    final selected = lvl == level;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onChanged(lvl),
                        child: Container(
                          margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: selected ? colors[i].withValues(alpha: 0.12) : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: selected ? colors[i] : TechnoColors.cardBorder),
                          ),
                          child: Text(
                            labels[i],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.rajdhani(
                              color: selected ? colors[i] : TechnoColors.textMuted,
                              fontSize: 12,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
