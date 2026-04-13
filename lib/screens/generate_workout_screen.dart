import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../services/workout_generator.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_card.dart';
import 'active_workout_screen.dart';

class GenerateWorkoutScreen extends StatefulWidget {
  final WorkoutType? presetType;
  final List<EquipmentType>? presetEquipment;

  const GenerateWorkoutScreen({
    super.key,
    this.presetType,
    this.presetEquipment,
  });

  @override
  State<GenerateWorkoutScreen> createState() => _GenerateWorkoutScreenState();
}

class _GenerateWorkoutScreenState extends State<GenerateWorkoutScreen> {
  WorkoutType _type = WorkoutType.strength;
  final Set<MuscleGroup> _focusAreas = {MuscleGroup.fullBody};
  final Set<EquipmentType> _equipment = {EquipmentType.none};
  Set<InjuryArea> _injuries = {};
  FitnessLevel _level = FitnessLevel.intermediate;
  int _duration = 45;
  bool _atGym = false;

  List<WorkoutExerciseLog>? _preview;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AppProvider>().data.profile;
    _level = profile.fitnessLevel;
    _atGym = profile.preferGym;
    _injuries = profile.injuries.toSet();
    if (widget.presetType != null) _type = widget.presetType!;
    if (widget.presetEquipment != null) {
      _equipment
        ..clear()
        ..addAll(widget.presetEquipment!);
    } else if (_atGym) {
      _equipment.add(EquipmentType.fullGym);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GENERATE WORKOUT'),
      ),
      body: _preview != null ? _PreviewPane(
        exercises: _preview!,
        type: _type,
        atGym: _atGym,
        duration: _duration,
        onRegen: () => setState(() => _preview = null),
        onStart: () => _startWorkout(context),
      ) : _ConfigPane(
        type: _type,
        focusAreas: _focusAreas,
        equipment: _equipment,
        injuries: _injuries,
        level: _level,
        duration: _duration,
        atGym: _atGym,
        onTypeChanged: (t) => setState(() => _type = t),
        onFocusChanged: (m) => setState(() {
          if (m == MuscleGroup.fullBody) {
            _focusAreas
              ..clear()
              ..add(MuscleGroup.fullBody);
          } else {
            _focusAreas.remove(MuscleGroup.fullBody);
            _focusAreas.contains(m) ? _focusAreas.remove(m) : _focusAreas.add(m);
            if (_focusAreas.isEmpty) _focusAreas.add(MuscleGroup.fullBody);
          }
        }),
        onEquipmentChanged: (eq) => setState(() {
          _equipment.contains(eq) ? _equipment.remove(eq) : _equipment.add(eq);
          if (_equipment.isEmpty) _equipment.add(EquipmentType.none);
        }),
        onInjuryChanged: (inj) => setState(() {
          _injuries.contains(inj) ? _injuries.remove(inj) : _injuries.add(inj);
        }),
        onLevelChanged: (l) => setState(() => _level = l),
        onDurationChanged: (d) => setState(() => _duration = d),
        onGymChanged: (v) => setState(() {
          _atGym = v;
          if (v) {
            _equipment.add(EquipmentType.fullGym);
          } else {
            _equipment.remove(EquipmentType.fullGym);
            if (_equipment.isEmpty) _equipment.add(EquipmentType.none);
          }
        }),
        onGenerate: _generate,
      ),
    );
  }

  void _generate() {
    final req = WorkoutRequest(
      type: _type,
      focusAreas: _focusAreas.toList(),
      availableEquipment: _equipment.toList(),
      fitnessLevel: _level,
      injuries: _injuries.toList(),
      targetMinutes: _duration,
      isAtGym: _atGym,
    );
    final exercises = WorkoutGenerator.generate(req);
    setState(() => _preview = exercises);
  }

  void _startWorkout(BuildContext context) {
    final provider = context.read<AppProvider>();
    if (provider.hasActiveWorkout) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Finish your current workout first!')),
      );
      return;
    }
    final name = '${_type.label} — ${_focusAreas.map((m) => m.label).join(', ')}';
    provider.startWorkout(
      name: name,
      type: _type,
      isAtGym: _atGym,
      exercises: _preview!,
    );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
    );
  }
}

// ── Config Pane ───────────────────────────────────────────────────────────────

