import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/step_provider.dart';
import '../services/step_service.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_card.dart';

class CaloriesScreen extends StatelessWidget {
  const CaloriesScreen({super.key});

  static final _numFmt = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ActivityRingsProvider>();
    final kcal = p.caloriesKcal ?? 0;
    final goal = ActivityRingsProvider.caloriesGoal;
    final entries = p.calorieEntries;
    final progress = p.caloriesProgress.clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TechnoColors.neonOrange),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'CALORIES',
          style: GoogleFonts.orbitron(
            color: TechnoColors.textPrimary,
            fontSize: 14,
            letterSpacing: 2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Summary card ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: NeonCard(
                borderColor: TechnoColors.neonOrange,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TODAY',
                            style: GoogleFonts.orbitron(
                              color: TechnoColors.textSecondary,
                              fontSize: 10,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  _numFmt.format(kcal.round()),
                                  style: GoogleFonts.orbitron(
                                    color: TechnoColors.neonOrange,
                                    fontSize: 52,
                                    fontWeight: FontWeight.w900,
                                    height: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 8, left: 6),
                                  child: Text(
                                    '/ ${_numFmt.format(goal.round())}',
                                    style: GoogleFonts.rajdhani(
                                      color: TechnoColors.neonOrange
                                          .withValues(alpha: 0.5),
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'KCAL BURNED',
                            style: GoogleFonts.rajdhani(
                              color: TechnoColors.textSecondary,
                              fontSize: 12,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _MiniRing(progress: progress),
                  ],
                ),
              ),
            ),
          ),

          // ── Section header ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Text(
                "TODAY'S CALORIE LOG",
                style: GoogleFonts.orbitron(
                  color: TechnoColors.textSecondary,
                  fontSize: 11,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),

          // ── Entry list ────────────────────────────────────────────────────
          if (entries.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: NeonCard(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'NO CALORIE DATA RECORDED TODAY',
                        style: GoogleFonts.rajdhani(
                          color: TechnoColors.textMuted,
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                  child: _CalorieEntryTile(entry: entries[i]),
                ),
                childCount: entries.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

// ── Mini ring ─────────────────────────────────────────────────────────────────

class _MiniRing extends StatelessWidget {
  final double progress;
  const _MiniRing({required this.progress});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: CustomPaint(painter: _MiniRingPainter(progress: progress)),
    );
  }
}

class _MiniRingPainter extends CustomPainter {
  final double progress;
  const _MiniRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 5;
    const color = TechnoColors.neonOrange;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9,
    );

    if (progress <= 0) return;

    final sweep = (progress * 2 * pi).clamp(0.0, 2 * pi);
    final rect = Rect.fromCircle(center: center, radius: radius);

    canvas.drawArc(
      rect,
      -pi / 2,
      sweep,
      false,
      Paint()
        ..color = color.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawArc(
      rect,
      -pi / 2,
      sweep,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_MiniRingPainter old) => old.progress != progress;
}

// ── Calorie entry tile ────────────────────────────────────────────────────────

class _CalorieEntryTile extends StatelessWidget {
  final CalorieEntry entry;
  const _CalorieEntryTile({required this.entry});

  static final _numFmt = NumberFormat('#,###');
  static final _timeFmt = DateFormat('h:mm a');

  @override
  Widget build(BuildContext context) {
    const color = TechnoColors.neonOrange;
    final sameMinute = entry.start.difference(entry.end).abs().inMinutes < 2;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.local_fire_department,
                color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CALORIES BURNED',
                  style: GoogleFonts.orbitron(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sameMinute
                      ? _timeFmt.format(entry.start)
                      : '${_timeFmt.format(entry.start)} – ${_timeFmt.format(entry.end)}',
                  style: GoogleFonts.rajdhani(
                    color: TechnoColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${_numFmt.format(entry.kcal.round())} kcal',
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
