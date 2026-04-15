import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_card.dart';
import 'history_screen.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('STATS'),
          bottom: TabBar(
            labelColor: TechnoColors.neonCyan,
            unselectedLabelColor: TechnoColors.textMuted,
            indicatorColor: TechnoColors.neonCyan,
            indicatorWeight: 2,
            labelStyle: GoogleFonts.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
            unselectedLabelStyle: GoogleFonts.orbitron(
              fontSize: 12,
              letterSpacing: 2,
            ),
            tabs: const [
              Tab(text: 'OVERVIEW'),
              Tab(text: 'HISTORY'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(provider: provider),
            const _HistoryTab(),
          ],
        ),
      ),
    );
  }
}

// ── Overview Tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final AppProvider provider;
  const _OverviewTab({required this.provider});

  @override
  Widget build(BuildContext context) {
    final data = provider.data;
    final weightInKg = data.profile.preferKg;

    if (data.workouts.isEmpty && data.weightHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart, color: TechnoColors.textMuted, size: 64),
            const SizedBox(height: 16),
            Text(
              'NO DATA YET',
              style: GoogleFonts.orbitron(
                color: TechnoColors.textMuted,
                fontSize: 14,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete workouts to see your stats here',
              style: GoogleFonts.rajdhani(
                  color: TechnoColors.textMuted, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Summary Row ─────────────────────────────────────────────────
        _SummaryRow(provider: provider),
        const SizedBox(height: 16),

        // ── Weekly Frequency ────────────────────────────────────────────
        if (data.workouts.isNotEmpty) ...[
          _SectionLabel(label: 'WEEKLY FREQUENCY'),
          const SizedBox(height: 8),
          NeonCard(
            child: SizedBox(
              height: 180,
              child: _WeeklyBarChart(provider: provider),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Body Weight ─────────────────────────────────────────────────
        if (data.weightHistory.isNotEmpty) ...[
          _SectionLabel(label: 'BODY WEIGHT'),
          const SizedBox(height: 8),
          NeonCard(
            child: SizedBox(
              height: data.profile.goalWeightKg != null ? 300 : 260,
              child: _WeightLineChart(
                history: data.weightHistory,
                preferKg: weightInKg,
                goalWeightKg: data.profile.goalWeightKg,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Muscle Groups ────────────────────────────────────────────────
        if (data.workouts.isNotEmpty) ...[
          _SectionLabel(label: 'MUSCLE GROUP FOCUS'),
          const SizedBox(height: 8),
          NeonCard(
            child: _MuscleGroupChart(provider: provider),
          ),
          const SizedBox(height: 16),

          // ── Personal Records ─────────────────────────────────────────
          if (data.personalRecords.isNotEmpty) ...[
            _SectionLabel(label: 'PERSONAL RECORDS'),
            const SizedBox(height: 8),
            ...data.personalRecords.take(8).map(
              (pr) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _PRCard(pr: pr, preferKg: weightInKg),
              ),
            ),
          ],
        ],

        const SizedBox(height: 40),
      ],
    );
  }
}

// ── History Tab ───────────────────────────────────────────────────────────────

class _HistoryTab extends StatefulWidget {
  const _HistoryTab();

  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab> {
  WorkoutType? _filter;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    var workouts = provider.data.workouts.toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    if (_filter != null) {
      workouts = workouts.where((w) => w.type == _filter).toList();
    }

    return Column(
      children: [
        // ── Type filter ──────────────────────────────────────────────────
        Container(
          color: TechnoColors.bgSecondary,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _TabChip(
                  label: 'All',
                  selected: _filter == null,
                  onTap: () => setState(() => _filter = null),
                ),
                ...WorkoutType.values.map(
                  (t) => _TabChip(
                    label: t.label,
                    selected: _filter == t,
                    onTap: () => setState(() => _filter = t),
                  ),
                ),
              ],
            ),
          ),
        ),
        // ── List ─────────────────────────────────────────────────────────
        Expanded(
          child: workouts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.history,
                          color: TechnoColors.textMuted, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        _filter != null
                            ? 'NO WORKOUTS MATCH FILTER'
                            : 'NO WORKOUTS YET',
                        style: GoogleFonts.orbitron(
                          color: TechnoColors.textMuted,
                          fontSize: 14,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _filter != null
                            ? 'Try a different filter'
                            : 'Complete your first workout to see it here',
                        style: GoogleFonts.rajdhani(
                            color: TechnoColors.textMuted, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: workouts.length,
                  itemBuilder: (ctx, i) => WorkoutHistoryCard(
                    workout: workouts[i],
                    onDelete: () =>
                        _confirmDelete(context, provider, workouts[i].id),
                  ),
                ),
        ),
      ],
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
          style:
              GoogleFonts.orbitron(color: TechnoColors.neonPink, fontSize: 14),
        ),
        content: const Text('Remove this workout from history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('DELETE',
                style: TextStyle(color: TechnoColors.neonPink)),
          ),
        ],
      ),
    );
    if (confirmed == true) provider.deleteWorkout(id);
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.label,
    required this.selected,
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
            color: selected
                ? TechnoColors.neonCyan.withValues(alpha: 0.18)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? TechnoColors.neonCyan : TechnoColors.cardBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: GoogleFonts.rajdhani(
              color: selected ? TechnoColors.neonCyan : TechnoColors.textMuted,
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Summary Row ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  final AppProvider provider;
  const _SummaryRow({required this.provider});

  @override
  Widget build(BuildContext context) {
    final workouts = provider.data.workouts;
    final totalMins = workouts.fold(0, (s, w) => s + w.durationMinutes);
    final totalCal = workouts.fold(0, (s, w) => s + w.caloriesBurned);

    return Row(
      children: [
        _StatBox(
          value: '${workouts.length}',
          label: 'TOTAL\nWORKOUTS',
          color: TechnoColors.neonCyan,
        ),
        const SizedBox(width: 8),
        _StatBox(
          value: totalMins >= 60
              ? '${(totalMins / 60).toStringAsFixed(1)}h'
              : '${totalMins}m',
          label: 'TOTAL\nTIME',
          color: TechnoColors.neonPurple,
        ),
        const SizedBox(width: 8),
        _StatBox(
          value: totalCal > 1000
              ? '${(totalCal / 1000).toStringAsFixed(1)}k'
              : '$totalCal',
          label: 'TOTAL\nCALORIES',
          color: TechnoColors.neonOrange,
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatBox({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.orbitron(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.rajdhani(
                color: TechnoColors.textMuted,
                fontSize: 10,
                letterSpacing: 0.5,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Weekly Bar Chart ──────────────────────────────────────────────────────────

class _WeeklyBarChart extends StatelessWidget {
  final AppProvider provider;
  const _WeeklyBarChart({required this.provider});

  @override
  Widget build(BuildContext context) {
    final weeks = provider.workoutsPerWeek(8);
    final maxY = weeks.isEmpty
        ? 7.0
        : (weeks.reduce((a, b) => a > b ? a : b) + 1)
            .toDouble()
            .clamp(3.0, 14.0);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (_) => FlLine(
            color: TechnoColors.cardBorder,
            strokeWidth: 1,
          ),
          drawVerticalLine: false,
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              interval: 1,
              getTitlesWidget: (v, _) => Text(
                '${v.toInt()}',
                style: GoogleFonts.orbitron(
                  color: TechnoColors.textMuted,
                  fontSize: 9,
                ),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final idx = v.toInt();
                final weeksAgo = 7 - idx;
                if (weeksAgo == 0) {
                  return Text('NOW',
                      style: GoogleFonts.orbitron(
                          color: TechnoColors.neonCyan, fontSize: 8));
                }
                return Text('W-$weeksAgo',
                    style: GoogleFonts.orbitron(
                        color: TechnoColors.textMuted, fontSize: 8));
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: List.generate(weeks.length, (i) {
          final v = weeks[i].toDouble();
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: v,
                color: i == weeks.length - 1
                    ? TechnoColors.neonCyan
                    : TechnoColors.neonPurple.withValues(alpha: 0.7),
                width: 16,
                borderRadius: BorderRadius.circular(4),
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxY,
                  color: TechnoColors.cardBorder.withValues(alpha: 0.3),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Weight Line Chart ─────────────────────────────────────────────────────────

class _WeightLineChart extends StatelessWidget {
  final List<BodyWeightEntry> history;
  final bool preferKg;
  final double? goalWeightKg; // stored in kg, converted on display

  const _WeightLineChart({
    required this.history,
    required this.preferKg,
    this.goalWeightKg,
  });

  double _convert(double kg) => preferKg ? kg : kg * 2.20462;
  String get _unit => preferKg ? 'kg' : 'lbs';

  /// Linear regression → (slope, intercept)
  (double, double) _regression(List<FlSpot> spots) {
    final n = spots.length.toDouble();
    final sumX = spots.fold(0.0, (s, p) => s + p.x);
    final sumY = spots.fold(0.0, (s, p) => s + p.y);
    final sumXY = spots.fold(0.0, (s, p) => s + p.x * p.y);
    final sumX2 = spots.fold(0.0, (s, p) => s + p.x * p.x);
    final denom = n * sumX2 - sumX * sumX;
    if (denom == 0) return (0, sumY / n);
    final slope = (n * sumXY - sumX * sumY) / denom;
    final intercept = (sumY - slope * sumX) / n;
    return (slope, intercept);
  }

  /// Human-readable duration from days.
  String _formatDays(int days) {
    if (days < 7) return '$days d';
    if (days < 30) return '${(days / 7).round()} wks';
    if (days < 365) return '${(days / 30.4).round()} mo';
    return '${(days / 365.0).toStringAsFixed(1)} yr';
  }

  @override
  Widget build(BuildContext context) {
    final spots = history.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), _convert(e.value.weightKg));
    }).toList();

    final first = _convert(history.first.weightKg);
    final current = _convert(history.last.weightKg);
    final delta = current - first;
    final deltaColor = delta <= 0 ? TechnoColors.neonGreen : TechnoColors.neonOrange;

    // Include goal in y-range so the line is always visible
    final goalDisplay = goalWeightKg != null ? _convert(goalWeightKg!) : null;
    final allY = [...spots.map((s) => s.y), ?goalDisplay];
    final minY = allY.reduce((a, b) => a < b ? a : b) - 2.0;
    final maxY = allY.reduce((a, b) => a > b ? a : b) + 2.0;

    // Regression & ETA
    double slope = 0, intercept = 0;
    if (spots.length >= 2) {
      (slope, intercept) = _regression(spots);
    }

    String? etaText;
    double? remaining;
    if (goalDisplay != null && spots.length >= 2) {
      remaining = goalDisplay - current;
      final totalDays =
          history.last.date.difference(history.first.date).inDays;
      if (totalDays > 0) {
        final slopePerDay = slope * (history.length - 1) / totalDays;
        if (slopePerDay.abs() >= 0.001) {
          // trend moving toward goal?
          if ((remaining < 0 && slopePerDay < 0) ||
              (remaining > 0 && slopePerDay > 0)) {
            etaText = _formatDays((remaining / slopePerDay).abs().round());
          } else {
            etaText = 'off track';
          }
        }
      }
    }

    // Trend line
    final lineBars = <LineChartBarData>[
      LineChartBarData(
        spots: spots,
        isCurved: true,
        curveSmoothness: 0.35,
        color: TechnoColors.neonGreen,
        barWidth: 2.5,
        dotData: FlDotData(
          show: spots.length <= 12,
          getDotPainter: (_, _, _, _) => FlDotCirclePainter(
            radius: 3,
            color: TechnoColors.neonGreen,
            strokeWidth: 0,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              TechnoColors.neonGreen.withValues(alpha: 0.15),
              TechnoColors.neonGreen.withValues(alpha: 0.0),
            ],
          ),
        ),
      ),
    ];

    if (spots.length >= 2) {
      lineBars.add(
        LineChartBarData(
          spots: [
            FlSpot(spots.first.x, slope * spots.first.x + intercept),
            FlSpot(spots.last.x, slope * spots.last.x + intercept),
          ],
          isCurved: false,
          color: TechnoColors.neonCyan.withValues(alpha: 0.55),
          barWidth: 1.5,
          dotData: const FlDotData(show: false),
          dashArray: [6, 4],
        ),
      );
    }

    // Spread bottom labels so they never overlap
    final labelStep = ((spots.length - 1) / 4).ceil().clamp(1, spots.length);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 12, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Stats row ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 34, bottom: 6),
            child: Row(
              children: [
                _WeightStatLabel(
                  label: 'START',
                  value: '${first.toStringAsFixed(1)} $_unit',
                  color: TechnoColors.textMuted,
                ),
                const SizedBox(width: 16),
                _WeightStatLabel(
                  label: 'NOW',
                  value: '${current.toStringAsFixed(1)} $_unit',
                  color: TechnoColors.neonGreen,
                ),
                const Spacer(),
                _WeightStatLabel(
                  label: 'CHANGE',
                  value: '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(1)} $_unit',
                  color: deltaColor,
                  alignEnd: true,
                ),
              ],
            ),
          ),

          // ── Goal row (only when a goal weight is set) ──────────────────
          if (goalDisplay != null)
            Padding(
              padding: const EdgeInsets.only(left: 34, bottom: 8),
              child: Row(
                children: [
                  _WeightStatLabel(
                    label: 'GOAL',
                    value: '${goalDisplay.toStringAsFixed(1)} $_unit',
                    color: TechnoColors.neonYellow,
                  ),
                  const SizedBox(width: 16),
                  if (remaining != null)
                    _WeightStatLabel(
                      label: 'TO GO',
                      value: '${remaining.abs().toStringAsFixed(1)} $_unit',
                      color: TechnoColors.neonYellow,
                    ),
                  const Spacer(),
                  if (etaText != null)
                    _WeightStatLabel(
                      label: 'EST. TIME',
                      value: etaText,
                      color: etaText == 'off track'
                          ? TechnoColors.neonOrange
                          : TechnoColors.neonCyan,
                      alignEnd: true,
                    ),
                ],
              ),
            ),

          // ── Chart ──────────────────────────────────────────────────────
          Expanded(
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                extraLinesData: goalDisplay != null
                    ? ExtraLinesData(horizontalLines: [
                        HorizontalLine(
                          y: goalDisplay,
                          color: TechnoColors.neonYellow.withValues(alpha: 0.8),
                          strokeWidth: 1.5,
                          dashArray: [6, 4],
                          label: HorizontalLineLabel(
                            show: true,
                            alignment: Alignment.topRight,
                            padding: const EdgeInsets.only(right: 4, bottom: 2),
                            style: GoogleFonts.orbitron(
                              color: TechnoColors.neonYellow,
                              fontSize: 8,
                              letterSpacing: 1,
                            ),
                            labelResolver: (_) => 'GOAL',
                          ),
                        ),
                      ])
                    : ExtraLinesData(),
                gridData: FlGridData(
                  show: true,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: TechnoColors.cardBorder,
                    strokeWidth: 1,
                  ),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      getTitlesWidget: (v, _) => Text(
                        v.toStringAsFixed(1),
                        style: GoogleFonts.orbitron(
                            color: TechnoColors.textMuted, fontSize: 8),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx >= history.length) return const SizedBox.shrink();
                        final isFirst = idx == 0;
                        final isLast = idx == history.length - 1;
                        if (!isFirst && !isLast && idx % labelStep != 0) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            DateFormat('d/M').format(history[idx].date),
                            style: GoogleFonts.orbitron(
                                color: TechnoColors.textMuted, fontSize: 8),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: lineBars,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touched) => touched.map((s) {
                      if (s.barIndex != 0) return null; // skip trend line
                      final idx = s.spotIndex;
                      if (idx >= history.length) return null;
                      final date =
                          DateFormat('d MMM').format(history[idx].date);
                      return LineTooltipItem(
                        '${s.y.toStringAsFixed(1)} $_unit\n',
                        GoogleFonts.orbitron(
                          color: TechnoColors.neonGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                        children: [
                          TextSpan(
                            text: date,
                            style: GoogleFonts.rajdhani(
                              color: TechnoColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightStatLabel extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool alignEnd;

  const _WeightStatLabel({
    required this.label,
    required this.value,
    required this.color,
    this.alignEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.orbitron(
              color: TechnoColors.textMuted, fontSize: 8, letterSpacing: 1),
        ),
        Text(
          value,
          style: GoogleFonts.orbitron(
              color: color, fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

// ── Muscle Group Chart ────────────────────────────────────────────────────────

class _MuscleGroupChart extends StatelessWidget {
  final AppProvider provider;
  const _MuscleGroupChart({required this.provider});

  static const _colors = [
    TechnoColors.neonCyan,
    TechnoColors.neonPink,
    TechnoColors.neonGreen,
    TechnoColors.neonPurple,
    TechnoColors.neonYellow,
    TechnoColors.neonOrange,
    Color(0xFF00BFFF),
    Color(0xFFFF4500),
  ];

  @override
  Widget build(BuildContext context) {
    final byType = provider.workoutTypeCount();
    if (byType.isEmpty) return const SizedBox.shrink();

    final total = byType.values.fold(0, (a, b) => a + b);
    final entries = byType.entries.toList();

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: PieChart(
              PieChartData(
                sections: entries.asMap().entries.map((e) {
                  final color = _colors[e.key % _colors.length];
                  final pct = e.value.value / total * 100;
                  return PieChartSectionData(
                    value: e.value.value.toDouble(),
                    color: color,
                    radius: 40,
                    title: '${pct.round()}%',
                    titleStyle: GoogleFonts.orbitron(
                      color: TechnoColors.bgPrimary,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  );
                }).toList(),
                sectionsSpace: 2,
                centerSpaceRadius: 20,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: entries.asMap().entries.map((e) {
                final color = _colors[e.key % _colors.length];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          e.value.key.label,
                          style: GoogleFonts.rajdhani(
                            color: TechnoColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        '${e.value.value}',
                        style: GoogleFonts.orbitron(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── PR Card ───────────────────────────────────────────────────────────────────

class _PRCard extends StatelessWidget {
  final PersonalRecord pr;
  final bool preferKg;

  const _PRCard({required this.pr, required this.preferKg});

  @override
  Widget build(BuildContext context) {
    final weight = preferKg ? pr.weightKg : pr.weightKg * 2.20462;
    final unit = preferKg ? 'kg' : 'lbs';
    final orm = preferKg ? pr.oneRepMax : pr.oneRepMax * 2.20462;

    return NeonCard(
      borderColor: TechnoColors.neonYellow.withValues(alpha: 0.4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.emoji_events,
              color: TechnoColors.neonYellow, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pr.exerciseName,
                  style: GoogleFonts.rajdhani(
                    color: TechnoColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  DateFormat('d MMM y').format(pr.date),
                  style: GoogleFonts.rajdhani(
                    color: TechnoColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${weight.toStringAsFixed(1)} $unit × ${pr.reps}',
                style: GoogleFonts.orbitron(
                  color: TechnoColors.neonYellow,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '1RM ~${orm.toStringAsFixed(1)} $unit',
                style: GoogleFonts.rajdhani(
                  color: TechnoColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

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
