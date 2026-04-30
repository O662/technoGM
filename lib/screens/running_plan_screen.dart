import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_card.dart';

// ── Data ────────────────────────────────────────────────────────────────────

class _RunWeek {
  final int week;
  final double runMin;
  final double walkMin;
  final int cycles;
  final int? bonusRunMin; // Week 6: extra final run after cycles
  final String? tip;      // Week 9: trainer's note

  const _RunWeek({
    required this.week,
    required this.runMin,
    required this.walkMin,
    required this.cycles,
    this.bonusRunMin,
    this.tip,
  });

  bool get isContinuous => walkMin == 0;

  String get intervalSummary {
    if (isContinuous) return 'Run ${_fmt(runMin)} min continuous';
    final base = '${_fmt(runMin)}m run / ${_fmt(walkMin)}m walk × $cycles';
    if (bonusRunMin != null) return '$base, then run ${bonusRunMin}m';
    return base;
  }

  String get totalMinLabel {
    if (isContinuous) return '${runMin.toInt()} min total';
    final total = (runMin + walkMin) * cycles + (bonusRunMin ?? 0);
    final rounded = total.truncateToDouble() == total
        ? total.toInt().toString()
        : total.toStringAsFixed(1);
    return '$rounded min total';
  }

  static String _fmt(double v) =>
      v == v.truncateToDouble() ? '${v.toInt()}' : '$v';
}

// Budd Coates 10-Week Beginner Running Plan
const _weeks = [
  _RunWeek(week: 1,  runMin: 2,  walkMin: 4,   cycles: 5),
  _RunWeek(week: 2,  runMin: 3,  walkMin: 3,   cycles: 5),
  _RunWeek(week: 3,  runMin: 5,  walkMin: 2.5, cycles: 4),
  _RunWeek(week: 4,  runMin: 7,  walkMin: 3,   cycles: 3),
  _RunWeek(week: 5,  runMin: 8,  walkMin: 2,   cycles: 3),
  _RunWeek(week: 6,  runMin: 9,  walkMin: 2,   cycles: 2, bonusRunMin: 8),
  _RunWeek(week: 7,  runMin: 9,  walkMin: 1,   cycles: 3),
  _RunWeek(week: 8,  runMin: 13, walkMin: 2,   cycles: 2),
  _RunWeek(
    week: 9,
    runMin: 14,
    walkMin: 1,
    cycles: 2,
    tip: 'If you feel tired after this week, repeat it before moving on to Week 10.',
  ),
  _RunWeek(week: 10, runMin: 30, walkMin: 0, cycles: 1),
];

const _scheduleDays = [
  _DayEntry(label: 'MON', isTraining: true),
  _DayEntry(label: 'TUE', isTraining: false),
  _DayEntry(label: 'WED', isTraining: true),
  _DayEntry(label: 'THU', isTraining: false),
  _DayEntry(label: 'FRI', isTraining: true),
  _DayEntry(label: 'SAT', isTraining: true),
  _DayEntry(label: 'SUN', isTraining: false, isForcedRest: true),
];

class _DayEntry {
  final String label;
  final bool isTraining;
  final bool isForcedRest;

  const _DayEntry({
    required this.label,
    required this.isTraining,
    this.isForcedRest = false,
  });
}

// ── Main Screen ─────────────────────────────────────────────────────────────

