import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../providers/step_provider.dart';
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
            child: _Header(name: name, streak: streak),
          ),

          // ── Hero Animation ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _HeroAnimation(),
          ),

          // ── Daily Steps ───────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: _DailyStepsCard(),
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
  final StreakData streak;
  const _Header({required this.name, required this.streak});

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
          Row(
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
              const Spacer(),
              _FlameIcon(streak: streak),
            ],
          ),
          Transform.translate(
            offset: const Offset(0, -8),
            child: Text(
              name.toUpperCase(),
              style: GoogleFonts.orbitron(
                color: TechnoColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                height: 1.0,
              ),
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

// ── Hero Animation ────────────────────────────────────────────────────────────

class _HeroAnimation extends StatefulWidget {
  const _HeroAnimation();

  @override
  State<_HeroAnimation> createState() => _HeroAnimationState();
}

class _HeroAnimationState extends State<_HeroAnimation>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _rotateCtrl;
  late final AnimationController _glowCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000),
    )..repeat();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rotateCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height / 3;
    return SizedBox(
      height: height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pulseCtrl, _rotateCtrl, _glowCtrl]),
        builder: (_, __) => CustomPaint(
          painter: _TechnoPainter(
            pulse: _pulseCtrl.value,
            rotation: _rotateCtrl.value,
            glow: _glowCtrl.value,
          ),
        ),
      ),
    );
  }
}

class _TechnoPainter extends CustomPainter {
  final double pulse;
  final double rotation;
  final double glow;

