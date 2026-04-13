import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_card.dart';

enum _SortOption { newest, oldest, longest, mostExercises }

extension on _SortOption {
  String get label {
    switch (this) {
      case _SortOption.newest:
        return 'Newest First';
      case _SortOption.oldest:
        return 'Oldest First';
      case _SortOption.longest:
        return 'Longest First';
      case _SortOption.mostExercises:
        return 'Most Exercises';
    }
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  WorkoutType? _typeFilter;
  bool? _gymFilter;
  int _dateFilter = 0; // 0=all, 1=this week, 2=this month, 3=last 3 months
  _SortOption _sort = _SortOption.newest;

  bool get _hasFilters =>
      _typeFilter != null || _gymFilter != null || _dateFilter != 0;

  List<CompletedWorkout> _apply(List<CompletedWorkout> workouts) {
    var result = workouts.toList();

    if (_typeFilter != null) {
      result = result.where((w) => w.type == _typeFilter).toList();
    }
    if (_gymFilter != null) {
      result = result.where((w) => w.isAtGym == _gymFilter).toList();
    }

    final now = DateTime.now();
    if (_dateFilter == 1) {
      final monday = now.subtract(Duration(days: now.weekday - 1));
      final start = DateTime(monday.year, monday.month, monday.day);
      result = result.where((w) => w.startTime.isAfter(start)).toList();
    } else if (_dateFilter == 2) {
      final start = DateTime(now.year, now.month, 1);
      result = result.where((w) => w.startTime.isAfter(start)).toList();
    } else if (_dateFilter == 3) {
      final start = DateTime(now.year, now.month - 3, now.day);
      result = result.where((w) => w.startTime.isAfter(start)).toList();
    }

    switch (_sort) {
      case _SortOption.newest:
        result.sort((a, b) => b.startTime.compareTo(a.startTime));
      case _SortOption.oldest:
        result.sort((a, b) => a.startTime.compareTo(b.startTime));
      case _SortOption.longest:
        result.sort(
            (a, b) => b.durationMinutes.compareTo(a.durationMinutes));
      case _SortOption.mostExercises:
        result.sort(
            (a, b) => b.exercises.length.compareTo(a.exercises.length));
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final filtered = _apply(provider.data.workouts);

    return Scaffold(
      appBar: AppBar(
        title: const Text('WORKOUTS'),
        actions: [
          PopupMenuButton<_SortOption>(
            icon: const Icon(Icons.sort, color: TechnoColors.neonCyan),
            tooltip: 'Sort',
            onSelected: (v) => setState(() => _sort = v),
            itemBuilder: (_) => _SortOption.values
                .map((v) => PopupMenuItem(value: v, child: Text(v.label)))
                .toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter Bar ────────────────────────────────────────────────────
          Container(
            color: TechnoColors.bgSecondary,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1: Type
                SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _Chip(
                        label: 'All Types',
                        selected: _typeFilter == null,
                        color: TechnoColors.neonCyan,
                        onTap: () => setState(() => _typeFilter = null),
                      ),
                      ...WorkoutType.values.map(
                        (t) => _Chip(
                          label: t.label,
                          selected: _typeFilter == t,
                          color: TechnoColors.neonCyan,
                          onTap: () => setState(() => _typeFilter = t),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // Row 2: Location + Date
                SizedBox(
                  height: 32,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _Chip(
                        label: 'All',
                        selected: _gymFilter == null,
                        color: TechnoColors.neonPurple,
                        onTap: () => setState(() => _gymFilter = null),
                      ),
                      _Chip(
                        label: 'Gym',
                        selected: _gymFilter == true,
                        color: TechnoColors.neonPurple,
                        onTap: () => setState(() => _gymFilter = true),
                      ),
                      _Chip(
                        label: 'Home',
                        selected: _gymFilter == false,
                        color: TechnoColors.neonPurple,
                        onTap: () => setState(() => _gymFilter = false),
                      ),
                      const _ChipDivider(),
                      _Chip(
                        label: 'All Time',
                        selected: _dateFilter == 0,
                        color: TechnoColors.neonGreen,
                        onTap: () => setState(() => _dateFilter = 0),
                      ),
                      _Chip(
                        label: 'This Week',
                        selected: _dateFilter == 1,
                        color: TechnoColors.neonGreen,
                        onTap: () => setState(() => _dateFilter = 1),
                      ),
                      _Chip(
                        label: 'This Month',
                        selected: _dateFilter == 2,
                        color: TechnoColors.neonGreen,
                        onTap: () => setState(() => _dateFilter = 2),
                      ),
                      _Chip(
                        label: '3 Months',
                        selected: _dateFilter == 3,
                        color: TechnoColors.neonGreen,
                        onTap: () => setState(() => _dateFilter = 3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // ── Results Count ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                Text(
                  '${filtered.length} WORKOUT${filtered.length == 1 ? '' : 'S'}',
                  style: GoogleFonts.orbitron(
                    color: TechnoColors.textMuted,
                    fontSize: 10,
                    letterSpacing: 1.5,
                  ),
                ),
                if (_hasFilters) ...[
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() {
                      _typeFilter = null;
                      _gymFilter = null;
                      _dateFilter = 0;
                    }),
                    child: Text(
                      'CLEAR',
                      style: GoogleFonts.orbitron(
                        color: TechnoColors.neonCyan,
                        fontSize: 10,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // ── List ──────────────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? _EmptyState(hasFilters: _hasFilters)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => WorkoutHistoryCard(
                      workout: filtered[i],
                      onDelete: () =>
                          _confirmDelete(context, provider, filtered[i].id),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AppProvider provider,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'DELETE?',
          style: GoogleFonts.orbitron(color: TechnoColors.neonPink, fontSize: 14),
        ),
        content: const Text('Remove this workout from history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('DELETE', style: TextStyle(color: TechnoColors.neonPink)),
          ),
        ],
      ),
    );
    if (confirmed == true) provider.deleteWorkout(id);
  }
}

// ── Filter Chip ───────────────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: selected ? color.withValues(alpha: 0.18) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? color : TechnoColors.cardBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.rajdhani(
              color: selected ? color : TechnoColors.textMuted,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipDivider extends StatelessWidget {
  const _ChipDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.fromLTRB(8, 6, 14, 6),
      color: TechnoColors.cardBorder,
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final bool hasFilters;
  const _EmptyState({required this.hasFilters});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            hasFilters ? Icons.filter_list_off : Icons.fitness_center,
            color: TechnoColors.textMuted,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'NO WORKOUTS MATCH' : 'NO WORKOUTS YET',
            style: GoogleFonts.orbitron(
              color: TechnoColors.textMuted,
              fontSize: 14,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasFilters
                ? 'Try different filters'
                : 'Complete your first workout to see it here',
            style: GoogleFonts.rajdhani(color: TechnoColors.textMuted, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

// ── Workout History Card (public – shared with StatsScreen) ───────────────────

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
