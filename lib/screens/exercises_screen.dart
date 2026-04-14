import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../data/exercise_database.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_card.dart';
import 'active_workout_screen.dart';

// ─── Plan Data ────────────────────────────────────────────────────────────────

enum _PlanCategory { bodybuilding, cardio, running, muscleBuilding }

extension _PlanCategoryX on _PlanCategory {
  String get label {
    switch (this) {
      case _PlanCategory.bodybuilding:
        return 'BODYBUILDING';
      case _PlanCategory.cardio:
        return 'CARDIO';
      case _PlanCategory.running:
        return 'RUNNING';
      case _PlanCategory.muscleBuilding:
        return 'MUSCLE BUILDING';
    }
  }

  Color get color {
    switch (this) {
      case _PlanCategory.bodybuilding:
        return TechnoColors.neonCyan;
      case _PlanCategory.cardio:
        return TechnoColors.neonOrange;
      case _PlanCategory.running:
        return TechnoColors.neonGreen;
      case _PlanCategory.muscleBuilding:
        return TechnoColors.neonPink;
    }
  }

  String get emoji {
    switch (this) {
      case _PlanCategory.bodybuilding:
        return '🏆';
      case _PlanCategory.cardio:
        return '🔥';
      case _PlanCategory.running:
        return '🏃';
      case _PlanCategory.muscleBuilding:
        return '💪';
    }
  }
}

class _WorkoutPlan {
  final String id;
  final String name;
  final String description;
  final _PlanCategory category;
  final String emoji;
  final List<String> exerciseIds;
  final int estimatedMinutes;
  final WorkoutType workoutType;

  const _WorkoutPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.emoji,
    required this.exerciseIds,
    required this.estimatedMinutes,
    required this.workoutType,
  });
}