class RunningPlanScreen extends StatelessWidget {
  const RunningPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('10-WEEK RUNNING PLAN'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 20),
            Text(
              'SELECT A WEEK',
              style: GoogleFonts.orbitron(
                color: TechnoColors.textSecondary,
                fontSize: 11,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            ..._weeks.map((w) => _WeekTile(week: w)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: TechnoColors.neonOrange.withValues(alpha: 0.07),
        border: Border.all(
          color: TechnoColors.neonOrange.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Text('🏃', style: TextStyle(fontSize: 36)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BEGINNER RUNNING PLAN',
                  style: GoogleFonts.orbitron(
                    color: TechnoColors.neonOrange,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'By Budd Coates · 10 weeks · Mon / Wed / Fri / Sat',
                  style: GoogleFonts.rajdhani(
                    color: TechnoColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Build to 3.5 miles non-stop in 10 weeks',
                  style: GoogleFonts.rajdhani(
                    color: TechnoColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Week Tile ────────────────────────────────────────────────────────────────

class _WeekTile extends StatelessWidget {
  final _RunWeek week;
  const _WeekTile({required this.week});

  @override
  Widget build(BuildContext context) {
    final color = _colorForWeek(week.week);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => _showSchedule(context),
        child: NeonCard(
          borderColor: color.withValues(alpha: 0.35),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.12),
                  border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
                ),
                child: Center(
                  child: Text(
                    '${week.week}',
                    style: GoogleFonts.orbitron(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'WEEK ${week.week}',
                      style: GoogleFonts.orbitron(
                        color: TechnoColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      week.intervalSummary,
                      style: GoogleFonts.rajdhani(
                        color: TechnoColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      week.totalMinLabel,
                      style: GoogleFonts.rajdhani(
                        color: TechnoColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (week.tip != null)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(Icons.info_outline, color: color, size: 16),
                ),
              Icon(Icons.chevron_right, color: color, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showSchedule(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WeekScheduleSheet(week: week),
    );
  }

  Color _colorForWeek(int w) {
    const colors = [
      TechnoColors.neonGreen,
      TechnoColors.neonCyan,
      TechnoColors.neonCyan,
      TechnoColors.neonCyan,
      TechnoColors.neonYellow,
      TechnoColors.neonYellow,
      TechnoColors.neonOrange,
      TechnoColors.neonOrange,
      TechnoColors.neonPink,
      TechnoColors.neonPink,
    ];
    return colors[(w - 1).clamp(0, colors.length - 1)];
  }
}

// ── Week Schedule Bottom Sheet ───────────────────────────────────────────────

class _WeekScheduleSheet extends StatelessWidget {
  final _RunWeek week;
  const _WeekScheduleSheet({required this.week});

  Color _weekColor(int w) {
    const colors = [
      TechnoColors.neonGreen,
      TechnoColors.neonCyan,
      TechnoColors.neonCyan,
      TechnoColors.neonCyan,
      TechnoColors.neonYellow,
      TechnoColors.neonYellow,
      TechnoColors.neonOrange,
      TechnoColors.neonOrange,
      TechnoColors.neonPink,
      TechnoColors.neonPink,
    ];
    return colors[(w - 1).clamp(0, colors.length - 1)];
  }

  @override
  Widget build(BuildContext context) {
    final color = _weekColor(week.week);

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: TechnoColors.bgSecondary,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: TechnoColors.cardBorder, width: 1),
            ),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: TechnoColors.textMuted,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // ── Header ──
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: color.withValues(alpha: 0.12),
                      border: Border.all(color: color, width: 1.5),
                    ),
                    child: Text(
                      'WEEK ${week.week}',
                      style: GoogleFonts.orbitron(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          week.intervalSummary,
                          style: GoogleFonts.rajdhani(
                            color: TechnoColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          week.totalMinLabel,
                          style: GoogleFonts.rajdhani(
                            color: TechnoColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _intervalBreakdown(color),
              if (week.tip != null) ...[
                const SizedBox(height: 12),
                _tipCard(week.tip!),
              ],
              const SizedBox(height: 24),
              Text(
                'WEEKLY SCHEDULE',
                style: GoogleFonts.orbitron(
                  color: TechnoColors.textSecondary,
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),
              ..._scheduleDays.map(
                (day) => _DayRow(day: day, week: week, accentColor: color),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _intervalBreakdown(Color color) {
    if (week.isContinuous) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: TechnoColors.bgTertiary,
          border: Border.all(color: TechnoColors.cardBorder),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🏆', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CONTINUOUS RUN',
                  style: GoogleFonts.orbitron(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'No walk breaks — you\'ve earned it!',
                  style: GoogleFonts.rajdhani(
                    color: TechnoColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: TechnoColors.bgTertiary,
        border: Border.all(color: TechnoColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statPill('🏃 RUN', '${_RunWeek._fmt(week.runMin)} min', TechnoColors.neonOrange),
              _divider(),
              _statPill('🚶 WALK', '${_RunWeek._fmt(week.walkMin)} min', TechnoColors.neonCyan),
              _divider(),
              _statPill('🔁 CYCLES', '${week.cycles}×', color),
            ],
          ),
          if (week.bonusRunMin != null) ...[
            const SizedBox(height: 10),
            Divider(color: TechnoColors.cardBorder.withValues(alpha: 0.6), height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: TechnoColors.neonOrange, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Then run ${week.bonusRunMin} min to finish',
                  style: GoogleFonts.rajdhani(
                    color: TechnoColors.neonOrange,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _tipCard(String tip) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: TechnoColors.neonYellow.withValues(alpha: 0.06),
        border: Border.all(
          color: TechnoColors.neonYellow.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.lightbulb_outline, color: TechnoColors.neonYellow, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              tip,
              style: GoogleFonts.rajdhani(
                color: TechnoColors.neonYellow,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statPill(String label, String value, Color c) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.orbitron(
            color: c,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.rajdhani(
            color: TechnoColors.textMuted,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 32, color: TechnoColors.cardBorder);
}

// ── Day Row ──────────────────────────────────────────────────────────────────

class _DayRow extends StatelessWidget {
  final _DayEntry day;
  final _RunWeek week;
  final Color accentColor;

  const _DayRow({
    required this.day,
    required this.week,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isRest = !day.isTraining;
    final isSundayRest = day.isForcedRest;
    final label = week.isContinuous ? 'Continuous Run' : 'Run/Walk Intervals';
    final subtitle = week.isContinuous
        ? 'Run ${week.runMin.toInt()} min non-stop'
        : week.intervalSummary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isRest
              ? TechnoColors.bgPrimary
              : accentColor.withValues(alpha: 0.06),
          border: Border.all(
            color: isRest
                ? TechnoColors.cardBorder
                : accentColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 36,
              child: Text(
                day.label,
                style: GoogleFonts.orbitron(
                  color: isRest ? TechnoColors.textMuted : accentColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            if (!isRest) ...[
              Icon(Icons.directions_run, color: accentColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.rajdhani(
                        color: TechnoColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.rajdhani(
                        color: TechnoColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                week.totalMinLabel,
                style: GoogleFonts.rajdhani(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              Icon(
                isSundayRest ? Icons.weekend : Icons.self_improvement,
                color: TechnoColors.textMuted,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                isSundayRest ? 'Rest Day' : 'Rest / Active Recovery',
                style: GoogleFonts.rajdhani(
                  color: TechnoColors.textMuted,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
