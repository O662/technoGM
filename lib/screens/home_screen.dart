import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_card.dart';
import '../models/models.dart';
import '../services/workout_generator.dart';
import 'active_workout_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final data = provider.data;
    final streak = data.streak;
    final name = data.profile.name.isNotEmpty ? data.profile.name : 'Athlete';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _Header(name: name),
          ),

          // ── Streak Banner ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _StreakBanner(provider: provider, streak: streak),
            ),
          ),

          // ── This Week ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: _ThisWeekCard(provider: provider),
            ),
          ),

          // ── Quick Start ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _QuickStartGrid(provider: provider),
            ),
          ),

          // ── Recent Workouts ───────────────────────────────────────────────
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

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'MORNING' : hour < 17 ? 'AFTERNOON' : 'EVENING';

    return Container(
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 16, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GOOD $greeting',
            style: GoogleFonts.orbitron(
              color: TechnoColors.neonCyan,
              fontSize: 11,
              letterSpacing: 3,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name.toUpperCase(),
            style: GoogleFonts.orbitron(
              color: TechnoColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 2),
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

// ── Streak Banner ─────────────────────────────────────────────────────────────

class _StreakBanner extends StatelessWidget {
  final AppProvider provider;
  final StreakData streak;

  const _StreakBanner({required this.provider, required this.streak});

  @override
  Widget build(BuildContext context) {
    final weekComplete = provider.thisWeekComplete;
    final accentColor = weekComplete ? TechnoColors.neonGreen : TechnoColors.neonYellow;

    return NeonCard(
      borderColor: accentColor,
      backgroundColor: TechnoColors.cardBg,
      child: Row(
        children: [
          // Streak number
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '${streak.currentWeekStreak}',
                    style: GoogleFonts.orbitron(
                      color: accentColor,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WEEK',
                        style: GoogleFonts.orbitron(
                          color: accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'STREAK',
                        style: GoogleFonts.orbitron(
                          color: accentColor.withValues(alpha: 0.7),
                          fontSize: 10,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                'BEST: ${streak.bestWeekStreak} WEEKS',
                style: GoogleFonts.rajdhani(
                  color: TechnoColors.textMuted,
                  fontSize: 12,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                weekComplete ? Icons.verified : Icons.timer_outlined,
                color: accentColor,
                size: 32,
              ),
              const SizedBox(height: 4),
              Text(
                weekComplete ? 'WEEK LOCKED IN!' : 'IN PROGRESS',
                style: GoogleFonts.orbitron(
                  color: accentColor,
                  fontSize: 10,
                  letterSpacing: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
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
              const SizedBox(width: 12),
              _StatPill(
                value: '$minutes',
                label: 'MINUTES',
                target: '$minuteGoal',
                color: TechnoColors.neonPurple,
                done: minutes >= minuteGoal,
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

// ── Quick Start Grid ──────────────────────────────────────────────────────────

class _QuickStartGrid extends StatelessWidget {
  final AppProvider provider;
  const _QuickStartGrid({required this.provider});

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

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemCount: quickStarts.length,
      itemBuilder: (ctx, i) => _QuickStartTile(
        qs: quickStarts[i],
        provider: provider,
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
