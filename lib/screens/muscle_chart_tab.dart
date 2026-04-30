import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../data/exercise_database.dart';
import '../theme/app_theme.dart';

// ─── Coordinate space: 200 × 400 units ───────────────────────────────────────
const double _kW = 200.0;
const double _kH = 400.0;

// ─── Muscle Region ────────────────────────────────────────────────────────────

class _Region {
  const _Region({
    required this.muscle,
    required this.path,
    required this.color,
    required this.labelAt,
  });
  final MuscleGroup muscle;
  final Path path;
  final Color color;
  final Offset labelAt;
}

// ─── Path helpers ─────────────────────────────────────────────────────────────

Path _oval(double cx, double cy, double rx, double ry) =>
    Path()..addOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2));

// ─── Front regions ────────────────────────────────────────────────────────────

final List<_Region> _frontRegions = [
  _Region(
    muscle: MuscleGroup.chest,
    path: () {
      final p = Path();
      p.moveTo(65, 60);
      p.quadraticBezierTo(65, 57, 97, 57);
      p.lineTo(97, 97);
      p.quadraticBezierTo(78, 102, 63, 93);
      p.quadraticBezierTo(61, 76, 65, 60);
      p.close();
      return p;
    }(),
    color: TechnoColors.neonCyan,
    labelAt: const Offset(78, 75),
  ),
  _Region(
    muscle: MuscleGroup.chest,
    path: () {
      final p = Path();
      p.moveTo(135, 60);
      p.quadraticBezierTo(135, 57, 103, 57);
      p.lineTo(103, 97);
      p.quadraticBezierTo(122, 102, 137, 93);
      p.quadraticBezierTo(139, 76, 135, 60);
      p.close();
      return p;
    }(),
    color: TechnoColors.neonCyan,
    labelAt: const Offset(122, 75),
  ),
  _Region(
    muscle: MuscleGroup.shoulders,
    path: _oval(46, 71, 23, 17),
    color: TechnoColors.neonYellow,
    labelAt: const Offset(46, 71),
  ),
  _Region(
    muscle: MuscleGroup.shoulders,
    path: _oval(154, 71, 23, 17),
    color: TechnoColors.neonYellow,
    labelAt: const Offset(154, 71),
  ),
  _Region(
    muscle: MuscleGroup.biceps,
    path: _oval(33, 118, 14, 31),
    color: TechnoColors.neonGreen,
    labelAt: const Offset(33, 118),
  ),
  _Region(
    muscle: MuscleGroup.biceps,
    path: _oval(167, 118, 14, 31),
    color: TechnoColors.neonGreen,
    labelAt: const Offset(167, 118),
  ),
  _Region(
    muscle: MuscleGroup.forearms,
    path: _oval(24, 170, 12, 27),
    color: const Color(0xFF80FFB0),
    labelAt: const Offset(24, 170),
  ),
  _Region(
    muscle: MuscleGroup.forearms,
    path: _oval(176, 170, 12, 27),
    color: const Color(0xFF80FFB0),
    labelAt: const Offset(176, 170),
  ),
  _Region(
    muscle: MuscleGroup.core,
    path: () {
      final p = Path();
      p.addRRect(RRect.fromRectAndRadius(
        const Rect.fromLTWH(82, 98, 36, 66),
        const Radius.circular(7),
      ));
      return p;
    }(),
    color: TechnoColors.neonPink,
    labelAt: const Offset(100, 131),
  ),
  _Region(
    muscle: MuscleGroup.core,
    path: () {
      final p = Path();
      p.moveTo(63, 100);
      p.lineTo(81, 100);
      p.lineTo(78, 163);
      p.lineTo(60, 163);
      p.close();
      return p;
    }(),
    color: TechnoColors.neonPink,
    labelAt: const Offset(71, 131),
  ),
  _Region(
    muscle: MuscleGroup.core,
    path: () {
      final p = Path();
      p.moveTo(137, 100);
      p.lineTo(119, 100);
      p.lineTo(122, 163);
      p.lineTo(140, 163);
      p.close();
      return p;
    }(),
    color: TechnoColors.neonPink,
    labelAt: const Offset(129, 131),
  ),
  _Region(
    muscle: MuscleGroup.quadriceps,
    path: _oval(79, 252, 25, 47),
    color: TechnoColors.neonOrange,
    labelAt: const Offset(79, 252),
  ),
  _Region(
    muscle: MuscleGroup.quadriceps,
    path: _oval(121, 252, 25, 47),
    color: TechnoColors.neonOrange,
    labelAt: const Offset(121, 252),
  ),
  _Region(
    muscle: MuscleGroup.calves,
    path: _oval(75, 346, 17, 30),
    color: TechnoColors.neonYellow,
    labelAt: const Offset(75, 346),
  ),
  _Region(
    muscle: MuscleGroup.calves,
    path: _oval(125, 346, 17, 30),
    color: TechnoColors.neonYellow,
    labelAt: const Offset(125, 346),
  ),
];