final List<_WorkoutPlan> _kPlans = [
  // ── BODYBUILDING ─────────────────────────────────────────────────────────
  const _WorkoutPlan(
    id: 'push_day',
    name: 'Push Day',
    description: 'Chest, shoulders & triceps. Classic PPL push session for muscle and strength.',
    category: _PlanCategory.bodybuilding,
    emoji: '🫸',
    exerciseIds: [
      'bench_press', 'incline_db_press', 'cable_fly', 'db_flye',
      'ohp', 'lateral_raise', 'front_raise',
      'tricep_pushdown', 'overhead_tricep',
    ],
    estimatedMinutes: 65,
    workoutType: WorkoutType.strength,
  ),
  const _WorkoutPlan(
    id: 'pull_day',
    name: 'Pull Day',
    description: 'Back & biceps. Build a wide, thick back with heavy compound pulling.',
    category: _PlanCategory.bodybuilding,
    emoji: '🫳',
    exerciseIds: [
      'deadlift', 'pullup', 'lat_pulldown',
      'bent_over_row', 'cable_row', 'db_row',
      'barbell_curl', 'hammer_curl', 'chin_up',
    ],
    estimatedMinutes: 65,
    workoutType: WorkoutType.strength,
  ),
  const _WorkoutPlan(
    id: 'leg_day_bb',
    name: 'Leg Day',
    description: 'Quads, hamstrings, glutes & calves. Never skip leg day.',
    category: _PlanCategory.bodybuilding,
    emoji: '🦵',
    exerciseIds: [
      'squat', 'leg_press', 'lunges',
      'rdl', 'leg_curl',
      'hip_thrust', 'standing_calf_raise', 'seated_calf_raise',
    ],
    estimatedMinutes: 70,
    workoutType: WorkoutType.strength,
  ),
  const _WorkoutPlan(
    id: 'classic_5x5',
    name: 'Classic 5×5',
    description: 'The original strength program. Five heavy compound lifts for maximum gains.',
    category: _PlanCategory.bodybuilding,
    emoji: '⚔️',
    exerciseIds: ['squat', 'bench_press', 'deadlift', 'bent_over_row', 'ohp'],
    estimatedMinutes: 60,
    workoutType: WorkoutType.strength,
  ),

  // ── CARDIO ───────────────────────────────────────────────────────────────
  const _WorkoutPlan(
    id: 'hiit_blast',
    name: 'HIIT Blast',
    description: 'Max intensity intervals designed to torch calories and spike your heart rate.',
    category: _PlanCategory.cardio,
    emoji: '⚡',
    exerciseIds: [
      'burpees', 'mountain_climbers', 'jumping_jacks',
      'high_knees', 'box_jumps',
    ],
    estimatedMinutes: 30,
    workoutType: WorkoutType.hiit,
  ),
  const _WorkoutPlan(
    id: 'steady_state',
    name: 'Steady State',
    description: 'Low-intensity sustained cardio for fat burning and aerobic base building.',
    category: _PlanCategory.cardio,
    emoji: '🫀',
    exerciseIds: ['treadmill_run', 'jump_rope', 'jumping_jacks'],
    estimatedMinutes: 45,
    workoutType: WorkoutType.cardio,
  ),
  const _WorkoutPlan(
    id: 'full_body_burn',
    name: 'Full Body Burn',
    description: 'Combines functional strength moves with cardio for a complete metabolic workout.',
    category: _PlanCategory.cardio,
    emoji: '🔥',
    exerciseIds: ['kb_swing', 'thruster', 'burpees', 'clean_press', 'box_jumps'],
    estimatedMinutes: 40,
    workoutType: WorkoutType.mixed,
  ),

  // ── RUNNING ──────────────────────────────────────────────────────────────
  const _WorkoutPlan(
    id: 'speed_intervals',
    name: 'Speed Intervals',
    description: 'Alternating sprint and recovery intervals to build speed and VO2 max.',
    category: _PlanCategory.running,
    emoji: '💨',
    exerciseIds: ['treadmill_run', 'high_knees', 'box_jumps', 'jump_rope'],
    estimatedMinutes: 35,
    workoutType: WorkoutType.cardio,
  ),
  const _WorkoutPlan(
    id: 'plyo_power',
    name: 'Plyometric Power',
    description: 'Explosive movements to build the leg power and coordination needed for faster running.',
    category: _PlanCategory.running,
    emoji: '🚀',
    exerciseIds: ['box_jumps', 'jump_rope', 'burpees', 'high_knees', 'lunges'],
    estimatedMinutes: 30,
    workoutType: WorkoutType.hiit,
  ),
  const _WorkoutPlan(
    id: 'endurance_base',
    name: 'Endurance Base',
    description: 'Long aerobic run to build your base mileage and strengthen running muscles.',
    category: _PlanCategory.running,
    emoji: '🏅',
    exerciseIds: ['treadmill_run', 'standing_calf_raise', 'rdl_db'],
    estimatedMinutes: 50,
    workoutType: WorkoutType.cardio,
  ),

  // ── MUSCLE BUILDING ───────────────────────────────────────────────────────
  const _WorkoutPlan(
    id: 'chest_builder',
    name: 'Chest Builder',
    description: 'All angles of the chest covered — upper, mid, and inner. Maximum pec activation.',
    category: _PlanCategory.muscleBuilding,
    emoji: '🫁',
    exerciseIds: ['bench_press', 'incline_db_press', 'cable_fly', 'dips', 'db_flye'],
    estimatedMinutes: 50,
    workoutType: WorkoutType.strength,
  ),
  const _WorkoutPlan(
    id: 'back_builder',
    name: 'Back Builder',
    description: 'Width and thickness from every angle. Build the V-taper with heavy compound pulls.',
    category: _PlanCategory.muscleBuilding,
    emoji: '🪵',
    exerciseIds: ['deadlift', 'pullup', 'lat_pulldown', 'bent_over_row', 'cable_row'],
    estimatedMinutes: 60,
    workoutType: WorkoutType.strength,
  ),
  const _WorkoutPlan(
    id: 'shoulder_sculptor',
    name: 'Shoulder Sculptor',
    description: 'Develop full, rounded delts for that 3D look. Front, side, and overhead.',
    category: _PlanCategory.muscleBuilding,
    emoji: '🎯',
    exerciseIds: ['ohp', 'db_shoulder_press', 'lateral_raise', 'front_raise'],
    estimatedMinutes: 45,
    workoutType: WorkoutType.strength,
  ),
  const _WorkoutPlan(
    id: 'arm_destroyer',
    name: 'Arm Destroyer',
    description: 'Biceps and triceps superset session for maximum pump and arm growth.',
    category: _PlanCategory.muscleBuilding,
    emoji: '💪',
    exerciseIds: [
      'barbell_curl', 'hammer_curl', 'chin_up',
      'tricep_pushdown', 'overhead_tricep', 'tricep_dips_bench',
    ],
    estimatedMinutes: 50,
    workoutType: WorkoutType.strength,
  ),
  const _WorkoutPlan(
    id: 'leg_power',
    name: 'Leg Power',
    description: 'Build powerful quads, hamstrings and glutes. Complete lower body hypertrophy.',
    category: _PlanCategory.muscleBuilding,
    emoji: '🦿',
    exerciseIds: [
      'squat', 'leg_press', 'lunges',
      'rdl', 'leg_curl', 'hip_thrust',
      'standing_calf_raise',
    ],
    estimatedMinutes: 70,
    workoutType: WorkoutType.strength,
  ),
  const _WorkoutPlan(
    id: 'core_forge',
    name: 'Core Forge',
    description: 'Build real core strength — not just abs. Stability, anti-rotation, and power.',
    category: _PlanCategory.muscleBuilding,
    emoji: '🔩',
    exerciseIds: [
      'plank', 'ab_wheel', 'leg_raises',
      'bicycle_crunch', 'mountain_climbers', 'crunches',
    ],
    estimatedMinutes: 30,
    workoutType: WorkoutType.bodyweight,
  ),
];

