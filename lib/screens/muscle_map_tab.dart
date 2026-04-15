import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

// ── Data model ────────────────────────────────────────────────────────────────

class _MuscleRegion {
  final String name;
  final String scientificName;
  final List<Rect> rects; // virtual 100×240 coordinate space
  final Color color;

  const _MuscleRegion(this.name, this.scientificName, this.rects, this.color);
}

// ── Virtual canvas dimensions ─────────────────────────────────────────────────

const double _vw = 100.0;
const double _vh = 240.0;

// ── Muscle region definitions ─────────────────────────────────────────────────

final List<_MuscleRegion> _frontMuscles = [
  _MuscleRegion('Shoulders', 'Anterior Deltoids', [
    Rect.fromLTWH(19, 30, 14, 18),
    Rect.fromLTWH(67, 30, 14, 18),
  ], TechnoColors.neonPurple),
  _MuscleRegion('Chest', 'Pectorals', [
    Rect.fromLTWH(33, 35, 17, 19),
    Rect.fromLTWH(50, 35, 17, 19),
  ], TechnoColors.neonCyan),
  _MuscleRegion('Biceps', 'Bicep Brachii', [
    Rect.fromLTWH(16, 48, 12, 24),
    Rect.fromLTWH(72, 48, 12, 24),
  ], TechnoColors.neonPink),
  _MuscleRegion('Forearms', 'Brachioradialis', [
    Rect.fromLTWH(14, 74, 12, 28),
    Rect.fromLTWH(74, 74, 12, 28),
  ], TechnoColors.neonOrange),
  _MuscleRegion('Abs', 'Rectus Abdominis', [
    Rect.fromLTWH(39, 55, 22, 33),
  ], TechnoColors.neonGreen),
  _MuscleRegion('Obliques', 'External Obliques', [
    Rect.fromLTWH(31, 56, 9, 27),
    Rect.fromLTWH(60, 56, 9, 27),
  ], TechnoColors.neonYellow),
  _MuscleRegion('Abductors', 'Hip Abductors', [
    Rect.fromLTWH(26, 100, 12, 22),
    Rect.fromLTWH(62, 100, 12, 22),
  ], TechnoColors.neonPurple),
  _MuscleRegion('Quads', 'Quadriceps', [
    Rect.fromLTWH(31, 118, 16, 50),
    Rect.fromLTWH(53, 118, 16, 50),
  ], TechnoColors.neonCyan),
  _MuscleRegion('Calves', 'Gastrocnemius', [
    Rect.fromLTWH(31, 174, 15, 38),
    Rect.fromLTWH(54, 174, 15, 38),
  ], TechnoColors.neonPink),
];

final List<_MuscleRegion> _backMuscles = [
  _MuscleRegion('Traps', 'Trapezius', [
    Rect.fromLTWH(36, 28, 28, 20),
  ], TechnoColors.neonCyan),
  _MuscleRegion('Rear Delts', 'Posterior Deltoids', [
    Rect.fromLTWH(19, 30, 14, 16),
    Rect.fromLTWH(67, 30, 14, 16),
  ], TechnoColors.neonPurple),
  _MuscleRegion('Triceps', 'Tricep Brachii', [
    Rect.fromLTWH(16, 48, 12, 24),
    Rect.fromLTWH(72, 48, 12, 24),
  ], TechnoColors.neonPink),
  _MuscleRegion('Forearms', 'Brachioradialis', [
    Rect.fromLTWH(14, 74, 12, 28),
    Rect.fromLTWH(74, 74, 12, 28),
  ], TechnoColors.neonOrange),
  _MuscleRegion('Lats', 'Latissimus Dorsi', [
    Rect.fromLTWH(27, 50, 13, 36),
    Rect.fromLTWH(60, 50, 13, 36),
  ], TechnoColors.neonGreen),
  _MuscleRegion('Mid Back', 'Rhomboids', [
    Rect.fromLTWH(38, 48, 24, 18),
  ], TechnoColors.neonYellow),
  _MuscleRegion('Lower Back', 'Erector Spinae', [
    Rect.fromLTWH(38, 70, 24, 22),
  ], TechnoColors.neonCyan),
  _MuscleRegion('Glutes', 'Gluteus Maximus', [
    Rect.fromLTWH(32, 96, 18, 20),
    Rect.fromLTWH(50, 96, 18, 20),
  ], TechnoColors.neonYellow),
  _MuscleRegion('Hamstrings', 'Bicep Femoris', [
    Rect.fromLTWH(31, 118, 16, 48),
    Rect.fromLTWH(53, 118, 16, 48),
  ], TechnoColors.neonPurple),
  _MuscleRegion('Calves', 'Gastrocnemius', [
    Rect.fromLTWH(31, 172, 15, 38),
    Rect.fromLTWH(54, 172, 15, 38),
  ], TechnoColors.neonPink),
];