  const _TechnoPainter({
    required this.pulse,
    required this.rotation,
    required this.glow,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = math.min(size.width, size.height) * 0.40;

    _drawGrid(canvas, size);
    _drawPulsingRings(canvas, center, maxR);
    _drawStaticRings(canvas, center, maxR);
    _drawRotatingArcs(canvas, center, maxR);
    _drawOrbitingDots(canvas, center, maxR);
    _drawCenterGlow(canvas, center, maxR);
    _drawCornerAccents(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TechnoColors.neonCyan.withValues(alpha: 0.035)
      ..strokeWidth = 0.5;
    const spacing = 28.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawPulsingRings(Canvas canvas, Offset center, double maxR) {
    for (int i = 0; i < 3; i++) {
      final t = (pulse + i / 3.0) % 1.0;
      final radius = maxR * t;
      final alpha = (1.0 - t) * 0.55;
      if (alpha <= 0) continue;
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = TechnoColors.neonCyan.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawStaticRings(Canvas canvas, Offset center, double maxR) {
    canvas.drawCircle(
      center,
      maxR,
      Paint()
        ..color = TechnoColors.neonCyan.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    canvas.drawCircle(
      center,
      maxR * 0.6,
      Paint()
        ..color = TechnoColors.neonPurple.withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
    canvas.drawCircle(
      center,
      maxR * 0.25,
      Paint()
        ..color = TechnoColors.neonCyan.withValues(alpha: 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  void _drawRotatingArcs(Canvas canvas, Offset center, double maxR) {
    final angle = rotation * 2 * math.pi;

    // Inner arcs — purple, 4 segments rotating clockwise
    final innerArcPaint = Paint()
      ..color = TechnoColors.neonPurple.withValues(alpha: 0.75)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final innerRect = Rect.fromCircle(center: center, radius: maxR * 0.6);
    for (int i = 0; i < 4; i++) {
      canvas.drawArc(
        innerRect,
        angle + (i * math.pi / 2),
        math.pi / 5,
        false,
        innerArcPaint,
      );
    }

    // Outer arcs — cyan, 3 segments rotating counter-clockwise
    final outerArcPaint = Paint()
      ..color = TechnoColors.neonCyan.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final outerRect = Rect.fromCircle(center: center, radius: maxR * 0.85);
    final reverseAngle = -angle * 0.6;
    for (int i = 0; i < 3; i++) {
      canvas.drawArc(
        outerRect,
        reverseAngle + (i * 2 * math.pi / 3),
        math.pi / 7,
        false,
        outerArcPaint,
      );
    }
  }

  void _drawOrbitingDots(Canvas canvas, Offset center, double maxR) {
    final angle = rotation * 2 * math.pi;
    final dotPaint = Paint()
      ..color = TechnoColors.neonCyan
      ..style = PaintingStyle.fill;
    final dimDotPaint = Paint()
      ..color = TechnoColors.neonPurple.withValues(alpha: 0.8)
      ..style = PaintingStyle.fill;

    // 4 dots on outer ring
    for (int i = 0; i < 4; i++) {
      final a = angle + (i * math.pi / 2);
      canvas.drawCircle(
        Offset(center.dx + maxR * math.cos(a), center.dy + maxR * math.sin(a)),
        2.5,
        dotPaint,
      );
    }
    // 3 dots on mid ring (counter-rotating)
    final reverseAngle = -angle * 0.6;
    for (int i = 0; i < 3; i++) {
      final a = reverseAngle + (i * 2 * math.pi / 3);
      canvas.drawCircle(
        Offset(
          center.dx + maxR * 0.6 * math.cos(a),
          center.dy + maxR * 0.6 * math.sin(a),
        ),
        2.0,
        dimDotPaint,
      );
    }
  }

  void _drawCenterGlow(Canvas canvas, Offset center, double maxR) {
    // Soft glow halo
    canvas.drawCircle(
      center,
      maxR * 0.22,
      Paint()
        ..color = TechnoColors.neonCyan.withValues(alpha: 0.08 + glow * 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );
    // Tight glow
    canvas.drawCircle(
      center,
      7,
      Paint()
        ..color = TechnoColors.neonCyan.withValues(alpha: 0.4 + glow * 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
    );
    // Solid center dot
    canvas.drawCircle(
      center,
      3,
      Paint()
        ..color = TechnoColors.neonCyan
        ..style = PaintingStyle.fill,
    );
  }

  void _drawCornerAccents(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TechnoColors.neonCyan.withValues(alpha: 0.25)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    const len = 14.0;
    const margin = 10.0;

    // Top-left
    canvas.drawLine(const Offset(margin, margin), Offset(margin + len, margin), paint);
    canvas.drawLine(const Offset(margin, margin), Offset(margin, margin + len), paint);
    // Top-right
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin - len, margin), paint);
    canvas.drawLine(Offset(size.width - margin, margin), Offset(size.width - margin, margin + len), paint);
    // Bottom-left
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin + len, size.height - margin), paint);
    canvas.drawLine(Offset(margin, size.height - margin), Offset(margin, size.height - margin - len), paint);
    // Bottom-right
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin - len, size.height - margin), paint);
    canvas.drawLine(Offset(size.width - margin, size.height - margin), Offset(size.width - margin, size.height - margin - len), paint);
  }

  @override
  bool shouldRepaint(_TechnoPainter old) => true;
}

// ── Daily Steps Card ──────────────────────────────────────────────────────────

class _DailyStepsCard extends StatefulWidget {
  const _DailyStepsCard();

  @override
  State<_DailyStepsCard> createState() => _DailyStepsCardState();
}

class _DailyStepsCardState extends State<_DailyStepsCard> {
  static const _goal = 10000;

  @override
  void initState() {
    super.initState();
    // Kick off the permission prompt + fetch on first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StepProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<StepProvider>();

    return NeonCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'DAILY STEPS',
                style: GoogleFonts.orbitron(
                  color: TechnoColors.textSecondary,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: sp.isLoading ? null : () => sp.refresh(),
                child: Icon(
                  Icons.refresh,
                  size: 16,
                  color: sp.isLoading
                      ? TechnoColors.textMuted
                      : TechnoColors.neonCyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildBody(sp),
        ],
      ),
    );
  }

  Widget _buildBody(StepProvider sp) {
    switch (sp.status) {
      case StepStatus.loading:
      case StepStatus.idle:
        return const SizedBox(
          height: 36,
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: TechnoColors.neonCyan,
              ),
            ),
          ),
        );

      case StepStatus.unavailable:
        return _ActionRow(
          message: 'Health Connect not installed',
          buttonLabel: 'INSTALL',
          onTap: () => sp.openInstallPage(),
        );

      case StepStatus.denied:
        return _ActionRow(
          message: 'Permission required',
          buttonLabel: 'ALLOW',
          onTap: () => sp.refresh(),
        );

      case StepStatus.granted:
        final steps = sp.steps ?? 0;
        final progress = (steps / _goal).clamp(0.0, 1.0);
        final done = steps >= _goal;
        final color = done ? TechnoColors.neonGreen : TechnoColors.neonCyan;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  NumberFormat('#,###').format(steps),
                  style: GoogleFonts.orbitron(
                    color: color,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4, left: 6),
                  child: Text(
                    '/ ${NumberFormat('#,###').format(_goal)}',
                    style: GoogleFonts.rajdhani(
                      color: color.withValues(alpha: 0.55),
                      fontSize: 14,
                    ),
                  ),
                ),
                const Spacer(),
                if (done)
                  Icon(Icons.check_circle,
                      color: TechnoColors.neonGreen, size: 20),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: color.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              done
                  ? 'GOAL REACHED!'
                  : '${NumberFormat('#,###').format(_goal - steps)} TO GO',
              style: GoogleFonts.rajdhani(
                color: done ? TechnoColors.neonGreen : TechnoColors.textMuted,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
          ],
        );
    }
  }
}

class _ActionRow extends StatelessWidget {
  final String message;
  final String buttonLabel;
  final VoidCallback onTap;

  const _ActionRow({
    required this.message,
    required this.buttonLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.directions_walk,
            color: TechnoColors.textMuted, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: GoogleFonts.rajdhani(
              color: TechnoColors.textMuted,
              fontSize: 13,
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: TechnoColors.neonCyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: TechnoColors.neonCyan.withValues(alpha: 0.5)),
            ),
            child: Text(
              buttonLabel,
              style: GoogleFonts.orbitron(
                color: TechnoColors.neonCyan,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
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