// ─── Main Screen ──────────────────────────────────────────────────────────────

class ExercisesScreen extends StatefulWidget {
  const ExercisesScreen({super.key});

  @override
  State<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends State<ExercisesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EXERCISES'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: TechnoColors.neonCyan,
          labelColor: TechnoColors.neonCyan,
          unselectedLabelColor: TechnoColors.textSecondary,
          labelStyle: GoogleFonts.orbitron(fontSize: 11, letterSpacing: 2),
          unselectedLabelStyle: GoogleFonts.orbitron(fontSize: 11, letterSpacing: 2),
          tabs: const [
            Tab(text: 'EXERCISES'),
            Tab(text: 'PLANS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ExercisesTab(),
          _PlansTab(),
        ],
      ),
    );
  }
}

// ─── EXERCISES TAB ────────────────────────────────────────────────────────────

class _ExercisesTab extends StatefulWidget {
  const _ExercisesTab();

  @override
  State<_ExercisesTab> createState() => _ExercisesTabState();
}

class _ExercisesTabState extends State<_ExercisesTab> {
  final _searchController = TextEditingController();
  MuscleGroup? _selectedMuscle;
  String _query = '';

  static const _muscleFilters = [
    null, // All
    MuscleGroup.chest,
    MuscleGroup.back,
    MuscleGroup.shoulders,
    MuscleGroup.biceps,
    MuscleGroup.triceps,
    MuscleGroup.quadriceps,
    MuscleGroup.hamstrings,
    MuscleGroup.glutes,
    MuscleGroup.calves,
    MuscleGroup.core,
    MuscleGroup.cardio,
    MuscleGroup.fullBody,
  ];