// ── Main widget ───────────────────────────────────────────────────────────────

class MuscleMapTab extends StatefulWidget {
  const MuscleMapTab({super.key});

  @override
  State<MuscleMapTab> createState() => _MuscleMapTabState();
}

class _MuscleMapTabState extends State<MuscleMapTab> {
  bool _showFront = true;
  String? _selected;

  List<_MuscleRegion> get _regions =>
      _showFront ? _frontMuscles : _backMuscles;

  _MuscleRegion? get _selectedRegion =>
      _selected == null
          ? null
          : _regions.cast<_MuscleRegion?>().firstWhere(
              (r) => r!.name == _selected,
              orElse: () => null,
            );

  void _onTapDown(TapDownDetails details, Size canvasSize) {
    final vx = details.localPosition.dx * _vw / canvasSize.width;
    final vy = details.localPosition.dy * _vh / canvasSize.height;
    final tap = Offset(vx, vy);

    String? hit;
    // Iterate reversed so topmost-drawn region wins
    for (final r in _regions.reversed) {
      if (r.rects.any((rect) => rect.contains(tap))) {
        hit = r.name;
        break;
      }
    }
    setState(() => _selected = (hit == _selected) ? null : hit);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Front / Back toggle ───────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ToggleBtn(
                label: 'FRONT',
                active: _showFront,
                onTap: () => setState(() {
                  _showFront = true;
                  _selected = null;
                }),
              ),
              const SizedBox(width: 12),
              _ToggleBtn(
                label: 'BACK',
                active: !_showFront,
                onTap: () => setState(() {
                  _showFront = false;
                  _selected = null;
                }),
              ),
            ],
          ),
        ),

        // ── Body diagram ──────────────────────────────────────────────────
        Expanded(
          child: LayoutBuilder(
            builder: (ctx, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              return GestureDetector(
                onTapDown: (d) => _onTapDown(d, size),
                behavior: HitTestBehavior.opaque,
                child: CustomPaint(
                  size: size,
                  painter: _BodyPainter(
                    regions: _regions,
                    selected: _selected,
                    isFront: _showFront,
                  ),
                ),
              );
            },
          ),
        ),

        // ── Info panel ────────────────────────────────────────────────────
        _InfoPanel(region: _selectedRegion),
      ],
    );
  }
}

