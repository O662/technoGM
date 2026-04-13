import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/exercise_database.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_card.dart';

class EquipmentGuideScreen extends StatelessWidget {
  const EquipmentGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EQUIPMENT GUIDE')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: kEquipmentGuides.length,
        itemBuilder: (ctx, i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _EquipmentCard(guide: kEquipmentGuides[i]),
        ),
      ),
    );
  }
}

class _EquipmentCard extends StatefulWidget {
  final EquipmentGuide guide;
  const _EquipmentCard({required this.guide});

  @override
  State<_EquipmentCard> createState() => _EquipmentCardState();
}

class _EquipmentCardState extends State<_EquipmentCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final g = widget.guide;

    return NeonCard(
      padding: EdgeInsets.zero,
      borderColor: _expanded ? TechnoColors.neonCyan.withValues(alpha: 0.5) : TechnoColors.cardBorder,
      child: Column(
        children: [
          // ── Header ───────────────────────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Text(g.icon, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          g.name,
                          style: GoogleFonts.rajdhani(
                            color: TechnoColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Wrap(
                          spacing: 6,
                          children: g.musclesTargeted
                              .take(3)
                              .map(
                                (m) => Text(
                                  m,
                                  style: GoogleFonts.rajdhani(
                                    color: TechnoColors.neonCyan,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: TechnoColors.textMuted,
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded Content ──────────────────────────────────────────────
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    g.description,
                    style: GoogleFonts.rajdhani(
                      color: TechnoColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Setup
                  _GuideSection(
                    icon: Icons.build_outlined,
                    title: 'HOW TO SET UP',
                    items: g.setupSteps,
                    color: TechnoColors.neonCyan,
                  ),
                  const SizedBox(height: 12),

                  // Tips
                  _GuideSection(
                    icon: Icons.lightbulb_outline,
                    title: 'TIPS',
                    items: g.usageTips,
                    color: TechnoColors.neonYellow,
                  ),
                  const SizedBox(height: 12),

                  // Mistakes
                  _GuideSection(
                    icon: Icons.warning_amber_outlined,
                    title: 'COMMON MISTAKES',
                    items: g.commonMistakes,
                    color: TechnoColors.neonOrange,
                  ),
                  const SizedBox(height: 12),

                  // Safety
                  _GuideSection(
                    icon: Icons.shield_outlined,
                    title: 'SAFETY',
                    items: g.safetyRules,
                    color: TechnoColors.neonPink,
                  ),
                  const SizedBox(height: 12),

                  // Sample exercises
                  _SectionHeader(label: 'EXERCISES YOU CAN DO'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: g.sampleExercises
                        .map(
                          (e) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: TechnoColors.neonGreen.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: TechnoColors.neonGreen.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Text(
                              e,
                              style: GoogleFonts.rajdhani(
                                color: TechnoColors.neonGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _GuideSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;
  final Color color;

  const _GuideSection({
    required this.icon,
    required this.title,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(
              title,
              style: GoogleFonts.orbitron(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ...items.asMap().entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '${e.key + 1}',
                        style: GoogleFonts.orbitron(
                          color: color,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e.value,
                    style: GoogleFonts.rajdhani(
                      color: TechnoColors.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: GoogleFonts.orbitron(
      color: TechnoColors.textSecondary,
      fontSize: 10,
      letterSpacing: 1.5,
    ),
  );
}