// ─── Back regions ─────────────────────────────────────────────────────────────

final List<_Region> _backRegions = [
  _Region(
    muscle: MuscleGroup.back,
    path: () {
      final p = Path();
      p.moveTo(100, 58);
      p.lineTo(63, 58);
      p.quadraticBezierTo(42, 72, 48, 93);
      p.lineTo(76, 107);
      p.lineTo(100, 100);
      p.close();
      return p;
    }(),
    color: TechnoColors.neonPurple,
    labelAt: const Offset(72, 80),
  ),
  _Region(
    muscle: MuscleGroup.back,
    path: () {
      final p = Path();
      p.moveTo(100, 58);
      p.lineTo(137, 58);
      p.quadraticBezierTo(158, 72, 152, 93);
      p.lineTo(124, 107);
      p.lineTo(100, 100);
      p.close();
      return p;
    }(),
    color: TechnoColors.neonPurple,
    labelAt: const Offset(128, 80),
  ),
  _Region(
    muscle: MuscleGroup.back,
    path: () {
      final p = Path();
      p.moveTo(55, 110);
      p.lineTo(80, 172);
      p.lineTo(100, 172);
      p.lineTo(100, 108);
      p.quadraticBezierTo(78, 100, 55, 110);
      p.close();
      return p;
    }(),
    color: TechnoColors.neonPurple,
    labelAt: const Offset(75, 142),
  ),
  _Region(
    muscle: MuscleGroup.back,
    path: () {
      final p = Path();
      p.moveTo(145, 110);
      p.lineTo(120, 172);
      p.lineTo(100, 172);
      p.lineTo(100, 108);
      p.quadraticBezierTo(122, 100, 145, 110);
      p.close();
      return p;
    }(),
    color: TechnoColors.neonPurple,
    labelAt: const Offset(125, 142),
  ),
  _Region(
    muscle: MuscleGroup.shoulders,
    path: _oval(44, 74, 22, 17),
    color: TechnoColors.neonYellow,
    labelAt: const Offset(44, 74),
  ),
  _Region(
    muscle: MuscleGroup.shoulders,
    path: _oval(156, 74, 22, 17),
    color: TechnoColors.neonYellow,
    labelAt: const Offset(156, 74),
  ),
  _Region(
    muscle: MuscleGroup.triceps,
    path: _oval(31, 120, 15, 32),
    color: TechnoColors.neonGreen,
    labelAt: const Offset(31, 120),
  ),
  _Region(
    muscle: MuscleGroup.triceps,
    path: _oval(169, 120, 15, 32),
    color: TechnoColors.neonGreen,
    labelAt: const Offset(169, 120),
  ),
  _Region(
    muscle: MuscleGroup.forearms,
    path: _oval(24, 170, 12, 27),
    color: const Color(0xFF80FFB0),
    labelAt: const Offset(24, 170),
  ),
  _Region(
    muscle: MuscleGroup.forearms,
    path: _oval(176, 170, 12, 27),
    color: const Color(0xFF80FFB0),
    labelAt: const Offset(176, 170),
  ),
  _Region(
    muscle: MuscleGroup.glutes,
    path: _oval(82, 203, 28, 28),
    color: TechnoColors.neonOrange,
    labelAt: const Offset(82, 203),
  ),
  _Region(
    muscle: MuscleGroup.glutes,
    path: _oval(118, 203, 28, 28),
    color: TechnoColors.neonOrange,
    labelAt: const Offset(118, 203),
  ),
  _Region(
    muscle: MuscleGroup.hamstrings,
    path: _oval(80, 272, 24, 45),
    color: const Color(0xFFFF9030),
    labelAt: const Offset(80, 272),
  ),
  _Region(
    muscle: MuscleGroup.hamstrings,
    path: _oval(120, 272, 24, 45),
    color: const Color(0xFFFF9030),
    labelAt: const Offset(120, 272),
  ),
  _Region(
    muscle: MuscleGroup.calves,
    path: _oval(75, 348, 17, 30),
    color: TechnoColors.neonYellow,
    labelAt: const Offset(75, 348),
  ),
  _Region(
    muscle: MuscleGroup.calves,
    path: _oval(125, 348, 17, 30),
    color: TechnoColors.neonYellow,
    labelAt: const Offset(125, 348),
  ),
];