// ── Toggle button ─────────────────────────────────────────────────────────────

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleBtn({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? TechnoColors.neonCyan.withValues(alpha: 0.15)
              : TechnoColors.bgTertiary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? TechnoColors.neonCyan : TechnoColors.cardBorder,
            width: active ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.orbitron(
            color:
                active ? TechnoColors.neonCyan : TechnoColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}

// ── Info panel ────────────────────────────────────────────────────────────────

class _InfoPanel extends StatelessWidget {
  final _MuscleRegion? region;
  const _InfoPanel({required this.region});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: TechnoColors.bgSecondary,
        border: Border(
          top: BorderSide(color: TechnoColors.cardBorder),
        ),
      ),
      child: region == null
          ? Center(
              child: Text(
                'TAP A MUSCLE GROUP TO SELECT',
                style: GoogleFonts.orbitron(
                  color: TechnoColors.textMuted,
                  fontSize: 9,
                  letterSpacing: 2,
                ),
              ),
            )
          : Row(
              children: [
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: region!.color,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: region!.color.withValues(alpha: 0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      region!.name.toUpperCase(),
                      style: GoogleFonts.orbitron(
                        color: region!.color,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      region!.scientificName,
                      style: GoogleFonts.rajdhani(
                        color: TechnoColors.textSecondary,
                        fontSize: 13,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}

// ── Body painter ──────────────────────────────────────────────────────────────

class _BodyPainter extends CustomPainter {
  final List<_MuscleRegion> regions;
  final String? selected;
  final bool isFront;

  const _BodyPainter({
    required this.regions,
    required this.selected,
    required this.isFront,
  });

  // Scale virtual → canvas
  double _x(double v, Size s) => v * s.width / _vw;
  double _y(double v, Size s) => v * s.height / _vh;

  Offset _o(double vx, double vy, Size s) => Offset(_x(vx, s), _y(vy, s));

  Rect _r(Rect r, Size s) => Rect.fromLTWH(
        _x(r.left, s),
        _y(r.top, s),
        _x(r.width, s),
        _y(r.height, s),
      );

  RRect _rr(Rect r, Size s, double radius) =>
      RRect.fromRectAndRadius(_r(r, s), Radius.circular(_x(radius, s)));

  @override
  void paint(Canvas canvas, Size size) {
    _drawGrid(canvas, size);
    _drawBodyOutline(canvas, size);
    _drawMuscles(canvas, size);
    _drawLabels(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = TechnoColors.neonCyan.withValues(alpha: 0.025)
      ..strokeWidth = 0.5;
    const spacing = 20.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawBodyOutline(Canvas canvas, Size size) {
    final p = Paint()
      ..color = TechnoColors.neonCyan.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Head
    canvas.drawOval(
      Rect.fromCenter(center: _o(50, 12, size), width: _x(18, size), height: _y(20, size)),
      p,
    );

    // Neck
    canvas.drawRRect(_rr(Rect.fromLTWH(44, 22, 12, 9), size, 2), p);

    // Torso path
    final torso = Path()
      ..moveTo(_x(21, size), _y(31, size))
      ..lineTo(_x(79, size), _y(31, size))
      ..lineTo(_x(68, size), _y(92, size))
      ..lineTo(_x(72, size), _y(114, size))
      ..lineTo(_x(28, size), _y(114, size))
      ..lineTo(_x(32, size), _y(92, size))
      ..close();
    canvas.drawPath(torso, p);

    // Upper arms
    canvas.drawRRect(_rr(Rect.fromLTWH(14, 31, 13, 40), size, 5), p);
    canvas.drawRRect(_rr(Rect.fromLTWH(73, 31, 13, 40), size, 5), p);

    // Forearms
    canvas.drawRRect(_rr(Rect.fromLTWH(13, 73, 12, 30), size, 5), p);
    canvas.drawRRect(_rr(Rect.fromLTWH(75, 73, 12, 30), size, 5), p);

    // Hands
    canvas.drawOval(
      Rect.fromLTWH(_x(13, size), _y(105, size), _x(11, size), _y(8, size)), p);
    canvas.drawOval(
      Rect.fromLTWH(_x(76, size), _y(105, size), _x(11, size), _y(8, size)), p);

    // Thighs
    canvas.drawRRect(_rr(Rect.fromLTWH(30, 114, 18, 56), size, 5), p);
    canvas.drawRRect(_rr(Rect.fromLTWH(52, 114, 18, 56), size, 5), p);

    // Calves
    canvas.drawRRect(_rr(Rect.fromLTWH(30, 172, 17, 40), size, 5), p);
    canvas.drawRRect(_rr(Rect.fromLTWH(53, 172, 17, 40), size, 5), p);

    // Feet
    canvas.drawOval(
      Rect.fromLTWH(_x(27, size), _y(214, size), _x(22, size), _y(9, size)), p);
    canvas.drawOval(
      Rect.fromLTWH(_x(51, size), _y(214, size), _x(22, size), _y(9, size)), p);
  }

  void _drawMuscles(Canvas canvas, Size size) {
    for (final region in regions) {
      final isSelected = region.name == selected;
      final color = region.color;
      const radius = 3.0;

      for (final r in region.rects) {
        final rr = _rr(r, size, radius);

        // Outer glow when selected
        if (isSelected) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              _r(r, size).inflate(_x(3, size)),
              Radius.circular(_x(radius + 2, size)),
            ),
            Paint()
              ..color = color.withValues(alpha: 0.25)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
          );
        }

        // Fill
        canvas.drawRRect(
          rr,
          Paint()
            ..color = isSelected
                ? color.withValues(alpha: 0.38)
                : color.withValues(alpha: 0.08),
        );

        // Border
        canvas.drawRRect(
          rr,
          Paint()
            ..color = isSelected ? color : color.withValues(alpha: 0.40)
            ..style = PaintingStyle.stroke
            ..strokeWidth = isSelected ? 1.5 : 0.8,
        );
      }
    }
  }

  void _drawLabels(Canvas canvas, Size size) {
    for (final region in regions) {
      if (region.rects.isEmpty) continue;
      final isSelected = region.name == selected;

      // Only show label for selected OR draw a tiny dot indicator otherwise
      if (isSelected) {
        // Draw label near the first rect
        final r = _r(region.rects.first, size);
        final center = r.center;

        final tp = TextPainter(
          text: TextSpan(
            text: region.name.toUpperCase(),
            style: TextStyle(
              color: region.color,
              fontSize: _x(4.5, size).clamp(8.0, 11.0),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: region.color.withValues(alpha: 0.8),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        // Position above the first rect
        tp.paint(
          canvas,
          Offset(center.dx - tp.width / 2, r.top - tp.height - _y(1, size)),
        );
      } else {
        // Small dot at center of first rect to hint tappability
        final c = _r(region.rects.first, size).center;
        canvas.drawCircle(
          c,
          _x(1.2, size),
          Paint()..color = region.color.withValues(alpha: 0.6),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BodyPainter old) =>
      old.selected != selected || old.isFront != isFront;
}
