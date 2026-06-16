import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_card.dart';

// ── Workout History Card (public – shared with StatsScreen's History tab) ─────

class WorkoutHistoryCard extends StatefulWidget {
  final CompletedWorkout workout;
  final VoidCallback onDelete;

  const WorkoutHistoryCard({
    super.key,
    required this.workout,
    required this.onDelete,
  });

  @override
  State<WorkoutHistoryCard> createState() => _WorkoutHistoryCardState();
}

class _WorkoutHistoryCardState extends State<WorkoutHistoryCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final w = widget.workout;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: NeonCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Header
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: TechnoColors.neonCyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: TechnoColors.neonCyan.withValues(alpha: 0.3)),
                      ),
                      child: Center(
                        child: Text(w.type.emoji,
                            style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            w.name,
                            style: GoogleFonts.rajdhani(
                              color: TechnoColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            DateFormat('EEE, d MMM y').format(w.startTime),
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
                          '${w.durationMinutes} min',
                          style: GoogleFonts.orbitron(
                            color: TechnoColors.neonCyan,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              w.isAtGym ? Icons.location_on : Icons.home,
                              color: TechnoColors.textMuted,
                              size: 11,
                            ),
                            Text(
                              w.isAtGym ? 'Gym' : 'Home',
                              style: GoogleFonts.rajdhani(
                                color: TechnoColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: TechnoColors.textMuted,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            // Expanded details
            if (_expanded) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _QuickStat(
                          label: 'EXERCISES',
                          value: '${w.exercises.length}',
                          color: TechnoColors.neonCyan,
                        ),
                        _QuickStat(
                          label: 'SETS DONE',
                          value: '${w.totalSets}',
                          color: TechnoColors.neonPurple,
                        ),
                        _QuickStat(
                          label: 'CALORIES',
                          value: '~${w.caloriesBurned}',
                          color: TechnoColors.neonOrange,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...w.exercises.map(
                      (ex) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: TechnoColors.neonCyan,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              ex.exerciseName,
                              style: GoogleFonts.rajdhani(
                                color: TechnoColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            if (ex.sets.isNotEmpty)
                              Text(
                                '${ex.sets.length} × ${ex.sets.first.repsOrSeconds}${ex.isTimeBased ? "s" : ""}',
                                style: GoogleFonts.rajdhani(
                                  color: TechnoColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    if (w.notes.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        w.notes,
                        style: GoogleFonts.rajdhani(
                          color: TechnoColors.textMuted,
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: widget.onDelete,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.delete_outline,
                              color: TechnoColors.neonPink, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            'DELETE',
                            style: GoogleFonts.orbitron(
                              color: TechnoColors.neonPink,
                              fontSize: 11,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Quick Stat ────────────────────────────────────────────────────────────────

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _QuickStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.rajdhani(
              color: TechnoColors.textMuted,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