// ─── Body Painter ─────────────────────────────────────────────────────────────

class _BodyPainter extends CustomPainter {
  _BodyPainter({required this.regions, required this.selected, required this.isFront});

  final List<_Region> regions;
  final MuscleGroup? selected;
  final bool isFront;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / _kW;
    final sy = size.height / _kH;
    final m = Matrix4.diagonal3Values(sx, sy, 1.0).storage;

    Path s(Path p) => p.transform(m);

    _paintBase(canvas, s, isFront);

    for (final r in regions) {
      final sp = s(r.path);
      final isHit = r.muscle == selected;

      if (isHit) {
        canvas.drawPath(
          sp,
          Paint()
            ..style = PaintingStyle.fill
            ..color = r.color.withValues(alpha: 0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
        );
        canvas.drawPath(sp, Paint()..style = PaintingStyle.fill..color = r.color.withValues(alpha: 0.65));
        canvas.drawPath(sp, Paint()..style = PaintingStyle.stroke..color = r.color..strokeWidth = 2.0);
      } else {
        canvas.drawPath(sp, Paint()..style = PaintingStyle.fill..color = r.color.withValues(alpha: 0.10));
        canvas.drawPath(
          sp,
          Paint()..style = PaintingStyle.stroke..color = r.color.withValues(alpha: 0.35)..strokeWidth = 1.0,
        );
      }
    }

    // Label dot on each unique selected region center
    if (selected != null) {
      final seen = <Offset>{};
      for (final r in regions) {
        if (r.muscle != selected) continue;
        final c = Offset(r.labelAt.dx * sx, r.labelAt.dy * sy);
        if (seen.any((o) => (o - c).distance < 5)) continue;
        seen.add(c);
        canvas.drawCircle(c, 4 * sx.clamp(0.8, 1.2), Paint()..color = r.color);
      }
    }
  }

  void _paintBase(Canvas canvas, Path Function(Path) s, bool isFront) {
    final fill = Paint()..style = PaintingStyle.fill..color = const Color(0xFF12122A);
    final line = Paint()..style = PaintingStyle.stroke..color = const Color(0xFF2A2A50)..strokeWidth = 1.0;

    void draw(Path p) {
      canvas.drawPath(s(p), fill);
      canvas.drawPath(s(p), line);
    }

    // Head
    draw(_oval(100, 22, 20, 21));
    // Neck
    draw(Path()..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(90, 40, 20, 17), const Radius.circular(4))));
    // Shoulders
    draw(_oval(46, 69, 24, 19));
    draw(_oval(154, 69, 24, 19));
    // Upper arms
    draw(_oval(33, 118, 16, 34));
    draw(_oval(167, 118, 16, 34));
    // Forearms
    draw(_oval(24, 170, 13, 28));
    draw(_oval(176, 170, 13, 28));
    // Torso
    draw(() {
      final p = Path();
      p.moveTo(64, 57);
      p.lineTo(136, 57);
      p.quadraticBezierTo(140, 130, 135, isFront ? 178 : 188);
      p.lineTo(65, isFront ? 178 : 188);
      p.quadraticBezierTo(60, 130, 64, 57);
      p.close();
      return p;
    }());
    // Thighs
    draw(_oval(79, 250, 27, 50));
    draw(_oval(121, 250, 27, 50));
    // Lower legs
    draw(_oval(75, 346, 18, 32));
    draw(_oval(125, 346, 18, 32));

    if (isFront) {
      final eyePaint = Paint()..color = const Color(0xFF3A3A60);
      canvas.drawPath(s(_oval(93, 20, 2.5, 2.5)), eyePaint);
      canvas.drawPath(s(_oval(107, 20, 2.5, 2.5)), eyePaint);
    }
  }

  @override
  bool shouldRepaint(_BodyPainter old) => old.selected != selected || old.isFront != isFront;
}

