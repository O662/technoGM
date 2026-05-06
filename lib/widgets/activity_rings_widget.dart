import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/step_provider.dart';
import '../screens/active_minutes_screen.dart';
import '../screens/calories_screen.dart';
import '../screens/steps_screen.dart';
import '../screens/water_screen.dart';
import '../theme/app_theme.dart';

class ActivityRingsWidget extends StatefulWidget {
  const ActivityRingsWidget({super.key});

  @override
  State<ActivityRingsWidget> createState() => _ActivityRingsWidgetState();
}

class _ActivityRingsWidgetState extends State<ActivityRingsWidget>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _ctrl;
  ActivityRingsProvider? _provider;
  RingsStatus? _lastStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ActivityRingsProvider>().refresh();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provider?.removeListener(_onData);
    _provider = context.read<ActivityRingsProvider>()..addListener(_onData);
    _onData();
    _syncPolling();
  }

  void _syncPolling() {
    if (TickerMode.of(context)) {
      _provider?.startAutoRefresh();
    } else {
      _provider?.stopAutoRefresh();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (TickerMode.of(context)) _provider?.startAutoRefresh();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _provider?.stopAutoRefresh();
    }
  }

  void _onData() {
    if (!mounted) return;
    final status = _provider?.status;
    // Only run the fill animation when status first transitions to granted.
    // For incremental updates (addWater, auto-refresh) the controller stays at
    // t=1.0 and context.watch rebuilds the rings with the new values directly.
    if (status == RingsStatus.granted && _lastStatus != RingsStatus.granted) {
      _ctrl.forward(from: 0);
    }
    _lastStatus = status;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _provider?.removeListener(_onData);
    _provider?.stopAutoRefresh();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ActivityRingsProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          SizedBox(
            height: 210,
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (_, _) {
                final t = Curves.easeOutCubic.transform(_ctrl.value);
                return CustomPaint(
                  painter: _RingsPainter(
                    stepsP: (p.stepsProgress * t).clamp(0.0, 1.0),
                    activeP: (p.activeMinutesProgress * t).clamp(0.0, 1.0),
                    calsP: (p.caloriesProgress * t).clamp(0.0, 1.0),
                    waterP: (p.waterProgress * t).clamp(0.0, 1.0),
                  ),
                  size: Size.infinite,
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              _Pill(
                color: TechnoColors.neonCyan,
                label: 'STEPS',
                value: _fmtSteps(p.steps),
                goal: '10K',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const StepsScreen()),
                ),
              ),
              const SizedBox(width: 6),
              _Pill(
                color: TechnoColors.neonGreen,
                label: 'ACTIVE',
                value: p.activeMinutes != null ? '${p.activeMinutes}m' : '--',
                goal: '30m',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const ActiveMinutesScreen()),
                ),
              ),
              const SizedBox(width: 6),
              _Pill(
                color: TechnoColors.neonOrange,
                label: 'CALS',
                value: p.caloriesKcal != null
                    ? '${p.caloriesKcal!.round()}'
                    : '--',
                goal: '2K',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const CaloriesScreen()),
                ),
              ),
              const SizedBox(width: 6),
              _Pill(
                color: TechnoColors.neonPurple,
                label: 'WATER',
                value: _fmtWater(p.waterMl),
                goal: '2L',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WaterScreen()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            p.lastSynced != null
                ? 'LAST SYNCED ${DateFormat('h:mm a').format(p.lastSynced!)}'
                : 'SYNCING...',
            style: GoogleFonts.rajdhani(
              color: TechnoColors.textMuted,
              fontSize: 10,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static final _numFmt = NumberFormat('#,###');

  static String _fmtSteps(int? s) => s != null ? _numFmt.format(s) : '--';

  static String _fmtWater(double? ml) {
    if (ml == null) return '--';
    if (ml >= 1000) return '${(ml / 1000).toStringAsFixed(1)}L';
    return '${ml.round()}ml';
  }
}

// ── Stat pill ─────────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  final String goal;
  final VoidCallback? onTap;

  const _Pill({
    required this.color,
    required this.label,
    required this.value,
    required this.goal,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 11),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          color: color.withValues(alpha: 0.7), blurRadius: 4),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  goal,
                  style: GoogleFonts.rajdhani(
                    color: color.withValues(alpha: 0.5),
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: GoogleFonts.orbitron(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.rajdhani(
                color: TechnoColors.textSecondary,
                fontSize: 9,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

// ── Rings painter ─────────────────────────────────────────────────────────────

class _RingsPainter extends CustomPainter {
  final double stepsP;
  final double activeP;
  final double calsP;
  final double waterP;

  const _RingsPainter({
    required this.stepsP,
    required this.activeP,
    required this.calsP,
    required this.waterP,
  });

  static const double _stroke = 13.0;
  static const double _gap = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = min(size.width, size.height) / 2 - _stroke / 2 - 2;

    // Outermost → innermost: steps, active, calories, water
    _drawRing(canvas, center, maxR, stepsP, TechnoColors.neonCyan);
    _drawRing(
        canvas, center, maxR - (_stroke + _gap), activeP, TechnoColors.neonGreen);
    _drawRing(
        canvas, center, maxR - 2 * (_stroke + _gap), calsP, TechnoColors.neonOrange);
    _drawRing(
        canvas, center, maxR - 3 * (_stroke + _gap), waterP, TechnoColors.neonPurple);
  }

  void _drawRing(
      Canvas canvas, Offset center, double radius, double progress, Color color) {
    // Background track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color.withValues(alpha: 0.13)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke,
    );

    if (progress <= 0) return;

    final sweep = progress * 2 * pi;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Soft glow halo behind the arc
    canvas.drawArc(
      rect,
      -pi / 2,
      sweep,
      false,
      Paint()
        ..color = color.withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke + 7
        ..strokeCap = StrokeCap.round,
    );

    // Main colored arc
    canvas.drawArc(
      rect,
      -pi / 2,
      sweep,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_RingsPainter old) =>
      old.stepsP != stepsP ||
      old.activeP != activeP ||
      old.calsP != calsP ||
      old.waterP != waterP;
}