class _ConfigPane extends StatelessWidget {
  final WorkoutType type;
  final Set<MuscleGroup> focusAreas;
  final Set<EquipmentType> equipment;
  final Set<InjuryArea> injuries;
  final FitnessLevel level;
  final int duration;
  final bool atGym;
  final ValueChanged<WorkoutType> onTypeChanged;
  final ValueChanged<MuscleGroup> onFocusChanged;
  final ValueChanged<EquipmentType> onEquipmentChanged;
  final ValueChanged<InjuryArea> onInjuryChanged;
  final ValueChanged<FitnessLevel> onLevelChanged;
  final ValueChanged<int> onDurationChanged;
  final ValueChanged<bool> onGymChanged;
  final VoidCallback onGenerate;

  const _ConfigPane({
    required this.type,
    required this.focusAreas,
    required this.equipment,
    required this.injuries,
    required this.level,
    required this.duration,
    required this.atGym,
    required this.onTypeChanged,
    required this.onFocusChanged,
    required this.onEquipmentChanged,
    required this.onInjuryChanged,
    required this.onLevelChanged,
    required this.onDurationChanged,
    required this.onGymChanged,
    required this.onGenerate,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workout type
          _SectionHeader(label: 'WORKOUT TYPE'),
          const SizedBox(height: 8),
          _TypeSelector(selected: type, onChanged: onTypeChanged),
          const SizedBox(height: 20),

          // Location toggle
          Row(
            children: [
              _SectionHeader(label: 'LOCATION'),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.home,
                    color: !atGym ? TechnoColors.neonCyan : TechnoColors.textMuted,
                    size: 18,
                  ),
                  Switch(value: atGym, onChanged: onGymChanged),
                  Icon(
                    Icons.location_on,
                    color: atGym ? TechnoColors.neonCyan : TechnoColors.textMuted,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Focus areas
          _SectionHeader(label: 'FOCUS AREAS'),
          const SizedBox(height: 8),
          _ChipGrid(
            options: MuscleGroup.values,
            selected: focusAreas.cast<Enum>().toSet(),
            label: (m) => (m as MuscleGroup).label,
            onTap: (m) => onFocusChanged(m as MuscleGroup),
            color: TechnoColors.neonCyan,
          ),
          const SizedBox(height: 20),

          // Equipment
          if (!atGym) ...[
            _SectionHeader(label: 'AVAILABLE EQUIPMENT'),
            const SizedBox(height: 8),
            _ChipGrid(
              options: EquipmentType.values.where((e) => e != EquipmentType.fullGym).toList(),
              selected: equipment.cast<Enum>().toSet(),
              label: (e) => (e as EquipmentType).label,
              onTap: (e) => onEquipmentChanged(e as EquipmentType),
              color: TechnoColors.neonPurple,
            ),
            const SizedBox(height: 20),
          ],

          // Duration
          _SectionHeader(label: 'DURATION: ${duration} MIN'),
          Slider(
            value: duration.toDouble(),
            min: 15,
            max: 90,
            divisions: 5,
            onChanged: (v) => onDurationChanged(v.round()),
            label: '$duration min',
          ),
          const SizedBox(height: 20),

          // Fitness level
          _SectionHeader(label: 'FITNESS LEVEL'),
          const SizedBox(height: 8),
          _LevelSelector(selected: level, onChanged: onLevelChanged),
          const SizedBox(height: 20),

          // Injuries
          _SectionHeader(label: 'INJURIES / LIMITATIONS'),
          const SizedBox(height: 8),
          _ChipGrid(
            options: InjuryArea.values,
            selected: injuries.cast<Enum>().toSet(),
            label: (i) => (i as InjuryArea).label,
            onTap: (i) => onInjuryChanged(i as InjuryArea),
            color: TechnoColors.neonPink,
          ),
          const SizedBox(height: 32),

          // Generate button
          NeonButton(
            label: 'GENERATE WORKOUT',
            icon: Icons.bolt,
            color: TechnoColors.neonCyan,
            onTap: onGenerate,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
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

class _TypeSelector extends StatelessWidget {
  final WorkoutType selected;
  final ValueChanged<WorkoutType> onChanged;

  const _TypeSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1.6,
      ),
      itemCount: WorkoutType.values.length,
      itemBuilder: (ctx, i) {
        final t = WorkoutType.values[i];
        final isSelected = t == selected;
        return GestureDetector(
          onTap: () => onChanged(t),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? TechnoColors.neonCyan.withValues(alpha: 0.15)
                  : TechnoColors.cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? TechnoColors.neonCyan : TechnoColors.cardBorder,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(t.emoji, style: const TextStyle(fontSize: 20)),
                const SizedBox(height: 4),
                Text(
                  t.label.toUpperCase(),
                  style: GoogleFonts.orbitron(
                    color: isSelected ? TechnoColors.neonCyan : TechnoColors.textSecondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LevelSelector extends StatelessWidget {
  final FitnessLevel selected;
  final ValueChanged<FitnessLevel> onChanged;

  const _LevelSelector({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const levels = FitnessLevel.values;
    const colors = [TechnoColors.neonGreen, TechnoColors.neonYellow, TechnoColors.neonPink];
    const labels = ['BEGINNER', 'INTERMEDIATE', 'ADVANCED'];

    return Row(
      children: List.generate(levels.length, (i) {
        final isSelected = levels[i] == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(levels[i]),
            child: Container(
              margin: EdgeInsets.only(right: i < levels.length - 1 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? colors[i].withValues(alpha: 0.15) : TechnoColors.cardBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? colors[i] : TechnoColors.cardBorder,
                ),
              ),
              child: Text(
                labels[i],
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  color: isSelected ? colors[i] : TechnoColors.textMuted,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ChipGrid extends StatelessWidget {
  final List<dynamic> options;
  final Set<Enum> selected;
  final String Function(dynamic) label;
  final ValueChanged<dynamic> onTap;
  final Color color;

  const _ChipGrid({
    required this.options,
    required this.selected,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = selected.contains(opt);
        return GestureDetector(
          onTap: () => onTap(opt),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.12) : TechnoColors.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : TechnoColors.cardBorder,
              ),
            ),
            child: Text(
              label(opt),
              style: GoogleFonts.rajdhani(
                color: isSelected ? color : TechnoColors.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Preview Pane ──────────────────────────────────────────────────────────────

class _PreviewPane extends StatelessWidget {
  final List<WorkoutExerciseLog> exercises;
  final WorkoutType type;
  final bool atGym;
  final int duration;
  final VoidCallback onRegen;
  final VoidCallback onStart;

  const _PreviewPane({
    required this.exercises,
    required this.type,
    required this.atGym,
    required this.duration,
    required this.onRegen,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${type.label.toUpperCase()} WORKOUT',
                      style: GoogleFonts.orbitron(
                        color: TechnoColors.neonCyan,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${exercises.length} exercises  •  ~$duration min  •  ${atGym ? "Gym" : "Home"}',
                      style: GoogleFonts.rajdhani(
                        color: TechnoColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onRegen,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: TechnoColors.bgTertiary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: TechnoColors.cardBorder),
                  ),
                  child: const Icon(Icons.refresh, color: TechnoColors.neonCyan),
                ),
              ),
            ],
          ),
        ),

        // Exercise list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: exercises.length,
            itemBuilder: (ctx, i) {
              final ex = exercises[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: NeonCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: TechnoColors.neonCyan.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: GoogleFonts.orbitron(
                              color: TechnoColors.neonCyan,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ex.exerciseName,
                              style: GoogleFonts.rajdhani(
                                color: TechnoColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              ex.primaryMuscle.label,
                              style: GoogleFonts.rajdhani(
                                color: TechnoColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${ex.sets.length} sets',
                            style: GoogleFonts.orbitron(
                              color: TechnoColors.neonCyan,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            ex.isTimeBased
                                ? '${ex.sets.first.repsOrSeconds}s'
                                : '${ex.sets.first.repsOrSeconds} reps',
                            style: GoogleFonts.rajdhani(
                              color: TechnoColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Buttons
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            children: [
              NeonButton(
                label: 'START WORKOUT',
                icon: Icons.play_arrow,
                color: TechnoColors.neonGreen,
                onTap: onStart,
              ),
              const SizedBox(height: 10),
              NeonButton(
                label: 'REGENERATE',
                icon: Icons.refresh,
                color: TechnoColors.neonCyan,
                outlined: true,
                onTap: onRegen,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