// ─── Muscle names ─────────────────────────────────────────────────────────────

extension _MuscleLabel on MuscleGroup {
  String get displayName {
    switch (this) {
      case MuscleGroup.chest: return 'Chest';
      case MuscleGroup.back: return 'Back';
      case MuscleGroup.shoulders: return 'Shoulders';
      case MuscleGroup.biceps: return 'Biceps';
      case MuscleGroup.triceps: return 'Triceps';
      case MuscleGroup.forearms: return 'Forearms';
      case MuscleGroup.quadriceps: return 'Quadriceps';
      case MuscleGroup.hamstrings: return 'Hamstrings';
      case MuscleGroup.glutes: return 'Glutes';
      case MuscleGroup.calves: return 'Calves';
      case MuscleGroup.core: return 'Core / Abs';
      case MuscleGroup.fullBody: return 'Full Body';
      case MuscleGroup.cardio: return 'Cardio';
    }
  }

  Color get color {
    switch (this) {
      case MuscleGroup.chest: return TechnoColors.neonCyan;
      case MuscleGroup.back: return TechnoColors.neonPurple;
      case MuscleGroup.shoulders: return TechnoColors.neonYellow;
      case MuscleGroup.biceps: return TechnoColors.neonGreen;
      case MuscleGroup.triceps: return TechnoColors.neonGreen;
      case MuscleGroup.forearms: return const Color(0xFF80FFB0);
      case MuscleGroup.quadriceps: return TechnoColors.neonOrange;
      case MuscleGroup.hamstrings: return const Color(0xFFFF9030);
      case MuscleGroup.glutes: return TechnoColors.neonOrange;
      case MuscleGroup.calves: return TechnoColors.neonYellow;
      case MuscleGroup.core: return TechnoColors.neonPink;
      case MuscleGroup.fullBody: return TechnoColors.neonCyan;
      case MuscleGroup.cardio: return TechnoColors.neonYellow;
    }
  }
}

// ─── Main Widget ──────────────────────────────────────────────────────────────

class MuscleChartTab extends StatefulWidget {
  const MuscleChartTab({super.key});

  @override
  State<MuscleChartTab> createState() => _MuscleChartTabState();
}

class _MuscleChartTabState extends State<MuscleChartTab> {
  bool _showFront = true;
  MuscleGroup? _selected;

  final GlobalKey _paintKey = GlobalKey();

  List<Exercise> get _exercises {
    if (_selected == null) return [];
    return kExercises
        .where((e) => e.primaryMuscle == _selected || e.secondaryMuscles.contains(_selected))
        .toList()
      ..sort((a, b) {
        // Primary muscle exercises first
        final aPrimary = a.primaryMuscle == _selected ? 0 : 1;
        final bPrimary = b.primaryMuscle == _selected ? 0 : 1;
        return aPrimary.compareTo(bPrimary);
      });
  }