  List<Exercise> get _filtered {
    final q = _query.toLowerCase();
    return kExercises.where((e) {
      final matchesMuscle =
          _selectedMuscle == null || e.primaryMuscle == _selectedMuscle;
      final matchesQuery = q.isEmpty ||
          e.name.toLowerCase().contains(q) ||
          e.primaryMuscle.label.toLowerCase().contains(q);
      return matchesMuscle && matchesQuery;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exercises = _filtered;

    return Column(
      children: [
        // ── Search ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            controller: _searchController,
            style: GoogleFonts.rajdhani(color: TechnoColors.textPrimary, fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Search exercises...',
              hintStyle: GoogleFonts.rajdhani(
                  color: TechnoColors.textMuted, fontSize: 15),
              prefixIcon: const Icon(Icons.search, color: TechnoColors.textMuted, size: 20),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: TechnoColors.textMuted, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),

        // ── Muscle filter chips ──────────────────────────────────────────────
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _muscleFilters.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final muscle = _muscleFilters[i];
              final isSelected = _selectedMuscle == muscle;
              final label = muscle?.label ?? 'All';
              return GestureDetector(
                onTap: () => setState(() => _selectedMuscle = muscle),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? TechnoColors.neonCyan.withValues(alpha: 0.15)
                        : TechnoColors.bgSecondary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? TechnoColors.neonCyan
                          : TechnoColors.textMuted.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    label.toUpperCase(),
                    style: GoogleFonts.orbitron(
                      color: isSelected
                          ? TechnoColors.neonCyan
                          : TechnoColors.textSecondary,
                      fontSize: 9,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // ── Count label ─────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Text(
                '${exercises.length} EXERCISE${exercises.length == 1 ? '' : 'S'}',
                style: GoogleFonts.orbitron(
                  color: TechnoColors.textMuted,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // ── Exercise list ────────────────────────────────────────────────────
        Expanded(
          child: exercises.isEmpty
              ? Center(
                  child: Text(
                    'No exercises found',
                    style: GoogleFonts.rajdhani(
                        color: TechnoColors.textMuted, fontSize: 15),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  itemCount: exercises.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) =>
                      _ExerciseCard(exercise: exercises[i]),
                ),
        ),
      ],
    );
  }
}

class _ExerciseCard extends StatefulWidget {
  final Exercise exercise;
  const _ExerciseCard({required this.exercise});

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  bool _expanded = false;

  Color get _muscleColor {
    switch (widget.exercise.primaryMuscle) {
      case MuscleGroup.chest:
        return TechnoColors.neonCyan;
      case MuscleGroup.back:
        return TechnoColors.neonPurple;
      case MuscleGroup.shoulders:
        return TechnoColors.neonYellow;
      case MuscleGroup.biceps:
        return TechnoColors.neonGreen;
      case MuscleGroup.triceps:
        return TechnoColors.neonGreen;
      case MuscleGroup.quadriceps:
      case MuscleGroup.hamstrings:
      case MuscleGroup.glutes:
      case MuscleGroup.calves:
        return TechnoColors.neonOrange;
      case MuscleGroup.core:
        return TechnoColors.neonPink;
      case MuscleGroup.cardio:
      case MuscleGroup.fullBody:
        return TechnoColors.neonYellow;
      default:
        return TechnoColors.neonCyan;
    }
  }

  String get _difficultyLabel {
    switch (widget.exercise.difficulty) {
      case FitnessLevel.beginner:
        return 'BEGINNER';
      case FitnessLevel.intermediate:
        return 'INTERMEDIATE';
      case FitnessLevel.advanced:
        return 'ADVANCED';
    }
  }

  Color get _difficultyColor {
    switch (widget.exercise.difficulty) {
      case FitnessLevel.beginner:
        return TechnoColors.neonGreen;
      case FitnessLevel.intermediate:
        return TechnoColors.neonYellow;
      case FitnessLevel.advanced:
        return TechnoColors.neonPink;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    return NeonCard(
      borderColor: _muscleColor.withValues(alpha: 0.3),
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ────────────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ex.name,
                      style: GoogleFonts.rajdhani(
                        color: TechnoColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _MiniChip(
                            label: ex.primaryMuscle.label.toUpperCase(),
                            color: _muscleColor),
                        const SizedBox(width: 6),
                        _MiniChip(
                            label: _difficultyLabel,
                            color: _difficultyColor),
                        if (ex.isCompound) ...[
                          const SizedBox(width: 6),
                          _MiniChip(label: 'COMPOUND', color: TechnoColors.neonPurple),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.keyboard_arrow_down,
                    color: _muscleColor, size: 22),
              ),
            ],
          ),

          // ── Expanded details ──────────────────────────────────────────────
          if (_expanded) ...[
            const SizedBox(height: 12),
            Divider(color: _muscleColor.withValues(alpha: 0.2), height: 1),
            const SizedBox(height: 12),

            // Sets / reps / rest
            Row(
              children: [
                _StatPill(
                    label: 'SETS',
                    value: '${ex.defaultSets}',
                    color: _muscleColor),
                const SizedBox(width: 8),
                _StatPill(
                  label: ex.isTimeBased ? 'SECONDS' : 'REPS',
                  value: '${ex.defaultRepsOrSeconds}',
                  color: _muscleColor,
                ),
                const SizedBox(width: 8),
                _StatPill(
                    label: 'REST',
                    value: '${ex.restSeconds}s',
                    color: TechnoColors.textSecondary),
              ],
            ),
            const SizedBox(height: 10),

            // Instructions
            Text(
              'HOW TO',
              style: GoogleFonts.orbitron(
                  color: TechnoColors.textMuted,
                  fontSize: 9,
                  letterSpacing: 1.5),
            ),
            const SizedBox(height: 4),
            Text(
              ex.instructions,
              style: GoogleFonts.rajdhani(
                  color: TechnoColors.textSecondary,
                  fontSize: 13,
                  height: 1.4),
            ),

            // Tips
            if (ex.tips.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'TIP',
                style: GoogleFonts.orbitron(
                    color: TechnoColors.textMuted,
                    fontSize: 9,
                    letterSpacing: 1.5),
              ),
              const SizedBox(height: 4),
              Text(
                ex.tips,
                style: GoogleFonts.rajdhani(
                    color: _muscleColor.withValues(alpha: 0.85),
                    fontSize: 13,
                    height: 1.4),
              ),
            ],

            // Equipment
            const SizedBox(height: 10),
            Text(
              'EQUIPMENT',
              style: GoogleFonts.orbitron(
                  color: TechnoColors.textMuted,
                  fontSize: 9,
                  letterSpacing: 1.5),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: ex.requiredEquipment
                  .map((e) => _MiniChip(
                      label: e.label.toUpperCase(),
                      color: TechnoColors.textSecondary))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── PLANS TAB ────────────────────────────────────────────────────────────────

class _PlansTab extends StatelessWidget {
  const _PlansTab();

  @override
  Widget build(BuildContext context) {
    final categories = _PlanCategory.values;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: categories.expand((cat) {
        final plans = _kPlans.where((p) => p.category == cat).toList();
        return [
          _CategoryHeader(category: cat),
          const SizedBox(height: 10),
          ...plans.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _PlanCard(plan: p),
              )),
          const SizedBox(height: 16),
        ];
      }).toList(),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final _PlanCategory category;
  const _CategoryHeader({required this.category});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(category.emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Text(
          category.label,
          style: GoogleFonts.orbitron(
            color: category.color,
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Divider(color: category.color.withValues(alpha: 0.3)),
        ),
      ],
    );
  }
}

class _PlanCard extends StatefulWidget {
  final _WorkoutPlan plan;
  const _PlanCard({required this.plan});

  @override
  State<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends State<_PlanCard> {
  bool _expanded = false;

  List<Exercise> get _exercises {
    final lookup = {for (final e in kExercises) e.id: e};
    return widget.plan.exerciseIds
        .map((id) => lookup[id])
        .whereType<Exercise>()
        .toList();
  }

  void _startPlan(BuildContext context) {
    final provider = context.read<AppProvider>();
    if (provider.hasActiveWorkout) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Finish your current workout first!')),
      );
      return;
    }

    final exercises = _exercises.map((ex) {
      return WorkoutExerciseLog(
        exerciseId: ex.id,
        exerciseName: ex.name,
        primaryMuscle: ex.primaryMuscle,
        isTimeBased: ex.isTimeBased,
        sets: List.generate(
          ex.defaultSets,
          (_) => WorkoutSet(repsOrSeconds: ex.defaultRepsOrSeconds),
        ),
      );
    }).toList();

    provider.startWorkout(
      name: widget.plan.name,
      type: widget.plan.workoutType,
      isAtGym: provider.data.profile.preferGym,
      exercises: exercises,
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final color = plan.category.color;
    final exercises = _exercises;

    return NeonCard(
      borderColor: color.withValues(alpha: 0.35),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────────────────
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                Text(plan.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: GoogleFonts.rajdhani(
                          color: TechnoColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          _MiniChip(
                              label: '${exercises.length} EXERCISES',
                              color: color),
                          const SizedBox(width: 6),
                          _MiniChip(
                              label: '~${plan.estimatedMinutes} MIN',
                              color: TechnoColors.textSecondary),
                        ],
                      ),
                    ],
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(Icons.keyboard_arrow_down, color: color, size: 22),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),
          Text(
            plan.description,
            style: GoogleFonts.rajdhani(
                color: TechnoColors.textSecondary, fontSize: 13, height: 1.3),
          ),

          // ── Expanded exercise list + start button ─────────────────────────
          if (_expanded) ...[
            const SizedBox(height: 12),
            Divider(color: color.withValues(alpha: 0.2), height: 1),
            const SizedBox(height: 10),
            Text(
              'EXERCISES IN THIS PLAN',
              style: GoogleFonts.orbitron(
                  color: TechnoColors.textMuted, fontSize: 9, letterSpacing: 1.5),
            ),
            const SizedBox(height: 8),
            ...exercises.map((ex) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          ex.name,
                          style: GoogleFonts.rajdhani(
                            color: TechnoColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        '${ex.defaultSets}×${ex.defaultRepsOrSeconds}${ex.isTimeBased ? 's' : ''}',
                        style: GoogleFonts.rajdhani(
                          color: TechnoColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 14),
            NeonButton(
              label: 'START WORKOUT',
              icon: Icons.play_arrow,
              color: color,
              onTap: () => _startPlan(context),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: GoogleFonts.orbitron(color: color, fontSize: 8, letterSpacing: 1),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatPill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.orbitron(
                color: color, fontSize: 13, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: GoogleFonts.orbitron(
                color: color.withValues(alpha: 0.7), fontSize: 8, letterSpacing: 1),
          ),
        ],
      ),
    );
  }
}
