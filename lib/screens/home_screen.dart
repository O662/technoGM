import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../providers/step_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_card.dart';
import '../widgets/activity_rings_widget.dart';
import '../models/models.dart';
import '../services/workout_generator.dart';
import 'active_workout_screen.dart';
import 'exercises_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final data = provider.data;
    final streak = data.streak;
    final name = data.profile.name.isNotEmpty ? data.profile.name : 'Athlete';

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Header ──────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _Header(name: name),
              ),

              // ── Activity Rings ───────────────────────────────────────────────
              const SliverToBoxAdapter(
                child: ActivityRingsWidget(),
              ),

              // ── This Week ───────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: _ThisWeekCard(provider: provider),
                ),
              ),

              // ── Jump Right In ────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                  child: Text(
                    'JUMP RIGHT IN',
                    style: GoogleFonts.orbitron(
                      color: TechnoColors.textSecondary,
                      fontSize: 11,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _JumpRightInRow(provider: provider),
              ),

              // ── Quick Start (Cardio) ─────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: Text(
                    'QUICK START',
                    style: GoogleFonts.orbitron(
                      color: TechnoColors.textSecondary,
                      fontSize: 11,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _CardioRow(provider: provider),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ExercisesScreen()),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: TechnoColors.neonCyan.withValues(alpha: 0.5)),
                      foregroundColor: TechnoColors.neonCyan,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'BROWSE ALL EXERCISES',
                      style: GoogleFonts.orbitron(fontSize: 11, letterSpacing: 2),
                    ),
                  ),
                ),
              ),

              // ── Recent Workouts ──────────────────────────────────────────────
              if (data.workouts.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                    child: Text(
                      'RECENT',
                      style: GoogleFonts.orbitron(
                        color: TechnoColors.textSecondary,
                        fontSize: 11,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: _RecentWorkoutTile(workout: data.workouts[i]),
                    ),
                    childCount: data.workouts.length.clamp(0, 3),
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 140)),
            ],
          ),

          // ── Streak (floating, top-right) ─────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: _FlameIcon(streak: streak),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final String name;
  const _Header({required this.name});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    // Rotate through sayings daily so it feels fresh without being random each rebuild
    final daySeed = now.day;

    String pick(List<String> options) => options[daySeed % options.length];

    final String greeting;
    if (hour < 4) {
      greeting = pick([
        'BURNING THE LATE-NIGHT OIL?',
        'STILL UP OR JUST STARTING?',
        'THE CITY SLEEPS. YOU DON\'T.',
        'MIDNIGHT GRIND MODE',
        'BATMAN HOURS, LET\'S GO',
      ]);
    } else if (hour < 7) {
      greeting = pick([
        'HUNTING FOR WORMS ALREADY?',
        'FIRST ONE IN THE GYM',
        'THE EARLY BIRD GRINDS',
        'RISE AND GRIND',
      ]);
    } else if (hour < 12) {
      greeting = pick([
        'GOOD MORNING',
        'MORNING, CHAMPION',
        'READY TO CRUSH IT?',
        'LET\'S MAKE TODAY COUNT',
      ]);
    } else if (hour < 14) {
      greeting = pick([
        'PEAK PERFORMANCE HOURS',
        'LUNCHTIME LEGEND',
        'GOOD MIDDAY',
        'HALFWAY THERE',
      ]);
    } else if (hour < 17) {
      greeting = pick([
        'GOOD AFTERNOON',
        'AFTERNOON WARRIOR',
        'KEEP THAT MOMENTUM GOING',
        'AFTERNOON GRIND TIME',
      ]);
    } else if (hour < 20) {
      greeting = pick([
        'GOOD EVENING',
        'SUNSET SESSIONS HIT DIFFERENT',
        'FINISHING STRONG TODAY?',
        'EVENING GRIND, LET\'S GO',
      ]);
    } else {
      greeting = pick([
        'NIGHT MODE: ACTIVATED',
        'LATE SESSION INCOMING?',
        'NIGHT OWL ACTIVATED',
        'IF YOU\'RE UP, YOU MIGHT AS WELL BE TRAINING',
        'BURNING THE LATE-NIGHT OIL?',
        'BADASS NIGHT MODE ACTIVATED',
        'BATMAN HOURS, LET\'S GO',
      ]);
    }

    return Container(
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: GoogleFonts.orbitron(
              color: TechnoColors.neonCyan,
              fontSize: 11,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            name.toUpperCase(),
            style: GoogleFonts.orbitron(
              color: TechnoColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            DateFormat('EEEE, d MMMM').format(DateTime.now()).toUpperCase(),
            style: GoogleFonts.rajdhani(
              color: TechnoColors.textSecondary,
              fontSize: 13,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Flame Icon ────────────────────────────────────────────────────────────────

class _FlameIcon extends StatelessWidget {
  final StreakData streak;
  const _FlameIcon({required this.streak});

  @override
  Widget build(BuildContext context) {
    final count = streak.currentWeekStreak;
    final hasStreak = count > 0;

    final Color flameColor;
    if (!hasStreak) {
      flameColor = TechnoColors.textMuted;
    } else if (count >= 10) {
      flameColor = TechnoColors.neonPink;
    } else if (count >= 5) {
      flameColor = TechnoColors.neonOrange;
    } else {
      flameColor = TechnoColors.neonYellow;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          hasStreak
              ? Icons.local_fire_department
              : Icons.local_fire_department_outlined,
          color: flameColor,
          size: 40,
        ),
        Text(
          '$count',
          style: GoogleFonts.orbitron(
            color: flameColor,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ],
    );
  }
}

// ── This Week Card ────────────────────────────────────────────────────────────

class _ThisWeekCard extends StatelessWidget {
  final AppProvider provider;
  const _ThisWeekCard({required this.provider});

  @override
  Widget build(BuildContext context) {
    final sessions = provider.thisWeekSessions;
    final minutes = provider.thisWeekMinutes;
    final sessionGoal = provider.data.streak.weeklySessionGoal;
    final minuteGoal = provider.data.streak.weeklyMinutesGoal;
    final stepDaysGoal = provider.data.streak.weeklyStepDaysGoal;
    final sp = context.watch<ActivityRingsProvider>();
    final stepDays = sp.weeklyStepGoalDays ?? 0;

    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THIS WEEK',
            style: GoogleFonts.orbitron(
              color: TechnoColors.textSecondary,
              fontSize: 10,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatPill(
                value: '$sessions',
                label: 'SESSIONS',
                target: '$sessionGoal',
                color: TechnoColors.neonCyan,
                done: sessions >= sessionGoal,
              ),
              const SizedBox(width: 8),
              _StatPill(
                value: '$minutes',
                label: 'MINUTES',
                target: '$minuteGoal',
                color: TechnoColors.neonPurple,
                done: minutes >= minuteGoal,
              ),
              const SizedBox(width: 8),
              _StatPill(
                value: '$stepDays',
                label: 'STEP DAYS',
                target: '$stepDaysGoal',
                color: TechnoColors.neonGreen,
                done: stepDays >= stepDaysGoal,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  final String target;
  final Color color;
  final bool done;

  const _StatPill({
    required this.value,
    required this.label,
    required this.target,
    required this.color,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: done ? color : color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: GoogleFonts.orbitron(
                    color: color,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 4),
                  child: Text(
                    '/ $target',
                    style: GoogleFonts.rajdhani(
                      color: color.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              label,
              style: GoogleFonts.rajdhani(
                color: TechnoColors.textSecondary,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ── Jump Right In Row ─────────────────────────────────────────────────────────

class _JumpRightInRow extends StatelessWidget {
  final AppProvider provider;
  const _JumpRightInRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final level = provider.data.profile.fitnessLevel;
    final injuries = provider.data.profile.injuries;

    final quickStarts = [
      _QuickStart(
        label: 'Upper Body',
        icon: Icons.fitness_center,
        color: TechnoColors.neonCyan,
        exercises: () => WorkoutGenerator.quickUpperBody(level, injuries),
        type: WorkoutType.strength,
      ),
      _QuickStart(
        label: 'Lower Body',
        icon: Icons.directions_run,
        color: TechnoColors.neonPink,
        exercises: () => WorkoutGenerator.quickLowerBody(level, injuries),
        type: WorkoutType.strength,
      ),
      _QuickStart(
        label: 'HIIT Blast',
        icon: Icons.bolt,
        color: TechnoColors.neonYellow,
        exercises: () => WorkoutGenerator.quickHIIT(level, injuries),
        type: WorkoutType.hiit,
      ),
      _QuickStart(
        label: 'Core Burn',
        icon: Icons.rotate_right,
        color: TechnoColors.neonGreen,
        exercises: () => WorkoutGenerator.quickCore(level, injuries),
        type: WorkoutType.bodyweight,
      ),
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: quickStarts.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (ctx, i) => _QuickStartTile(
          qs: quickStarts[i],
          provider: provider,
        ),
      ),
    );
  }
}

// ── Cardio Row ────────────────────────────────────────────────────────────────

class _CardioRow extends StatelessWidget {
  final AppProvider provider;
  const _CardioRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final cardioOptions = [
      _QuickStart(
        label: 'Walking',
        icon: Icons.directions_walk,
        color: TechnoColors.neonGreen,
        exercises: () => [],
        type: WorkoutType.cardio,
      ),
      _QuickStart(
        label: 'Running',
        icon: Icons.directions_run,
        color: TechnoColors.neonCyan,
        exercises: () => [],
        type: WorkoutType.cardio,
      ),
      _QuickStart(
        label: 'Swimming',
        icon: Icons.pool,
        color: TechnoColors.neonPurple,
        exercises: () => [],
        type: WorkoutType.cardio,
      ),
      _QuickStart(
        label: 'Biking',
        icon: Icons.directions_bike,
        color: TechnoColors.neonOrange,
        exercises: () => [],
        type: WorkoutType.cardio,
      ),
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cardioOptions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (ctx, i) => _QuickStartTile(
          qs: cardioOptions[i],
          provider: provider,
        ),
      ),
    );
  }
}

class _QuickStart {
  final String label;
  final IconData icon;
  final Color color;
  final List<WorkoutExerciseLog> Function() exercises;
  final WorkoutType type;

  const _QuickStart({
    required this.label,
    required this.icon,
    required this.color,
    required this.exercises,
    required this.type,
  });
}

class _QuickStartTile extends StatelessWidget {
  final _QuickStart qs;
  final AppProvider provider;

  const _QuickStartTile({required this.qs, required this.provider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _launch(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: qs.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: qs.color.withValues(alpha: 0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(qs.icon, color: qs.color, size: 26),
            Text(
              qs.label.toUpperCase(),
              style: GoogleFonts.orbitron(
                color: qs.color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launch(BuildContext context) {
    if (provider.hasActiveWorkout) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Finish your current workout first!')),
      );
      return;
    }
    final exercises = qs.exercises();
    provider.startWorkout(
      name: qs.label,
      type: qs.type,
      isAtGym: provider.data.profile.preferGym,
      exercises: exercises,
    );
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
    );
  }
}

// ── Recent Workout Tile ───────────────────────────────────────────────────────

class _RecentWorkoutTile extends StatelessWidget {
  final CompletedWorkout workout;
  const _RecentWorkoutTile({required this.workout});

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: TechnoColors.neonCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: TechnoColors.neonCyan.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                workout.type.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.name,
                  style: GoogleFonts.rajdhani(
                    color: TechnoColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${workout.durationMinutes} min  •  ${workout.exercises.length} exercises',
                  style: GoogleFonts.rajdhani(
                    color: TechnoColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatDate(workout.startTime),
            style: GoogleFonts.rajdhani(
              color: TechnoColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return DateFormat('EEE d').format(d);
  }
}
