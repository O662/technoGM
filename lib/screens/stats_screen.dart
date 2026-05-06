import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../services/step_service.dart';
import '../services/water_service.dart';
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
      length: 3,
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
              Tab(text: 'CALENDAR'),
              Tab(text: 'HISTORY'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _OverviewTab(provider: provider),
            const _CalendarTab(),
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

        // ── This Week ───────────────────────────────────────────────────
        _SectionLabel(label: 'THIS WEEK'),
        const SizedBox(height: 8),
        _ThisWeekCard(provider: provider),
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

// ── This Week Card (Overview) ─────────────────────────────────────────────────

class _ThisWeekCard extends StatefulWidget {
  final AppProvider provider;
  const _ThisWeekCard({required this.provider});

  @override
  State<_ThisWeekCard> createState() => _ThisWeekCardState();
}

class _ThisWeekCardState extends State<_ThisWeekCard> {
  final Map<int, int?> _stepsByIndex = {};
  final Map<int, double> _waterByIndex = {};
  final Map<int, double?> _calsByIndex = {};
  final Map<int, int?> _activeByIndex = {};
  late final List<DateTime> _days;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
    _loadData();
  }

  Future<void> _loadData() async {
    final results = await Future.wait([
      Future.wait(_days.map(StepService.stepsForDay)),
      Future.wait(_days.map(WaterService.getWaterForDay)),
      Future.wait(_days.map(StepService.caloriesForDay)),
      Future.wait(_days.map(StepService.activeMinutesForDay)),
    ]);
    if (!mounted) return;
    final steps = results[0] as List<int?>;
    final water = results[1] as List<double>;
    final cals = results[2] as List<double?>;
    final active = results[3] as List<int?>;
    setState(() {
      for (int i = 0; i < 7; i++) {
        _stepsByIndex[i] = steps[i];
        _waterByIndex[i] = water[i];
        _calsByIndex[i] = cals[i];
        _activeByIndex[i] = active[i];
      }
    });
  }

  String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  Color _typeColor(WorkoutType t) {
    switch (t) {
      case WorkoutType.strength:
        return TechnoColors.neonCyan;
      case WorkoutType.cardio:
        return TechnoColors.neonGreen;
      case WorkoutType.hiit:
        return TechnoColors.neonPink;
      case WorkoutType.bodyweight:
        return TechnoColors.neonPurple;
      case WorkoutType.mixed:
        return TechnoColors.neonOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final workouts = widget.provider.data.workouts;
    final workoutsByDay = <String, List<CompletedWorkout>>{};
    for (final w in workouts) {
      final key = _dayKey(w.startTime);
      workoutsByDay[key] = [...(workoutsByDay[key] ?? []), w];
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return NeonCard(
      padding: const EdgeInsets.all(6),
      child: Column(
        children: [
          Row(
            children: _days
                .map((day) => Expanded(
                      child: Text(
                        DateFormat('E').format(day).toUpperCase(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.orbitron(
                          color: day == today
                              ? TechnoColors.neonCyan
                              : TechnoColors.textMuted,
                          fontSize: 9,
                          letterSpacing: 1,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          Row(
            children: List.generate(7, (i) {
              final day = _days[i];
              final isToday =
                  day.year == today.year && day.month == today.month && day.day == today.day;
              return Expanded(
                child: _MiniRingsCell(
                  date: day,
                  workouts: workoutsByDay[_dayKey(day)] ?? [],
                  stepsP: (_stepsByIndex[i] ?? 0) / 10000.0,
                  activeP: (_activeByIndex[i] ?? 0) / 30.0,
                  calsP: (_calsByIndex[i] ?? 0) / 2000.0,
                  waterP: (_waterByIndex[i] ?? 0.0) / 2000.0,
                  isToday: isToday,
                  typeColor: _typeColor,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Mini Rings Cell ───────────────────────────────────────────────────────────

class _MiniRingsCell extends StatelessWidget {
  final DateTime date;
  final List<CompletedWorkout> workouts;
  final double stepsP;
  final double activeP;
  final double calsP;
  final double waterP;
  final bool isToday;
  final Color Function(WorkoutType) typeColor;

  const _MiniRingsCell({
    required this.date,
    required this.workouts,
    required this.stepsP,
    required this.activeP,
    required this.calsP,
    required this.waterP,
    required this.isToday,
    required this.typeColor,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isFuture = DateTime(date.year, date.month, date.day).isAfter(today);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: isToday ? TechnoColors.neonCyan.withValues(alpha: 0.10) : null,
        borderRadius: BorderRadius.circular(8),
        border: isToday
            ? Border.all(color: TechnoColors.neonCyan, width: 1.5)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${date.day}',
            style: GoogleFonts.orbitron(
              color: isToday
                  ? TechnoColors.neonCyan
                  : isFuture
                      ? TechnoColors.textMuted.withValues(alpha: 0.4)
                      : TechnoColors.textSecondary,
              fontSize: 11,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 44,
            height: 44,
            child: isFuture
                ? null
                : CustomPaint(
                    painter: _MiniRingsPainter(
                      stepsP: stepsP.clamp(0.0, 1.0),
                      activeP: activeP.clamp(0.0, 1.0),
                      calsP: calsP.clamp(0.0, 1.0),
                      waterP: waterP.clamp(0.0, 1.0),
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          if (workouts.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: workouts.take(3).map((w) => Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: typeColor(w.type),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: typeColor(w.type).withValues(alpha: 0.7),
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  )).toList(),
            )
          else
            const SizedBox(height: 6),
        ],
      ),
    );
  }
}

// ── Mini Rings Painter ────────────────────────────────────────────────────────

class _MiniRingsPainter extends CustomPainter {
  final double stepsP;
  final double activeP;
  final double calsP;
  final double waterP;

  const _MiniRingsPainter({
    required this.stepsP,
    required this.activeP,
    required this.calsP,
    required this.waterP,
  });

  static const double _stroke = 3.5;
  static const double _gap = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = min(size.width, size.height) / 2 - _stroke / 2 - 1;

    _drawRing(canvas, center, maxR, stepsP, TechnoColors.neonCyan);
    _drawRing(canvas, center, maxR - (_stroke + _gap), activeP, TechnoColors.neonGreen);
    _drawRing(canvas, center, maxR - 2 * (_stroke + _gap), calsP, TechnoColors.neonOrange);
    _drawRing(canvas, center, maxR - 3 * (_stroke + _gap), waterP, TechnoColors.neonPurple);
  }

  void _drawRing(Canvas canvas, Offset center, double radius, double progress, Color color) {
    if (radius <= 0) return;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke,
    );
    if (progress <= 0) return;
    final sweep = progress * 2 * pi;
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect, -pi / 2, sweep, false,
      Paint()
        ..color = color.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke + 3
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawArc(
      rect, -pi / 2, sweep, false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_MiniRingsPainter old) =>
      old.stepsP != stepsP ||
      old.activeP != activeP ||
      old.calsP != calsP ||
      old.waterP != waterP;
}

// ── Calendar Tab ──────────────────────────────────────────────────────────────

class _CalendarTab extends StatefulWidget {
  const _CalendarTab();

  @override
  State<_CalendarTab> createState() => _CalendarTabState();
}

class _CalendarTabState extends State<_CalendarTab> {
  late DateTime _focusedMonth;
  final Map<String, int?> _stepsByDay = {};
  final Map<String, double> _waterByDay = {};
  final Map<String, double?> _calsByDay = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _loadMonthData(_focusedMonth);
  }

  String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  Future<void> _loadMonthData(DateTime month) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;

    final dates = <DateTime>[];
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(month.year, month.month, d);
      if (date.isAfter(today)) break;
      dates.add(date);
    }

    final results = await Future.wait([
      Future.wait(dates.map(StepService.stepsForDay)),
      Future.wait(dates.map(WaterService.getWaterForDay)),
      Future.wait(dates.map(StepService.caloriesForDay)),
    ]);
    if (!mounted) return;
    final steps = results[0] as List<int?>;
    final water = results[1] as List<double>;
    final cals = results[2] as List<double?>;
    setState(() {
      for (int i = 0; i < dates.length; i++) {
        _stepsByDay[_dayKey(dates[i])] = steps[i];
        _waterByDay[_dayKey(dates[i])] = water[i];
        _calsByDay[_dayKey(dates[i])] = cals[i];
      }
    });
  }

  void _changeMonth(DateTime newMonth) {
    setState(() => _focusedMonth = newMonth);
    _loadMonthData(newMonth);
  }

  void _openWeekView(BuildContext context, DateTime date, List<CompletedWorkout> workouts) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WeekViewSheet(selectedDate: date, allWorkouts: workouts),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final workouts = provider.data.workouts;

    final workoutsByDay = <String, List<CompletedWorkout>>{};
    for (final w in workouts) {
      final key = _dayKey(w.startTime);
      workoutsByDay[key] = [...(workoutsByDay[key] ?? []), w];
    }

    final now = DateTime.now();
    final isCurrentMonth =
        _focusedMonth.year == now.year && _focusedMonth.month == now.month;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Month navigation header
        Row(
          children: [
            IconButton(
              onPressed: () => _changeMonth(
                  DateTime(_focusedMonth.year, _focusedMonth.month - 1)),
              icon: const Icon(Icons.chevron_left, color: TechnoColors.neonCyan),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
            Expanded(
              child: Text(
                DateFormat('MMMM yyyy').format(_focusedMonth).toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  color: TechnoColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ),
            IconButton(
              onPressed: isCurrentMonth
                  ? null
                  : () => _changeMonth(
                      DateTime(_focusedMonth.year, _focusedMonth.month + 1)),
              icon: Icon(
                Icons.chevron_right,
                color: isCurrentMonth
                    ? TechnoColors.textMuted
                    : TechnoColors.neonCyan,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Day-of-week labels
        Row(
          children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
              .map((d) => Expanded(
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.orbitron(
                        color: TechnoColors.textMuted,
                        fontSize: 9,
                        letterSpacing: 1,
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 6),
        // Calendar grid
        _CalendarGrid(
          focusedMonth: _focusedMonth,
          workoutsByDay: workoutsByDay,
          stepsByDay: _stepsByDay,
          waterByDay: _waterByDay,
          calsByDay: _calsByDay,
          weeklySessionGoal: provider.data.streak.weeklySessionGoal,
          onDayTapped: (date) => _openWeekView(context, date, workouts),
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          spacing: 14,
          runSpacing: 8,
          children: [
            (TechnoColors.neonCyan, 'Strength'),
            (TechnoColors.neonGreen, 'Cardio'),
            (TechnoColors.neonPink, 'HIIT'),
            (TechnoColors.neonPurple, 'Bodyweight'),
            (TechnoColors.neonOrange, 'Mixed'),
          ]
              .map((item) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: item.$1,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: item.$1.withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        item.$2,
                        style: GoogleFonts.rajdhani(
                          color: TechnoColors.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ))
              .toList(),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
}

// ── Calendar Grid ─────────────────────────────────────────────────────────────

class _CalendarGrid extends StatelessWidget {
  final DateTime focusedMonth;
  final Map<String, List<CompletedWorkout>> workoutsByDay;
  final Map<String, int?> stepsByDay;
  final Map<String, double> waterByDay;
  final Map<String, double?> calsByDay;
  final int weeklySessionGoal;
  final void Function(DateTime) onDayTapped;

  const _CalendarGrid({
    required this.focusedMonth,
    required this.workoutsByDay,
    required this.stepsByDay,
    required this.waterByDay,
    required this.calsByDay,
    required this.weeklySessionGoal,
    required this.onDayTapped,
  });

  String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  Color _typeColor(WorkoutType t) {
    switch (t) {
      case WorkoutType.strength:
        return TechnoColors.neonCyan;
      case WorkoutType.cardio:
        return TechnoColors.neonGreen;
      case WorkoutType.hiit:
        return TechnoColors.neonPink;
      case WorkoutType.bodyweight:
        return TechnoColors.neonPurple;
      case WorkoutType.mixed:
        return TechnoColors.neonOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final daysInMonth =
        DateTime(focusedMonth.year, focusedMonth.month + 1, 0).day;
    final startOffset = firstDay.weekday - 1; // Mon=0, Sun=6
    final rows = ((startOffset + daysInMonth) / 7).ceil();

    return NeonCard(
      padding: const EdgeInsets.all(6),
      child: Column(
        children: List.generate(rows, (rowIndex) {
          // Count sessions this week row for the qualifying tint
          int weekSessions = 0;
          for (int col = 0; col < 7; col++) {
            final dayNum = rowIndex * 7 + col - startOffset + 1;
            if (dayNum >= 1 && dayNum <= daysInMonth) {
              final d = DateTime(focusedMonth.year, focusedMonth.month, dayNum);
              weekSessions += workoutsByDay[_dayKey(d)]?.length ?? 0;
            }
          }
          final weekMet = weekSessions >= weeklySessionGoal;
          final weekPartial = weekSessions > 0 && !weekMet;

          return Container(
            margin: const EdgeInsets.only(bottom: 2),
            decoration: BoxDecoration(
              color: weekMet
                  ? TechnoColors.neonGreen.withValues(alpha: 0.05)
                  : weekPartial
                      ? TechnoColors.neonYellow.withValues(alpha: 0.03)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: List.generate(7, (colIndex) {
                final dayNum = rowIndex * 7 + colIndex - startOffset + 1;
                if (dayNum < 1 || dayNum > daysInMonth) {
                  return const Expanded(child: SizedBox(height: 54));
                }
                final date =
                    DateTime(focusedMonth.year, focusedMonth.month, dayNum);
                final dayWorkouts = workoutsByDay[_dayKey(date)] ?? [];
                final steps = stepsByDay[_dayKey(date)];
                final water = waterByDay[_dayKey(date)] ?? 0.0;
                final cals = calsByDay[_dayKey(date)];

                return Expanded(
                  child: GestureDetector(
                    onTap: () => onDayTapped(date),
                    child: _DayCell(
                      date: date,
                      workouts: dayWorkouts,
                      steps: steps,
                      water: water,
                      calories: cals,
                      isToday: _isToday(date),
                      typeColor: _typeColor,
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ),
    );
  }
}

// ── Day Cell ──────────────────────────────────────────────────────────────────

class _DayCell extends StatelessWidget {
  final DateTime date;
  final List<CompletedWorkout> workouts;
  final int? steps;
  final double water;
  final double? calories;
  final bool isToday;
  final Color Function(WorkoutType) typeColor;

  const _DayCell({
    required this.date,
    required this.workouts,
    required this.steps,
    required this.water,
    required this.isToday,
    required this.typeColor,
    this.calories,
  });

  static Color _stepColor(int s) {
    if (s >= 10000) return TechnoColors.neonGreen;
    if (s >= 7000) return TechnoColors.neonYellow;
    return TechnoColors.textMuted;
  }

  static Color _waterColor(double ml) {
    if (ml >= 2000) return TechnoColors.neonPurple;
    if (ml >= 1000) return TechnoColors.neonPurple.withValues(alpha: 0.6);
    return TechnoColors.textMuted;
  }

  static String _formatSteps(int s) =>
      s >= 1000 ? '${(s / 1000).toStringAsFixed(1)}k' : '$s';

  static String _formatWater(double ml) =>
      ml >= 1000 ? '${(ml / 1000).toStringAsFixed(1)}L' : '${ml.round()}ml';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cellDay = DateTime(date.year, date.month, date.day);
    final isFuture = cellDay.isAfter(today);
    final hasWorkout = workouts.isNotEmpty;
    final showSteps = steps != null && steps! > 0 && !isFuture;
    final showCals = calories != null && calories! > 0 && !isFuture;
    final showWater = water > 0 && !isFuture;

    return Container(
      height: 80,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isToday
            ? TechnoColors.neonCyan.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isToday
            ? Border.all(color: TechnoColors.neonCyan, width: 1.5)
            : hasWorkout
                ? Border.all(
                    color: TechnoColors.cardBorder.withValues(alpha: 0.6))
                : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Day number
          Text(
            '${date.day}',
            style: GoogleFonts.orbitron(
              color: isToday
                  ? TechnoColors.neonCyan
                  : isFuture
                      ? TechnoColors.textMuted.withValues(alpha: 0.4)
                      : TechnoColors.textSecondary,
              fontSize: 11,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          // Workout dots
          if (hasWorkout)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...workouts.take(3).map((w) => Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      decoration: BoxDecoration(
                        color: typeColor(w.type),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: typeColor(w.type).withValues(alpha: 0.7),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    )),
                if (workouts.length > 3)
                  Text(
                    '+${workouts.length - 3}',
                    style: GoogleFonts.orbitron(
                      color: TechnoColors.textMuted,
                      fontSize: 7,
                    ),
                  ),
              ],
            )
          else
            const SizedBox(height: 7),
          const SizedBox(height: 2),
          // Step count
          if (showSteps)
            Text(
              _formatSteps(steps!),
              style: GoogleFonts.orbitron(
                color: _stepColor(steps!),
                fontSize: 7,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            const SizedBox(height: 9),
          const SizedBox(height: 2),
          // Calories
          if (showCals)
            Text(
              '${calories!.round()}cal',
              style: GoogleFonts.orbitron(
                color: TechnoColors.neonOrange,
                fontSize: 6,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            const SizedBox(height: 8),
          const SizedBox(height: 2),
          // Water
          if (showWater)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.water_drop,
                    size: 6, color: _waterColor(water)),
                const SizedBox(width: 1),
                Text(
                  _formatWater(water),
                  style: GoogleFonts.orbitron(
                    color: _waterColor(water),
                    fontSize: 6,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            )
          else
            const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ── Week View Sheet ───────────────────────────────────────────────────────────

class _WeekViewSheet extends StatefulWidget {
  final DateTime selectedDate;
  final List<CompletedWorkout> allWorkouts;

  const _WeekViewSheet({
    required this.selectedDate,
    required this.allWorkouts,
  });

  @override
  State<_WeekViewSheet> createState() => _WeekViewSheetState();
}

class _WeekViewSheetState extends State<_WeekViewSheet> {
  final Map<int, int?> _stepsByIndex = {};
  final Map<int, double> _waterByIndex = {};

  DateTime get _weekStart {
    final offset = (widget.selectedDate.weekday - 1) % 7;
    return DateTime(widget.selectedDate.year, widget.selectedDate.month,
        widget.selectedDate.day - offset);
  }

  @override
  void initState() {
    super.initState();
    _loadWeekData();
  }

  Future<void> _loadWeekData() async {
    final ws = _weekStart;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = List.generate(7, (i) => ws.add(Duration(days: i)));

    final stepFutures = <Future<int?>>[];
    final waterFutures = <Future<double>>[];
    final indices = <int>[];
    for (int i = 0; i < 7; i++) {
      if (!days[i].isAfter(today)) {
        stepFutures.add(StepService.stepsForDay(days[i]));
        waterFutures.add(WaterService.getWaterForDay(days[i]));
        indices.add(i);
      }
    }

    final results = await Future.wait([
      Future.wait(stepFutures),
      Future.wait(waterFutures),
    ]);
    if (!mounted) return;
    final steps = results[0] as List<int?>;
    final water = results[1] as List<double>;
    setState(() {
      for (int j = 0; j < indices.length; j++) {
        _stepsByIndex[indices[j]] = steps[j];
        _waterByIndex[indices[j]] = water[j];
      }
    });
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Color _typeColor(WorkoutType t) {
    switch (t) {
      case WorkoutType.strength:
        return TechnoColors.neonCyan;
      case WorkoutType.cardio:
        return TechnoColors.neonGreen;
      case WorkoutType.hiit:
        return TechnoColors.neonPink;
      case WorkoutType.bodyweight:
        return TechnoColors.neonPurple;
      case WorkoutType.mixed:
        return TechnoColors.neonOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ws = _weekStart;
    final we = ws.add(const Duration(days: 6));
    final days = List.generate(7, (i) => ws.add(Duration(days: i)));

    final byIndex = <int, List<CompletedWorkout>>{};
    for (int i = 0; i < 7; i++) {
      byIndex[i] = widget.allWorkouts
          .where((w) => _sameDay(w.startTime, days[i]))
          .toList();
    }

    final totalWorkouts = byIndex.values.fold(0, (s, l) => s + l.length);
    final totalMins = byIndex.values
        .fold(0, (s, l) => s + l.fold(0, (s2, w) => s2 + w.durationMinutes));
    final totalCal = byIndex.values
        .fold(0, (s, l) => s + l.fold(0, (s2, w) => s2 + w.caloriesBurned));
    final totalWaterMl =
        _waterByIndex.values.fold(0.0, (s, v) => s + v);
    final fmtWater = totalWaterMl >= 1000
        ? '${(totalWaterMl / 1000).toStringAsFixed(1)}L'
        : '${totalWaterMl.round()}ml';

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) => Container(
        decoration: BoxDecoration(
          color: TechnoColors.bgSecondary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: TechnoColors.cardBorder),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: TechnoColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Week range
            Text(
              'WEEK  ${DateFormat('d MMM').format(ws).toUpperCase()} – ${DateFormat('d MMM').format(we).toUpperCase()}',
              style: GoogleFonts.orbitron(
                color: TechnoColors.textSecondary,
                fontSize: 11,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            // Summary pills — 2 × 2 grid
            Row(
              children: [
                _WeekStatPill(
                  value: '$totalWorkouts',
                  label: 'SESSIONS',
                  color: TechnoColors.neonCyan,
                ),
                const SizedBox(width: 8),
                _WeekStatPill(
                  value: totalMins >= 60
                      ? '${(totalMins / 60).toStringAsFixed(1)}h'
                      : '${totalMins}m',
                  label: 'ACTIVE',
                  color: TechnoColors.neonGreen,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _WeekStatPill(
                  value: '~$totalCal',
                  label: 'CALS',
                  color: TechnoColors.neonOrange,
                ),
                const SizedBox(width: 8),
                _WeekStatPill(
                  value: fmtWater,
                  label: 'WATER',
                  color: TechnoColors.neonPurple,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Day-by-day rows
            ...List.generate(7, (i) {
              final day = days[i];
              final dayWorkouts = byIndex[i] ?? [];
              return _WeekDayRow(
                date: day,
                workouts: dayWorkouts,
                steps: _stepsByIndex[i],
                water: _waterByIndex[i] ?? 0.0,
                isToday: _sameDay(day, DateTime.now()),
                isSelected: _sameDay(day, widget.selectedDate),
                typeColor: _typeColor,
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Week Stat Pill ────────────────────────────────────────────────────────────

class _WeekStatPill extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _WeekStatPill({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.orbitron(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.rajdhani(
                color: TechnoColors.textMuted,
                fontSize: 9,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Week Day Row ──────────────────────────────────────────────────────────────

class _WeekDayRow extends StatelessWidget {
  final DateTime date;
  final List<CompletedWorkout> workouts;
  final int? steps;
  final double water;
  final bool isToday;
  final bool isSelected;
  final Color Function(WorkoutType) typeColor;

  const _WeekDayRow({
    required this.date,
    required this.workouts,
    required this.steps,
    required this.water,
    required this.isToday,
    required this.isSelected,
    required this.typeColor,
  });

  static Color _stepColor(int s) {
    if (s >= 10000) return TechnoColors.neonGreen;
    if (s >= 7000) return TechnoColors.neonYellow;
    return TechnoColors.textMuted;
  }

  static Color _waterColor(double ml) {
    if (ml >= 2000) return TechnoColors.neonPurple;
    if (ml >= 1000) return TechnoColors.neonPurple.withValues(alpha: 0.7);
    return TechnoColors.textMuted;
  }

  static String _formatSteps(int s) =>
      s >= 1000 ? '${(s / 1000).toStringAsFixed(1)}k' : '$s';

  static String _formatWater(double ml) =>
      ml >= 1000 ? '${(ml / 1000).toStringAsFixed(1)}L' : '${ml.round()}ml';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final isFuture = DateTime(date.year, date.month, date.day).isAfter(today);
    final showSteps = steps != null && steps! > 0 && !isFuture;

    final accentColor = isToday
        ? TechnoColors.neonCyan
        : isSelected
            ? TechnoColors.neonPurple
            : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor != null
                  ? accentColor.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: accentColor ?? TechnoColors.cardBorder,
                width: accentColor != null ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('E').format(date).toUpperCase(),
                  style: GoogleFonts.orbitron(
                    color: accentColor ?? TechnoColors.textMuted,
                    fontSize: 7,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  '${date.day}',
                  style: GoogleFonts.orbitron(
                    color: accentColor ?? TechnoColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (workouts.isNotEmpty)
                  ...workouts.map((w) => _WorkoutPill(
                        workout: w,
                        color: typeColor(w.type),
                      ))
                else
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      isFuture ? '—' : 'Rest day',
                      style: GoogleFonts.rajdhani(
                        color: TechnoColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ),
                if (showSteps) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.directions_walk,
                          size: 11, color: _stepColor(steps!)),
                      const SizedBox(width: 3),
                      Text(
                        '${_formatSteps(steps!)} steps',
                        style: GoogleFonts.rajdhani(
                          color: _stepColor(steps!),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (steps! >= 10000) ...[
                        const SizedBox(width: 4),
                        Text(
                          '✓',
                          style: TextStyle(
                            color: TechnoColors.neonGreen,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
                if (water > 0 && !isFuture) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.water_drop,
                          size: 11, color: _waterColor(water)),
                      const SizedBox(width: 3),
                      Text(
                        '${_formatWater(water)} water',
                        style: GoogleFonts.rajdhani(
                          color: _waterColor(water),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (water >= 2000) ...[
                        const SizedBox(width: 4),
                        Text(
                          '✓',
                          style: TextStyle(
                            color: TechnoColors.neonPurple,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Workout Pill ──────────────────────────────────────────────────────────────

class _WorkoutPill extends StatelessWidget {
  final CompletedWorkout workout;
  final Color color;

  const _WorkoutPill({required this.workout, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Text(workout.type.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workout.name,
                  style: GoogleFonts.rajdhani(
                    color: TechnoColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${workout.durationMinutes} min · ${workout.exercises.length} exercises',
                  style: GoogleFonts.rajdhani(
                    color: TechnoColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            DateFormat('HH:mm').format(workout.startTime),
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
