import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import '../providers/step_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/mini_ring.dart';
import '../widgets/neon_card.dart';

class WaterScreen extends StatelessWidget {
  const WaterScreen({super.key});

  // ml amounts; labels are chosen per-unit in build()
  static const _quickAddMl = [150.0, 250.0, 500.0];
  static const _mlPerFlOz = 29.5735;
  static const _mlPerCup = 240.0;

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ActivityRingsProvider>();
    final unit = context.watch<AppProvider>().data.profile.waterUnit;
    final waterMl = p.waterMl ?? 0;
    final goalMl = p.waterGoalMl;
    final entries = p.waterEntries;
    final progress = p.waterProgress.clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: TechnoColors.neonPurple),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'WATER',
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
                borderColor: TechnoColors.neonPurple,
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
                                  _fmtPrimary(waterMl, unit),
                                  style: GoogleFonts.orbitron(
                                    color: TechnoColors.neonPurple,
                                    fontSize: 52,
                                    fontWeight: FontWeight.w900,
                                    height: 1,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 8, left: 6),
                                  child: Text(
                                    '/ ${_fmtPrimary(goalMl, unit)}',
                                    style: GoogleFonts.rajdhani(
                                      color: TechnoColors.neonPurple
                                          .withValues(alpha: 0.5),
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _fmtSecondary(waterMl, unit),
                            style: GoogleFonts.rajdhani(
                              color: TechnoColors.neonPurple
                                  .withValues(alpha: 0.55),
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            'HYDRATION',
                            style: GoogleFonts.rajdhani(
                              color: TechnoColors.textSecondary,
                              fontSize: 12,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    MiniRing(progress: progress, color: TechnoColors.neonPurple),
                  ],
                ),
              ),
            ),
          ),

          // ── Quick-add buttons ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Row(
                children: _quickAddMl.map((ml) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: ml == _quickAddMl.last ? 0 : 8,
                      ),
                      child: _QuickAddButton(
                        ml: ml,
                        unit: unit,
                        onTap: () =>
                            context.read<ActivityRingsProvider>().addWater(ml),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Section header ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
              child: Text(
                "TODAY'S WATER LOG",
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
                        'NO WATER LOGGED TODAY',
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
                (ctx, i) {
                  // Display newest-first; map back to chronological index for removal.
                  final storedIndex = entries.length - 1 - i;
                  final entry = entries[storedIndex];
                  return Dismissible(
                    key: ValueKey(entry.time.toIso8601String()),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => context
                        .read<ActivityRingsProvider>()
                        .removeWaterEntry(storedIndex),
                    background: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.red.withValues(alpha: 0.5)),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 16),
                      child: const Icon(Icons.delete_outline,
                          color: Colors.red, size: 22),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 3),
                      child: _WaterEntryTile(entry: entry, unit: unit),
                    ),
                  );
                },
                childCount: entries.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  /// Big number rendered in the user's chosen unit.
  static String _fmtPrimary(double ml, WaterUnit unit) {
    switch (unit) {
      case WaterUnit.ml:
        if (ml >= 1000) return '${(ml / 1000).toStringAsFixed(1)}L';
        return '${ml.round()}ml';
      case WaterUnit.flOz:
        return '${(ml / _mlPerFlOz).toStringAsFixed(1)} fl oz';
      case WaterUnit.cups:
        return '${(ml / _mlPerCup).toStringAsFixed(1)} cups';
    }
  }

  /// Subtitle rendered in the *other* unit so users can sanity-check.
  static String _fmtSecondary(double ml, WaterUnit unit) {
    switch (unit) {
      case WaterUnit.ml:
        return '${(ml / _mlPerFlOz).toStringAsFixed(1)} fl oz · '
            '${(ml / _mlPerCup).toStringAsFixed(1)} cups';
      case WaterUnit.flOz:
      case WaterUnit.cups:
        if (ml >= 1000) return '${(ml / 1000).toStringAsFixed(1)} L';
        return '${ml.round()} ml';
    }
  }
}

// ── Quick-add button ──────────────────────────────────────────────────────────

class _QuickAddButton extends StatelessWidget {
  final double ml;
  final WaterUnit unit;
  final VoidCallback onTap;

  const _QuickAddButton({
    required this.ml,
    required this.unit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const color = TechnoColors.neonPurple;
    final primary = '+${WaterScreen._fmtPrimary(ml, unit)}';
    final secondary = WaterScreen._fmtSecondary(ml, unit);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              primary,
              style: GoogleFonts.orbitron(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              secondary,
              style: GoogleFonts.rajdhani(
                color: color.withValues(alpha: 0.6),
                fontSize: 10,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Water entry tile ──────────────────────────────────────────────────────────

class _WaterEntryTile extends StatelessWidget {
  final WaterEntry entry;
  final WaterUnit unit;
  const _WaterEntryTile({required this.entry, required this.unit});

  static final _timeFmt = DateFormat('h:mm a');

  @override
  Widget build(BuildContext context) {
    const color = TechnoColors.neonPurple;

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
            child: const Icon(Icons.water_drop, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WATER',
                  style: GoogleFonts.orbitron(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _timeFmt.format(entry.time),
                  style: GoogleFonts.rajdhani(
                    color: TechnoColors.textSecondary,
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
                WaterScreen._fmtPrimary(entry.ml, unit),
                style: GoogleFonts.orbitron(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                WaterScreen._fmtSecondary(entry.ml, unit),
                style: GoogleFonts.rajdhani(
                  color: color.withValues(alpha: 0.55),
                  fontSize: 10,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
