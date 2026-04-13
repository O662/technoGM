import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_card.dart';
import '../data/exercise_database.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late Timer _timer;
  Duration _elapsed = Duration.zero;
  DateTime? _restStart;
  int _restSeconds = 0;
  Timer? _restTimer;

  @override
  void initState() {
    super.initState();
    final provider = context.read<AppProvider>();
    final start = provider.activeWorkout?.startTime ?? DateTime.now();
    _elapsed = DateTime.now().difference(start);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  void _startRest(int seconds) {
    _restTimer?.cancel();
    setState(() {
      _restStart = DateTime.now();
      _restSeconds = seconds;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = _restSeconds - DateTime.now().difference(_restStart!).inSeconds;
      if (remaining <= 0) {
        _restTimer?.cancel();
        setState(() {
          _restStart = null;
          _restSeconds = 0;
        });
      } else {
        setState(() {});
      }
    });
  }

  int get _restRemaining {
    if (_restStart == null) return 0;
    final r = _restSeconds - DateTime.now().difference(_restStart!).inSeconds;
    return r.clamp(0, _restSeconds);
  }

  String _fmtDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final workout = provider.activeWorkout;
    if (workout == null) {
      Navigator.of(context).pop();
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: TechnoColors.bgPrimary,
      body: Column(
        children: [
          // ── Top Bar ────────────────────────────────────────────────────────
          _TopBar(
            workout: workout,
            elapsed: _elapsed,
            fmtDuration: _fmtDuration,
            onFinish: () => _confirmFinish(context, provider),
            onCancel: () => _confirmCancel(context, provider),
          ),

          // ── Rest Timer ────────────────────────────────────────────────────
          if (_restStart != null)
            _RestBanner(remaining: _restRemaining, total: _restSeconds),

          // ── Exercises ─────────────────────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: workout.exercises.length,
              itemBuilder: (ctx, i) {
                final ex = workout.exercises[i];
                final dbEx = kExercises.firstWhere(
                  (e) => e.id == ex.exerciseId,
                  orElse: () => kExercises.first,
                );
                return _ExerciseCard(
                  log: ex,
                  dbExercise: dbEx,
                  onUpdate: (updated) => provider.updateActiveExercise(i, updated),
                  onSetCompleted: () => _startRest(dbEx.restSeconds),
                  onRemove: () => provider.removeExerciseFromActive(i),
                );
              },
            ),
          ),
        ],
      ),

      // ── Add Exercise FAB ───────────────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: TechnoColors.bgTertiary,
        foregroundColor: TechnoColors.neonCyan,
        icon: const Icon(Icons.add),
        label: Text(
          'ADD EXERCISE',
          style: GoogleFonts.orbitron(fontSize: 11, letterSpacing: 1),
        ),
        onPressed: () => _showAddExercise(context, provider),
      ),
    );
  }

  Future<void> _confirmFinish(BuildContext context, AppProvider provider) async {
    final notesController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'FINISH WORKOUT',
          style: GoogleFonts.orbitron(color: TechnoColors.neonGreen, fontSize: 14),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Great work! Time: ${_fmtDuration(_elapsed)}',
              style: GoogleFonts.rajdhani(color: TechnoColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                hintText: 'Add notes (optional)',
                labelText: 'Notes',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'FINISH',
              style: TextStyle(color: TechnoColors.neonGreen),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await provider.finishWorkout(notes: notesController.text);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _confirmCancel(BuildContext context, AppProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'CANCEL WORKOUT?',
          style: GoogleFonts.orbitron(color: TechnoColors.neonPink, fontSize: 14),
        ),
        content: Text(
          'Progress will be lost.',
          style: GoogleFonts.rajdhani(color: TechnoColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('KEEP GOING'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('CANCEL', style: TextStyle(color: TechnoColors.neonPink)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      provider.cancelWorkout();
      Navigator.of(context).pop();
    }
  }

  Future<void> _showAddExercise(BuildContext context, AppProvider provider) async {
    final selected = await showModalBottomSheet<Exercise>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const _AddExerciseSheet(),
    );
    if (selected != null) {
      provider.addExerciseToActive(WorkoutExerciseLog(
        exerciseId: selected.id,
        exerciseName: selected.name,
        primaryMuscle: selected.primaryMuscle,
        isTimeBased: selected.isTimeBased,
        sets: List.generate(
          selected.defaultSets,
          (_) => WorkoutSet(repsOrSeconds: selected.defaultRepsOrSeconds),
        ),
      ));
    }
  }
}

// ── Top Bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final ActiveWorkout workout;
  final Duration elapsed;
  final String Function(Duration) fmtDuration;
  final VoidCallback onFinish;
  final VoidCallback onCancel;

  const _TopBar({
    required this.workout,
    required this.elapsed,
    required this.fmtDuration,
    required this.onFinish,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, MediaQuery.of(context).padding.top + 12, 16, 16),
      decoration: const BoxDecoration(
        color: TechnoColors.bgSecondary,
        border: Border(bottom: BorderSide(color: TechnoColors.cardBorder)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onCancel,
            icon: const Icon(Icons.close, color: TechnoColors.neonPink),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.name.toUpperCase(),
                  style: GoogleFonts.orbitron(
                    color: TechnoColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Icon(
                      workout.isAtGym ? Icons.location_on : Icons.home,
                      color: TechnoColors.textMuted,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      workout.isAtGym ? 'Gym' : 'Home',
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
          // Timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: TechnoColors.neonCyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: TechnoColors.neonCyan.withValues(alpha: 0.4)),
            ),
            child: Text(
              fmtDuration(elapsed),
              style: GoogleFonts.orbitron(
                color: TechnoColors.neonCyan,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onFinish,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: TechnoColors.neonGreen,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'DONE',
                style: GoogleFonts.orbitron(
                  color: TechnoColors.bgPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Rest Banner ───────────────────────────────────────────────────────────────

class _RestBanner extends StatelessWidget {
  final int remaining;
  final int total;
  const _RestBanner({required this.remaining, required this.total});

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? remaining / total : 0.0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: TechnoColors.neonYellow.withValues(alpha: 0.08),
      child: Row(
        children: [
          const Icon(Icons.timer, color: TechnoColors.neonYellow, size: 16),
          const SizedBox(width: 8),
          Text(
            'REST: ${remaining}s',
            style: GoogleFonts.orbitron(
              color: TechnoColors.neonYellow,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.toDouble(),
                backgroundColor: TechnoColors.cardBorder,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(TechnoColors.neonYellow),
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Exercise Card ─────────────────────────────────────────────────────────────

class _ExerciseCard extends StatefulWidget {
  final WorkoutExerciseLog log;
  final Exercise dbExercise;
  final ValueChanged<WorkoutExerciseLog> onUpdate;
  final VoidCallback onSetCompleted;
  final VoidCallback onRemove;

  const _ExerciseCard({
    required this.log,
    required this.dbExercise,
    required this.onUpdate,
    required this.onSetCompleted,
    required this.onRemove,
  });

  @override
  State<_ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<_ExerciseCard> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final completedSets = widget.log.sets.where((s) => s.completed).length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: NeonCard(
        padding: const EdgeInsets.all(0),
        borderColor: completedSets == widget.log.sets.length
            ? TechnoColors.neonGreen.withValues(alpha: 0.5)
            : TechnoColors.cardBorder,
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.log.exerciseName,
                            style: GoogleFonts.rajdhani(
                              color: TechnoColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            widget.log.primaryMuscle.label,
                            style: GoogleFonts.rajdhani(
                              color: TechnoColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$completedSets/${widget.log.sets.length}',
                      style: GoogleFonts.orbitron(
                        color: completedSets == widget.log.sets.length
                            ? TechnoColors.neonGreen
                            : TechnoColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      color: TechnoColors.textMuted,
                    ),
                    IconButton(
                      onPressed: widget.onRemove,
                      icon: const Icon(Icons.delete_outline, color: TechnoColors.textMuted, size: 18),
                    ),
                  ],
                ),
              ),
            ),

            // Instructions
            if (_expanded && widget.dbExercise.instructions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                child: Text(
                  widget.dbExercise.instructions,
                  style: GoogleFonts.rajdhani(
                    color: TechnoColors.textMuted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),

            // Sets
            if (_expanded) ...[
              // Header row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    SizedBox(
                      width: 32,
                      child: Text('SET', style: _headerStyle),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 80,
                      child: Text(
                        widget.log.isTimeBased ? 'SECONDS' : 'KG',
                        style: _headerStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 80,
                      child: Text(
                        widget.log.isTimeBased ? 'ROUNDS' : 'REPS',
                        style: _headerStyle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              ...List.generate(widget.log.sets.length, (i) {
                return _SetRow(
                  setNum: i + 1,
                  set: widget.log.sets[i],
                  isTimeBased: widget.log.isTimeBased,
                  onChanged: (updated) {
                    final newSets = List<WorkoutSet>.from(widget.log.sets);
                    final wasCompleted = newSets[i].completed;
                    newSets[i] = updated;
                    widget.onUpdate(WorkoutExerciseLog(
                      exerciseId: widget.log.exerciseId,
                      exerciseName: widget.log.exerciseName,
                      primaryMuscle: widget.log.primaryMuscle,
                      isTimeBased: widget.log.isTimeBased,
                      sets: newSets,
                      notes: widget.log.notes,
                    ));
                    if (!wasCompleted && updated.completed) {
                      widget.onSetCompleted();
                    }
                  },
                  onAddSet: i == widget.log.sets.length - 1 ? _addSet : null,
                );
              }),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }

  TextStyle get _headerStyle => GoogleFonts.orbitron(
    color: TechnoColors.textMuted,
    fontSize: 9,
    letterSpacing: 1,
  );

  void _addSet() {
    final lastSet = widget.log.sets.last;
    final newSets = [
      ...widget.log.sets,
      WorkoutSet(
        weight: lastSet.weight,
        repsOrSeconds: lastSet.repsOrSeconds,
      ),
    ];
    widget.onUpdate(WorkoutExerciseLog(
      exerciseId: widget.log.exerciseId,
      exerciseName: widget.log.exerciseName,
      primaryMuscle: widget.log.primaryMuscle,
      isTimeBased: widget.log.isTimeBased,
      sets: newSets,
      notes: widget.log.notes,
    ));
  }
}

// ── Set Row ───────────────────────────────────────────────────────────────────

class _SetRow extends StatefulWidget {
  final int setNum;
  final WorkoutSet set;
  final bool isTimeBased;
  final ValueChanged<WorkoutSet> onChanged;
  final VoidCallback? onAddSet;

  const _SetRow({
    required this.setNum,
    required this.set,
    required this.isTimeBased,
    required this.onChanged,
    this.onAddSet,
  });

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late TextEditingController _weightCtrl;
  late TextEditingController _repsCtrl;

  @override
  void initState() {
    super.initState();
    _weightCtrl = TextEditingController(
      text: widget.set.weight == 0 ? '' : widget.set.weight.toStringAsFixed(widget.set.weight % 1 == 0 ? 0 : 1),
    );
    _repsCtrl = TextEditingController(text: '${widget.set.repsOrSeconds}');
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    super.dispose();
  }

  void _notify() {
    final weight = double.tryParse(_weightCtrl.text) ?? 0;
    final reps = int.tryParse(_repsCtrl.text) ?? widget.set.repsOrSeconds;
    widget.onChanged(WorkoutSet(
      weight: weight,
      repsOrSeconds: reps,
      completed: widget.set.completed,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isComplete = widget.set.completed;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 2, 14, 2),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: isComplete ? TechnoColors.neonGreen.withValues(alpha: 0.06) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Set number
          SizedBox(
            width: 24,
            child: Text(
              '${widget.setNum}',
              style: GoogleFonts.orbitron(
                color: isComplete ? TechnoColors.neonGreen : TechnoColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const Spacer(),
          // Weight field (not shown for time-based)
          if (!widget.isTimeBased) ...[
            SizedBox(
              width: 80,
              child: _NumberField(
                controller: _weightCtrl,
                hint: 'BW',
                onChanged: (_) => _notify(),
                enabled: !isComplete,
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Reps/seconds field
          SizedBox(
            width: widget.isTimeBased ? 80 : 80,
            child: _NumberField(
              controller: _repsCtrl,
              hint: widget.isTimeBased ? 'sec' : 'reps',
              onChanged: (_) => _notify(),
              enabled: !isComplete,
            ),
          ),
          const SizedBox(width: 8),
          // Complete toggle
          GestureDetector(
            onTap: () {
              final weight = double.tryParse(_weightCtrl.text) ?? 0;
              final reps = int.tryParse(_repsCtrl.text) ?? widget.set.repsOrSeconds;
              widget.onChanged(WorkoutSet(
                weight: weight,
                repsOrSeconds: reps,
                completed: !isComplete,
              ));
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isComplete ? TechnoColors.neonGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isComplete ? TechnoColors.neonGreen : TechnoColors.cardBorder,
                  width: 1.5,
                ),
              ),
              child: isComplete
                  ? const Icon(Icons.check, color: TechnoColors.bgPrimary, size: 18)
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const _NumberField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      enabled: enabled,
      style: GoogleFonts.orbitron(
        color: enabled ? TechnoColors.textPrimary : TechnoColors.textMuted,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        isDense: true,
        fillColor: TechnoColors.bgSecondary,
      ),
      onChanged: onChanged,
    );
  }
}

// ── Add Exercise Sheet ────────────────────────────────────────────────────────

class _AddExerciseSheet extends StatefulWidget {
  const _AddExerciseSheet();

  @override
  State<_AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<_AddExerciseSheet> {
  String _search = '';
  MuscleGroup? _filterMuscle;

  List<Exercise> get _filtered {
    var list = kExercises.toList();
    if (_filterMuscle != null) {
      list = list.where((e) => e.primaryMuscle == _filterMuscle).toList();
    }
    if (_search.isNotEmpty) {
      list = list
          .where((e) => e.name.toLowerCase().contains(_search.toLowerCase()))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (ctx, controller) => Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: TechnoColors.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Text(
              'ADD EXERCISE',
              style: GoogleFonts.orbitron(
                color: TechnoColors.neonCyan,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search exercises...',
                prefixIcon: Icon(Icons.search, color: TechnoColors.textMuted),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          const SizedBox(height: 8),
          // Muscle filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filterMuscle == null,
                  onTap: () => setState(() => _filterMuscle = null),
                ),
                ...MuscleGroup.values.map((m) => _FilterChip(
                  label: m.label,
                  selected: _filterMuscle == m,
                  onTap: () => setState(() => _filterMuscle = _filterMuscle == m ? null : m),
                )),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: _filtered.length,
              itemBuilder: (ctx, i) {
                final ex = _filtered[i];
                return ListTile(
                  title: Text(
                    ex.name,
                    style: GoogleFonts.rajdhani(
                      color: TechnoColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    ex.primaryMuscle.label,
                    style: GoogleFonts.rajdhani(
                      color: TechnoColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  trailing: const Icon(Icons.add, color: TechnoColors.neonCyan),
                  onTap: () => Navigator.pop(ctx, ex),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? TechnoColors.neonCyan.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? TechnoColors.neonCyan : TechnoColors.cardBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.rajdhani(
            color: selected ? TechnoColors.neonCyan : TechnoColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
