import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_card.dart';

enum _UnitSystem { metric, imperial, custom }

_UnitSystem _systemFromProfile(UserProfile p) {
  if (p.preferKg && p.preferCm && p.waterUnit == WaterUnit.ml) return _UnitSystem.metric;
  if (!p.preferKg && !p.preferCm &&
      (p.waterUnit == WaterUnit.flOz || p.waterUnit == WaterUnit.cups)) {
    return _UnitSystem.imperial;
  }
  return _UnitSystem.custom;
}

class UnitsPreferencesScreen extends StatefulWidget {
  const UnitsPreferencesScreen({super.key});

  @override
  State<UnitsPreferencesScreen> createState() => _UnitsPreferencesScreenState();
}

class _UnitsPreferencesScreenState extends State<UnitsPreferencesScreen> {
  late _UnitSystem _localSystem;

  @override
  void initState() {
    super.initState();
    _localSystem = _systemFromProfile(context.read<AppProvider>().data.profile);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final profile = provider.data.profile;

    return Scaffold(
      appBar: AppBar(title: const Text('UNITS')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionLabel(label: 'UNIT SYSTEM'),
          const SizedBox(height: 8),

          // ── Metric ──────────────────────────────────────────────────────────
          _SystemTile(
            title: 'Metric',
            subtitle: 'Centimetres · Kilograms · Millilitres',
            icon: Icons.straighten,
            selected: _localSystem == _UnitSystem.metric,
            accentColor: TechnoColors.neonCyan,
            onTap: () {
              setState(() => _localSystem = _UnitSystem.metric);
              _apply(provider, profile,
                  preferKg: true, preferCm: true, waterUnit: WaterUnit.ml);
            },
          ),
          const SizedBox(height: 8),

          // ── Imperial ────────────────────────────────────────────────────────
          _SystemTile(
            title: 'Imperial',
            subtitle: 'Feet & Inches · Pounds · Fl oz or Cups',
            icon: Icons.flag_outlined,
            selected: _localSystem == _UnitSystem.imperial,
            accentColor: TechnoColors.neonPurple,
            onTap: () {
              setState(() => _localSystem = _UnitSystem.imperial);
              // Keep water choice if already imperial, otherwise default fl oz
              final wUnit = (_localSystem == _UnitSystem.imperial &&
                      profile.waterUnit == WaterUnit.cups)
                  ? WaterUnit.cups
                  : WaterUnit.flOz;
              _apply(provider, profile,
                  preferKg: false, preferCm: false, waterUnit: wUnit);
            },
          ),
          if (_localSystem == _UnitSystem.imperial) ...[
            const SizedBox(height: 8),
            NeonCard(
              padding: EdgeInsets.zero,
              borderColor: TechnoColors.neonPurple.withValues(alpha: 0.4),
              child: _CustomUnitRow(
                label: 'Water',
                icon: Icons.water_drop_outlined,
                options: const ['fl oz', 'cups'],
                selected: profile.waterUnit == WaterUnit.cups ? 1 : 0,
                accentColor: TechnoColors.neonPurple,
                onSelect: (i) => _apply(provider, profile,
                    preferKg: false,
                    preferCm: false,
                    waterUnit: i == 0 ? WaterUnit.flOz : WaterUnit.cups),
              ),
            ),
          ],
          const SizedBox(height: 8),

          // ── Custom ──────────────────────────────────────────────────────────
          _SystemTile(
            title: 'Custom',
            subtitle: 'Mix and match units',
            icon: Icons.tune,
            selected: _localSystem == _UnitSystem.custom,
            accentColor: TechnoColors.neonOrange,
            onTap: () => setState(() => _localSystem = _UnitSystem.custom),
          ),
          if (_localSystem == _UnitSystem.custom) ...[
            const SizedBox(height: 8),
            NeonCard(
              padding: EdgeInsets.zero,
              borderColor: TechnoColors.neonOrange.withValues(alpha: 0.4),
              child: Column(
                children: [
                  _CustomUnitRow(
                    label: 'Weight',
                    icon: Icons.monitor_weight_outlined,
                    options: const ['kg', 'lbs'],
                    selected: profile.preferKg ? 0 : 1,
                    accentColor: TechnoColors.neonOrange,
                    onSelect: (i) => _apply(provider, profile,
                        preferKg: i == 0,
                        preferCm: profile.preferCm,
                        waterUnit: profile.waterUnit),
                  ),
                  const Divider(height: 1),
                  _CustomUnitRow(
                    label: 'Height',
                    icon: Icons.height,
                    options: const ['cm', 'ft & in'],
                    selected: profile.preferCm ? 0 : 1,
                    accentColor: TechnoColors.neonOrange,
                    onSelect: (i) => _apply(provider, profile,
                        preferKg: profile.preferKg,
                        preferCm: i == 0,
                        waterUnit: profile.waterUnit),
                  ),
                  const Divider(height: 1),
                  _CustomUnitRow(
                    label: 'Water',
                    icon: Icons.water_drop_outlined,
                    options: const ['ml', 'fl oz', 'cups'],
                    selected: profile.waterUnit == WaterUnit.ml
                        ? 0
                        : profile.waterUnit == WaterUnit.flOz
                            ? 1
                            : 2,
                    accentColor: TechnoColors.neonOrange,
                    onSelect: (i) => _apply(provider, profile,
                        preferKg: profile.preferKg,
                        preferCm: profile.preferCm,
                        waterUnit: WaterUnit.values[i]),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
          _SectionLabel(label: 'PREVIEW'),
          const SizedBox(height: 8),
          NeonCard(
            padding: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Builder(builder: (_) {
                final latestKg = provider.latestWeight;
                final weightStr = latestKg == null
                    ? '—'
                    : profile.preferKg
                        ? '${latestKg.toStringAsFixed(1)} kg'
                        : '${(latestKg * 2.20462).toStringAsFixed(1)} lbs';
                final heightStr = () {
                  if (profile.preferCm) return '${profile.heightCm.round()} cm';
                  final totalIn = (profile.heightCm / 2.54).round();
                  return "${totalIn ~/ 12}'${totalIn % 12}\"";
                }();
                return Row(
                  children: [
                    Expanded(
                      child: _PreviewItem(
                        label: 'WEIGHT',
                        value: weightStr,
                      ),
                    ),
                    Container(width: 1, height: 36, color: TechnoColors.cardBorder),
                    Expanded(
                      child: _PreviewItem(
                        label: 'HEIGHT',
                        value: heightStr,
                      ),
                    ),
                    Container(width: 1, height: 36, color: TechnoColors.cardBorder),
                    Expanded(
                      child: _PreviewItem(
                        label: 'WATER',
                        value: switch (profile.waterUnit) {
                          WaterUnit.ml => '500 ml',
                          WaterUnit.flOz => '16.9 fl oz',
                          WaterUnit.cups => '2.1 cups',
                        },
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _apply(
    AppProvider provider,
    UserProfile profile, {
    required bool preferKg,
    required bool preferCm,
    required WaterUnit waterUnit,
  }) {
    provider.updateProfile(profile.copyWith(
      preferKg: preferKg,
      preferCm: preferCm,
      waterUnit: waterUnit,
    ));
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

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

class _SystemTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  const _SystemTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? accentColor.withValues(alpha: 0.1) : TechnoColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? accentColor : TechnoColors.cardBorder,
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: accentColor.withValues(alpha: 0.1), blurRadius: 16)]
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? accentColor : TechnoColors.textMuted, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.orbitron(
                      color: selected ? accentColor : TechnoColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.rajdhani(
                      color: selected
                          ? accentColor.withValues(alpha: 0.8)
                          : TechnoColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: selected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 150),
              child: Icon(Icons.check_circle, color: accentColor, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomUnitRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<String> options;
  final int selected;
  final Color accentColor;
  final ValueChanged<int> onSelect;

  const _CustomUnitRow({
    required this.label,
    required this.icon,
    required this.options,
    required this.selected,
    required this.accentColor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: TechnoColors.textMuted, size: 18),
          const SizedBox(width: 10),
          SizedBox(
            width: 52,
            child: Text(
              label,
              style: GoogleFonts.rajdhani(
                color: TechnoColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: List.generate(options.length, (i) {
              final active = i == selected;
              return Padding(
                padding: EdgeInsets.only(left: i > 0 ? 8 : 0),
                child: GestureDetector(
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: active
                          ? accentColor.withValues(alpha: 0.15)
                          : TechnoColors.bgTertiary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: active ? accentColor : TechnoColors.cardBorder,
                        width: active ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      options[i],
                      style: GoogleFonts.rajdhani(
                        color: active ? accentColor : TechnoColors.textSecondary,
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PreviewItem extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.orbitron(
            color: TechnoColors.textMuted,
            fontSize: 9,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.orbitron(
            color: TechnoColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
