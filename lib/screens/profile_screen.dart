import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_card.dart';
import '../providers/step_provider.dart';
import 'settings_screen.dart';

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
      appBar: AppBar(
        title: const Text('PROFILE'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: TechnoColors.neonCyan),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── User Info ──────────────────────────────────────────────────────
          _SectionHeader(label: 'USER INFO'),
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
                  value: _displayHeight(profile),
                  icon: Icons.height,
                  onEdit: () => _editHeight(context, provider, profile),
                ),
                const Divider(height: 1),
                _EditTile(
                  label: 'Age',
                  value: '${profile.age} yrs',
                  icon: Icons.cake_outlined,
                  onEdit: () => _editAge(context, provider, profile),
                ),
                const Divider(height: 1),
                _FitnessLevelTile(
                  level: profile.fitnessLevel,
                  onChanged: (l) =>
                      provider.updateProfile(profile.copyWith(fitnessLevel: l)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Injuries ───────────────────────────────────────────────────────
          NeonCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: InjuryArea.values.map((injury) {
                      final active = profile.injuries.contains(injury);
                      return GestureDetector(
                        onTap: () {
                          final injuries = List<InjuryArea>.from(profile.injuries);
                          final newSides = Map<InjuryArea, List<InjurySide>>.from(
                            profile.injurySides.map((k, v) => MapEntry(k, List<InjurySide>.from(v))),
                          );
                          if (active) {
                            injuries.remove(injury);
                            newSides.remove(injury);
                          } else {
                            injuries.add(injury);
                          }
                          provider.updateProfile(profile.copyWith(
                            injuries: injuries,
                            injurySides: newSides,
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
                if (profile.injuries.isNotEmpty) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      children: profile.injuries.map((injury) {
                        final sides = profile.injurySides[injury] ?? [];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 100,
                                child: Text(
                                  injury.label,
                                  style: GoogleFonts.rajdhani(
                                    color: TechnoColors.neonPink,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              _SideButton(
                                label: 'LEFT',
                                selected: sides.contains(InjurySide.left),
                                onTap: () => _toggleInjurySide(provider, profile, injury, InjurySide.left),
                              ),
                              const SizedBox(width: 8),
                              _SideButton(
                                label: 'RIGHT',
                                selected: sides.contains(InjurySide.right),
                                onTap: () => _toggleInjurySide(provider, profile, injury, InjurySide.right),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Workout Location ──────────────────────────────────────────────
          _SectionHeader(label: 'WORKOUT LOCATION'),
          const SizedBox(height: 8),
          NeonCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: _LocationButton(
                          label: 'HOME',
                          icon: Icons.home_outlined,
                          color: TechnoColors.neonCyan,
                          selected: !profile.preferGym,
                          onTap: () => provider
                              .updateProfile(profile.copyWith(preferGym: false)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _LocationButton(
                          label: 'GYM',
                          icon: Icons.fitness_center,
                          color: TechnoColors.neonPurple,
                          selected: profile.preferGym,
                          onTap: () => provider
                              .updateProfile(profile.copyWith(preferGym: true)),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'AVAILABLE EQUIPMENT',
                          style: GoogleFonts.orbitron(
                            color: TechnoColors.textMuted,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: EquipmentType.values.map((eq) {
                          final active = profile.homeEquipment.contains(eq);
                          return GestureDetector(
                            onTap: () {
                              final equipment = List<EquipmentType>.from(profile.homeEquipment);
                              active ? equipment.remove(eq) : equipment.add(eq);
                              provider.updateProfile(
                                  profile.copyWith(homeEquipment: equipment));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(
                                color: active
                                    ? TechnoColors.neonCyan.withValues(alpha: 0.12)
                                    : TechnoColors.bgTertiary,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: active
                                      ? TechnoColors.neonCyan
                                      : TechnoColors.cardBorder,
                                ),
                              ),
                              child: Text(
                                eq.label,
                                style: GoogleFonts.rajdhani(
                                  color: active
                                      ? TechnoColors.neonCyan
                                      : TechnoColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

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
                  const Spacer(),
                  Builder(builder: (_) {
                    final prev = provider.previousWeight;
                    if (prev == null) return const SizedBox.shrink();
                    final delta = latestWeight - prev;
                    final displayDelta = profile.preferKg ? delta : delta * 2.20462;
                    final isDown = delta < 0;
                    final isUp = delta > 0;
                    final arrowColor = isDown
                        ? TechnoColors.neonGreen
                        : isUp
                            ? TechnoColors.neonPink
                            : TechnoColors.textMuted;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isDown
                              ? Icons.arrow_downward
                              : isUp
                                  ? Icons.arrow_upward
                                  : Icons.remove,
                          color: arrowColor,
                          size: 16,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${displayDelta.abs().toStringAsFixed(1)} ${profile.preferKg ? "kg" : "lbs"}',
                          style: GoogleFonts.orbitron(
                            color: arrowColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          const SizedBox(height: 24),

          // ── Weekly Goal ────────────────────────────────────────────────────
          _SectionHeader(label: 'WEEKLY GOAL'),
          const SizedBox(height: 8),
          _StreakSettings(provider: provider),
          const SizedBox(height: 20),

          // ── Daily Goal ─────────────────────────────────────────────────────
          _SectionHeader(label: 'DAILY GOAL'),
          const SizedBox(height: 8),
          _DailySettings(provider: provider),
          const SizedBox(height: 20),

          // ── Fitness Goals ──────────────────────────────────────────────────
          _SectionHeader(label: 'FITNESS GOALS'),
          const SizedBox(height: 8),
          if (profile.goals.isEmpty)
            NeonCard(
              child: Center(
                child: Text(
                  'No goals set',
                  style: GoogleFonts.rajdhani(color: TechnoColors.textMuted, fontSize: 14),
                ),
              ),
            )
          else ...[
            NeonCard(
              padding: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: profile.goals.map((goal) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: TechnoColors.neonCyan.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: TechnoColors.neonCyan),
                      ),
                      child: Text(
                        '${goal.emoji}  ${goal.label}',
                        style: GoogleFonts.rajdhani(
                          color: TechnoColors.neonCyan,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            if (profile.goals.contains(FitnessGoal.loseWeight) && profile.goalWeightKg != null) ...[
              const SizedBox(height: 8),
              NeonCard(
                padding: EdgeInsets.zero,
                borderColor: TechnoColors.neonGreen.withValues(alpha: 0.5),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                      child: Row(
                        children: [
                          const Icon(Icons.track_changes, color: TechnoColors.neonGreen, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'WEIGHT GOAL',
                            style: GoogleFonts.orbitron(
                              color: TechnoColors.neonGreen,
                              fontSize: 10,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Builder(builder: (_) {
                        final goalKg = profile.goalWeightKg!;
                        String fmt(double kg) => profile.preferKg
                            ? '${kg.toStringAsFixed(1)} kg'
                            : '${(kg * 2.20462).toStringAsFixed(1)} lbs';

                        return Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text('CURRENT', style: GoogleFonts.orbitron(color: TechnoColors.textMuted, fontSize: 9, letterSpacing: 1)),
                                      const SizedBox(height: 4),
                                      Text(
                                        latestWeight != null ? fmt(latestWeight) : '—',
                                        style: GoogleFonts.orbitron(color: TechnoColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.arrow_forward, color: TechnoColors.neonGreen, size: 18),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text('GOAL', style: GoogleFonts.orbitron(color: TechnoColors.textMuted, fontSize: 9, letterSpacing: 1)),
                                      const SizedBox(height: 4),
                                      Text(
                                        fmt(goalKg),
                                        style: GoogleFonts.orbitron(color: TechnoColors.neonGreen, fontSize: 16, fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (latestWeight != null) ...[
                              const SizedBox(height: 14),
                              Builder(builder: (_) {
                                final delta = latestWeight - goalKg;
                                if (delta <= 0) {
                                  return Text(
                                    'Goal reached!',
                                    style: GoogleFonts.orbitron(color: TechnoColors.neonGreen, fontSize: 12),
                                  );
                                }
                                final firstKg = provider.data.weightHistory.isNotEmpty
                                    ? provider.data.weightHistory.first.weightKg
                                    : latestWeight;
                                final totalToLose = firstKg - goalKg;
                                final progress = totalToLose > 0
                                    ? ((firstKg - latestWeight) / totalToLose).clamp(0.0, 1.0)
                                    : 0.0;
                                final displayDelta = profile.preferKg ? delta : delta * 2.20462;
                                final unit = profile.preferKg ? 'kg' : 'lbs';
                                return Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '${displayDelta.toStringAsFixed(1)} $unit to go',
                                          style: GoogleFonts.rajdhani(
                                            color: TechnoColors.textSecondary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '${(progress * 100).round()}%',
                                          style: GoogleFonts.orbitron(
                                            color: TechnoColors.neonGreen,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: TechnoColors.bgTertiary,
                                        valueColor: const AlwaysStoppedAnimation(TechnoColors.neonGreen),
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ],
                          ],
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ],
          const SizedBox(height: 20),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  String _displayHeight(UserProfile p) {
    if (p.preferCm) return '${p.heightCm.round()} cm';
    final totalIn = (p.heightCm / 2.54).round();
    return "${totalIn ~/ 12}' ${totalIn % 12}\"";
  }

  void _toggleInjurySide(AppProvider provider, UserProfile profile, InjuryArea area, InjurySide side) {
    final newSides = Map<InjuryArea, List<InjurySide>>.from(
      profile.injurySides.map((k, v) => MapEntry(k, List<InjurySide>.from(v))),
    );
    final sides = List<InjurySide>.from(newSides[area] ?? []);
    sides.contains(side) ? sides.remove(side) : sides.add(side);
    newSides[area] = sides;
    provider.updateProfile(profile.copyWith(injurySides: newSides));
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
              provider.updateProfile(profile.copyWith(name: ctrl.text.trim()));
              Navigator.pop(ctx);
            },
            child: Text('SAVE', style: TextStyle(color: TechnoColors.neonCyan)),
          ),
        ],
      ),
    );
  }

  void _editHeight(BuildContext context, AppProvider provider, UserProfile profile) {
    if (profile.preferCm) {
      _editHeightCm(context, provider, profile);
    } else {
      _editHeightImperial(context, provider, profile);
    }
  }

  void _editHeightCm(BuildContext context, AppProvider provider, UserProfile profile) {
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
              provider.updateProfile(profile.copyWith(heightCm: h));
              Navigator.pop(ctx);
            },
            child: Text('SAVE', style: TextStyle(color: TechnoColors.neonCyan)),
          ),
        ],
      ),
    );
  }

  void _editHeightImperial(BuildContext context, AppProvider provider, UserProfile profile) {
    final totalIn = (profile.heightCm / 2.54).round();
    final ftCtrl = TextEditingController(text: (totalIn ~/ 12).toString());
    final inCtrl = TextEditingController(text: (totalIn % 12).toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('HEIGHT (FT & IN)',
            style: GoogleFonts.orbitron(fontSize: 13, color: TechnoColors.neonCyan)),
        content: Row(
          children: [
            Expanded(
              child: TextField(
                controller: ftCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Feet'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: inCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Inches'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              final ft = int.tryParse(ftCtrl.text) ?? 0;
              final inches = int.tryParse(inCtrl.text) ?? 0;
              final cm = ((ft * 12) + inches) * 2.54;
              provider.updateProfile(profile.copyWith(
                heightCm: cm > 0 ? cm : profile.heightCm,
              ));
              Navigator.pop(ctx);
            },
            child: Text('SAVE', style: TextStyle(color: TechnoColors.neonCyan)),
          ),
        ],
      ),
    );
  }

  void _editAge(BuildContext context, AppProvider provider, UserProfile profile) {
    final ctrl = TextEditingController(text: '${profile.age}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('AGE', style: GoogleFonts.orbitron(fontSize: 13, color: TechnoColors.neonOrange)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter your age'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          TextButton(
            onPressed: () {
              final a = int.tryParse(ctrl.text) ?? profile.age;
              provider.updateProfile(profile.copyWith(age: a.clamp(10, 100)));
              Navigator.pop(ctx);
            },
            child: Text('SAVE', style: TextStyle(color: TechnoColors.neonOrange)),
          ),
        ],
      ),
    );
  }

}

// ── Location Button ──────────────────────────────────────────────────────────

class _LocationButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _LocationButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : TechnoColors.cardBorder,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: selected ? color : TechnoColors.textMuted),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.orbitron(
                color: selected ? color : TechnoColors.textMuted,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Side Button ──────────────────────────────────────────────────────────────

class _SideButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SideButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? TechnoColors.neonOrange.withValues(alpha: 0.2) : TechnoColors.bgSecondary,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? TechnoColors.neonOrange : TechnoColors.cardBorder.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.rajdhani(
            color: selected ? TechnoColors.neonOrange : TechnoColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ── Streak Settings ──────────────────────────────────────────────────────────

class _StreakSettings extends StatelessWidget {
  final AppProvider provider;
  const _StreakSettings({required this.provider});

  @override
  Widget build(BuildContext context) {
    final streak = provider.data.streak;

    return NeonCard(
      child: Column(
        children: [
          _GoalRow(
            label: 'Sessions per week',
            value: '${streak.weeklySessionGoal}',
            color: TechnoColors.neonCyan,
            valueWidth: 32,
            onDecrement: streak.weeklySessionGoal > 1
                ? () => provider.updateStreakSettings(sessions: streak.weeklySessionGoal - 1)
                : null,
            onIncrement: streak.weeklySessionGoal < 7
                ? () => provider.updateStreakSettings(sessions: streak.weeklySessionGoal + 1)
                : null,
          ),
          const Divider(height: 1),
          _GoalRow(
            label: 'Minutes per week',
            value: '${streak.weeklyMinutesGoal}',
            color: TechnoColors.neonPurple,
            valueWidth: 48,
            onDecrement: streak.weeklyMinutesGoal > 30
                ? () => provider.updateStreakSettings(minutes: streak.weeklyMinutesGoal - 30)
                : null,
            onIncrement: streak.weeklyMinutesGoal < 600
                ? () => provider.updateStreakSettings(minutes: streak.weeklyMinutesGoal + 30)
                : null,
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

// ── Daily Settings ───────────────────────────────────────────────────────────

class _DailySettings extends StatelessWidget {
  final AppProvider provider;
  const _DailySettings({required this.provider});

  @override
  Widget build(BuildContext context) {
    final streak = provider.data.streak;
    final rings = context.read<ActivityRingsProvider>();

    return NeonCard(
      child: Column(
        children: [
          _GoalRow(
            label: 'Steps per day',
            value: _fmtK(streak.dailyStepGoal),
            color: TechnoColors.neonCyan,
            valueWidth: 56,
            onDecrement: streak.dailyStepGoal > 1000
                ? () {
                    final g = streak.dailyStepGoal - 500;
                    provider.updateStreakSettings(dailySteps: g);
                    rings.setStepsGoal(g);
                  }
                : null,
            onIncrement: streak.dailyStepGoal < 50000
                ? () {
                    final g = streak.dailyStepGoal + 500;
                    provider.updateStreakSettings(dailySteps: g);
                    rings.setStepsGoal(g);
                  }
                : null,
          ),
          const Divider(height: 1),
          _GoalRow(
            label: 'Active minutes',
            value: '${streak.dailyActiveMinutesGoal}m',
            color: TechnoColors.neonGreen,
            valueWidth: 48,
            onDecrement: streak.dailyActiveMinutesGoal > 10
                ? () {
                    final g = streak.dailyActiveMinutesGoal - 5;
                    provider.updateStreakSettings(dailyActiveMinutes: g);
                    rings.setActiveMinutesGoal(g);
                  }
                : null,
            onIncrement: streak.dailyActiveMinutesGoal < 180
                ? () {
                    final g = streak.dailyActiveMinutesGoal + 5;
                    provider.updateStreakSettings(dailyActiveMinutes: g);
                    rings.setActiveMinutesGoal(g);
                  }
                : null,
          ),
          const Divider(height: 1),
          _GoalRow(
            label: 'Calories',
            value: _fmtK(streak.dailyCaloriesGoal),
            color: TechnoColors.neonOrange,
            valueWidth: 56,
            onDecrement: streak.dailyCaloriesGoal > 500
                ? () {
                    final g = streak.dailyCaloriesGoal - 50;
                    provider.updateStreakSettings(dailyCalories: g);
                    rings.setCaloriesGoal(g);
                  }
                : null,
            onIncrement: streak.dailyCaloriesGoal < 5000
                ? () {
                    final g = streak.dailyCaloriesGoal + 50;
                    provider.updateStreakSettings(dailyCalories: g);
                    rings.setCaloriesGoal(g);
                  }
                : null,
          ),
          const Divider(height: 1),
          _GoalRow(
            label: 'Water',
            value: _fmtWater(streak.dailyWaterGoalMl.toDouble()),
            color: TechnoColors.neonPurple,
            valueWidth: 56,
            onDecrement: streak.dailyWaterGoalMl > 500
                ? () {
                    final g = streak.dailyWaterGoalMl - 250;
                    provider.updateStreakSettings(dailyWaterMl: g);
                    rings.setWaterGoal(g);
                  }
                : null,
            onIncrement: streak.dailyWaterGoalMl < 5000
                ? () {
                    final g = streak.dailyWaterGoalMl + 250;
                    provider.updateStreakSettings(dailyWaterMl: g);
                    rings.setWaterGoal(g);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  static String _fmtK(int n) {
    if (n % 1000 == 0) return '${n ~/ 1000}K';
    return '${(n / 1000).toStringAsFixed(1)}K';
  }

  static String _fmtWater(double ml) {
    if (ml >= 1000) return '${(ml / 1000).toStringAsFixed(ml % 1000 == 0 ? 0 : 1)}L';
    return '${ml.round()}ml';
  }
}

// ── Shared goal row ──────────────────────────────────────────────────────────

class _GoalRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double valueWidth;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  const _GoalRow({
    required this.label,
    required this.value,
    required this.color,
    required this.valueWidth,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.rajdhani(color: TechnoColors.textPrimary, fontSize: 15),
          ),
        ),
        IconButton(
          onPressed: onDecrement,
          icon: const Icon(Icons.remove, size: 18),
          color: color,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        SizedBox(
          width: valueWidth,
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          onPressed: onIncrement,
          icon: const Icon(Icons.add, size: 18),
          color: color,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
      ],
    );
  }
}

// ── Shared widgets ───────────────────────────────────────────────────────────

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