  void _handleTap(TapDownDetails details) {
    final box = _paintKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(details.globalPosition);
    final size = box.size;
    final sx = size.width / _kW;
    final sy = size.height / _kH;
    final m = Matrix4.diagonal3Values(sx, sy, 1.0).storage;

    final regions = _showFront ? _frontRegions : _backRegions;
    for (final r in regions.reversed) {
      if (r.path.transform(m).contains(local)) {
        setState(() => _selected = _selected == r.muscle ? null : r.muscle);
        return;
      }
    }
    setState(() => _selected = null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildToggle(),
        _buildChart(),
        _buildDivider(),
        Expanded(child: _buildExerciseList()),
      ],
    );
  }

  Widget _buildToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          _ToggleBtn(label: 'FRONT', active: _showFront, onTap: () => setState(() { _showFront = true; })),
          const SizedBox(width: 8),
          _ToggleBtn(label: 'BACK', active: !_showFront, onTap: () => setState(() { _showFront = false; })),
          const Spacer(),
          if (_selected != null)
            GestureDetector(
              onTap: () => setState(() => _selected = null),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: TechnoColors.textMuted),
                ),
                child: Text('CLEAR', style: GoogleFonts.orbitron(fontSize: 9, color: TechnoColors.textMuted)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return AspectRatio(
      aspectRatio: _kW / _kH,
      child: GestureDetector(
        onTapDown: _handleTap,
        child: CustomPaint(
          key: _paintKey,
          painter: _BodyPainter(
            regions: _showFront ? _frontRegions : _backRegions,
            selected: _selected,
            isFront: _showFront,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    final label = _selected != null
        ? '${_selected!.displayName.toUpperCase()} — ${_exercises.length} EXERCISES'
        : 'TAP A MUSCLE GROUP';
    final color = _selected?.color ?? TechnoColors.textMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
          bottom: BorderSide(color: TechnoColors.cardBorder, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (_selected != null)
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
          Text(
            label,
            style: GoogleFonts.orbitron(fontSize: 10, color: color, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList() {
    if (_selected == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.touch_app_outlined, size: 40, color: TechnoColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'Select a muscle group\nto see exercises',
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(
                fontSize: 16,
                color: TechnoColors.textMuted,
                height: 1.5,
              ),
            ),
          ],
        ),
      );
    }

    final exercises = _exercises;
    if (exercises.isEmpty) {
      return Center(
        child: Text('No exercises found', style: GoogleFonts.rajdhani(color: TechnoColors.textMuted, fontSize: 15)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: exercises.length,
      separatorBuilder: (_, i) => const SizedBox(height: 8),
      itemBuilder: (context, i) => _ExerciseCard(exercise: exercises[i], accentColor: _selected!.color),
    );
  }
}

// ─── Toggle Button ────────────────────────────────────────────────────────────

class _ToggleBtn extends StatelessWidget {
  const _ToggleBtn({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: active ? TechnoColors.neonCyan.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: active ? TechnoColors.neonCyan : TechnoColors.textMuted,
            width: active ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.orbitron(
            fontSize: 10,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            color: active ? TechnoColors.neonCyan : TechnoColors.textMuted,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

// ─── Exercise Card ────────────────────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({required this.exercise, required this.accentColor});
  final Exercise exercise;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TechnoColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: GoogleFonts.rajdhani(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: TechnoColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _Tag(exercise.difficulty.name.toUpperCase(), _difficultyColor(exercise.difficulty)),
                    const SizedBox(width: 6),
                    _Tag(exercise.primaryMuscle.displayName, accentColor),
                    if (exercise.isCompound) ...[
                      const SizedBox(width: 6),
                      _Tag('COMPOUND', TechnoColors.textMuted),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${exercise.defaultSets}×${exercise.defaultRepsOrSeconds}',
                style: GoogleFonts.orbitron(fontSize: 12, color: accentColor),
              ),
              Text(
                exercise.isTimeBased ? 'sec' : 'reps',
                style: GoogleFonts.rajdhani(fontSize: 11, color: TechnoColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _difficultyColor(FitnessLevel level) {
    switch (level) {
      case FitnessLevel.beginner: return TechnoColors.neonGreen;
      case FitnessLevel.intermediate: return TechnoColors.neonYellow;
      case FitnessLevel.advanced: return TechnoColors.neonPink;
    }
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.text, this.color);
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: GoogleFonts.rajdhani(fontSize: 10, color: color, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      ),
    );
  }
}
