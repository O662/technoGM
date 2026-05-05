import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_card.dart';

String _fmtWeight(double kg, bool preferKg) => preferKg
    ? '${kg.toStringAsFixed(1)} kg'
    : '${(kg * 2.20462).toStringAsFixed(1)} lbs';

// ─── Questionnaire Shell ──────────────────────────────────────────────────────

class OnboardingQuestionnaireScreen extends StatefulWidget {
  const OnboardingQuestionnaireScreen({super.key});

  @override
  State<OnboardingQuestionnaireScreen> createState() =>
      _OnboardingQuestionnaireScreenState();
}

class _OnboardingQuestionnaireScreenState
    extends State<OnboardingQuestionnaireScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _kNavDuration = Duration(milliseconds: 300);
  static const _kNavCurve = Curves.easeOutCubic;

  void _toggle<T>(List<T> list, T item) =>
      setState(() => list.contains(item) ? list.remove(item) : list.add(item));

  void _toggleInjury(InjuryArea area) {
    setState(() {
      if (_injuries.contains(area)) {
        _injuries.remove(area);
        _injurySides.remove(area);
      } else {
        _injuries.add(area);
        _injurySides[area] = [];
      }
    });
  }

  void _toggleInjurySide(InjuryArea area, InjurySide side) {
    setState(() {
      final sides = _injurySides[area] ?? [];
      sides.contains(side) ? sides.remove(side) : sides.add(side);
      _injurySides[area] = sides;
    });
  }

  // ── Collected answers ──────────────────────────────────────────────────────
  String _name = '';
  double _heightCm = 175;
  double _weightKg = 70;
  bool _preferKg = true;   // set by weight picker unit wheel
  bool _preferCm = true;   // set by height picker unit toggle
  FitnessLevel _fitnessLevel = FitnessLevel.intermediate;
  bool _preferGym = true;
  final List<EquipmentType> _homeEquipment = [];
  final List<InjuryArea> _injuries = [];
  final Map<InjuryArea, List<InjurySide>> _injurySides = {};
  final List<FitnessGoal> _goals = [];
  double? _goalWeightKg;

  // 7 pages total: 0=name, 1=h&w, 2=fitness, 3=location, 4=injuries,
  //                5=goals, 6=goal weight (only when loseWeight selected)
  int get _effectiveTotalPages =>
      _goals.contains(FitnessGoal.loseWeight) ? 7 : 6;

  double get _defaultGoalWeightKg =>
      (_weightKg - 10).clamp(30.0, _weightKg - 1.0);

  void _next() {
    FocusScope.of(context).unfocus();
    // Skip goal-weight page if lose-weight goal not selected
    if (_currentPage == 5 && !_goals.contains(FitnessGoal.loseWeight)) {
      _finish();
    } else if (_currentPage < _effectiveTotalPages - 1) {
      _pageController.nextPage(duration: _kNavDuration, curve: _kNavCurve);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _pageController.previousPage(duration: _kNavDuration, curve: _kNavCurve);
    } else {
      Navigator.pop(context);
    }
  }

  bool get _canAdvance {
    if (_currentPage == 0) return _name.trim().isNotEmpty;
    if (_currentPage == 5) return _goals.isNotEmpty;
    return true;
  }

  Future<void> _finish() async {
    final provider = context.read<AppProvider>();
    final profile = UserProfile(
      name: _name.trim(),
      heightCm: _heightCm,
      preferCm: _preferCm,
      fitnessLevel: _fitnessLevel,
      preferKg: _preferKg,
      preferGym: _preferGym,
      homeEquipment: _preferGym ? [] : List.from(_homeEquipment),
      injuries: List.from(_injuries),
      injurySides: Map.from(_injurySides),
      goals: List.from(_goals),
      goalWeightKg: _goals.contains(FitnessGoal.loseWeight)
          ? (_goalWeightKg ?? _defaultGoalWeightKg)
          : null,
    );
    await provider.completeOnboarding(
      profile: profile,
      initialWeightKg: _weightKg,
    );
    if (mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TechnoColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar: back + progress ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: TechnoColors.textSecondary, size: 18),
                    onPressed: _back,
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentPage + 1) / _effectiveTotalPages,
                        backgroundColor:
                            TechnoColors.textMuted.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            TechnoColors.neonCyan),
                        minHeight: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_currentPage + 1}/$_effectiveTotalPages',
                    style: GoogleFonts.orbitron(
                        color: TechnoColors.textMuted,
                        fontSize: 10,
                        letterSpacing: 1),
                  ),
                ],
              ),
            ),

            // ── Page content ───────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  // 0 — Name
                  _StepName(
                    name: _name,
                    onChanged: (v) => setState(() => _name = v),
                  ),
                  // 1 — Height & Weight
                  _StepHeightWeight(
                    heightCm: _heightCm,
                    weightKg: _weightKg,
                    preferKg: _preferKg,
                    preferCm: _preferCm,
                    onHeightChanged: (cm, isCm) => setState(() {
                      _heightCm = cm;
                      _preferCm = isCm;
                    }),
                    onWeightChanged: (kg, isKg) => setState(() {
                      _weightKg = kg;
                      _preferKg = isKg;
                    }),
                  ),
                  // 2 — Fitness Level
                  _StepFitnessLevel(
                    value: _fitnessLevel,
                    onChanged: (v) => setState(() => _fitnessLevel = v),
                  ),
                  // 3 — Default Location
                  _StepLocation(
                    preferGym: _preferGym,
                    onChanged: (v) => setState(() => _preferGym = v),
                    homeEquipment: _homeEquipment,
                    onEquipmentToggle: (e) => _toggle(_homeEquipment, e),
                  ),
                  // 4 — Injuries
                  _StepInjuries(
                    selected: _injuries,
                    injurySides: _injurySides,
                    onAreaToggle: _toggleInjury,
                    onSideToggle: _toggleInjurySide,
                  ),
                  // 5 — Goals
                  _StepGoals(
                    selected: _goals,
                    onToggle: (goal) => _toggle(_goals, goal),
                  ),
                  // 6 — Goal Weight (only reached when loseWeight selected)
                  _StepGoalWeight(
                    currentWeightKg: _weightKg,
                    goalWeightKg: _goalWeightKg ?? _defaultGoalWeightKg,
                    preferKg: _preferKg,
                    onChanged: (kg) => setState(() => _goalWeightKg = kg),
                  ),
                ],
              ),
            ),

            // ── Bottom continue button ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: NeonButton(
                label:
                    _currentPage == _effectiveTotalPages - 1 ? "LET'S GO!" : 'CONTINUE',
                icon: _currentPage == _effectiveTotalPages - 1
                    ? Icons.check
                    : Icons.arrow_forward,
                color: _canAdvance
                    ? TechnoColors.neonCyan
                    : TechnoColors.textMuted,
                onTap: _canAdvance ? _next : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 0 — Name ────────────────────────────────────────────────────────────

class _StepName extends StatefulWidget {
  final String name;
  final ValueChanged<String> onChanged;
  const _StepName({required this.name, required this.onChanged});

  @override
  State<_StepName> createState() => _StepNameState();
}

class _StepNameState extends State<_StepName> {
  late final TextEditingController _ctrl;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.name);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null && route.animation != null) {
      route.animation!.addStatusListener(_onRouteAnimated);
    }
  }

  void _onRouteAnimated(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      title: "WHAT'S YOUR NAME?",
      subtitle: 'How should we address you?',
      child: TextField(
        controller: _ctrl,
        focusNode: _focusNode,
        autofocus: false,
        textCapitalization: TextCapitalization.words,
        style: GoogleFonts.rajdhani(
            color: TechnoColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: 'Enter your name...',
          hintStyle:
              GoogleFonts.rajdhani(color: TechnoColors.textMuted, fontSize: 18),
          prefixIcon: const Icon(Icons.person_outline,
              color: TechnoColors.neonCyan, size: 22),
        ),
        onChanged: widget.onChanged,
      ),
    );
  }
}

// ─── Step 1 — Height & Weight ─────────────────────────────────────────────────

class _StepHeightWeight extends StatelessWidget {
  final double heightCm;
  final double weightKg;
  final bool preferKg;
  final bool preferCm;
  final void Function(double cm, bool isCm) onHeightChanged;
  final void Function(double kg, bool isKg) onWeightChanged;

  const _StepHeightWeight({
    required this.heightCm,
    required this.weightKg,
    required this.preferKg,
    required this.preferCm,
    required this.onHeightChanged,
    required this.onWeightChanged,
  });

  String _displayHeight() {
    if (preferCm) {
      return '${heightCm.round()} cm';
    } else {
      final totalIn = (heightCm / 2.54).round();
      final ft = totalIn ~/ 12;
      final inches = totalIn % 12;
      return "$ft ft $inches in";
    }
  }

  Future<void> _pickHeight(BuildContext context) async {
    final result = await showModalBottomSheet<_HeightResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HeightPickerSheet(
        initialCm: heightCm,
        initialIsCm: preferCm,
      ),
    );
    if (result != null) onHeightChanged(result.cm, result.isCm);
  }

  Future<void> _pickWeight(BuildContext context) async {
    final result = await showModalBottomSheet<_WeightResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WeightPickerSheet(
        initialKg: weightKg,
        initialIsKg: preferKg,
      ),
    );
    if (result != null) onWeightChanged(result.kg, result.isKg);
  }

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      title: 'HEIGHT & WEIGHT',
      subtitle: 'Tap either card to set your measurements using the scroll wheel.',
      child: Column(
        children: [
          _MeasurementCard(
            icon: Icons.height,
            label: 'HEIGHT',
            value: _displayHeight(),
            color: TechnoColors.neonCyan,
            onTap: () => _pickHeight(context),
          ),
          const SizedBox(height: 16),
          _MeasurementCard(
            icon: Icons.monitor_weight_outlined,
            label: 'WEIGHT',
            value: _fmtWeight(weightKg, preferKg),
            color: TechnoColors.neonPink,
            onTap: () => _pickWeight(context),
          ),
          const SizedBox(height: 20),
          Text(
            'The unit you pick in the weight picker becomes your app-wide preference.',
            style: GoogleFonts.rajdhani(
                color: TechnoColors.textMuted, fontSize: 12, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Step 2 — Fitness Level ───────────────────────────────────────────────────

class _StepFitnessLevel extends StatelessWidget {
  final FitnessLevel value;
  final ValueChanged<FitnessLevel> onChanged;
  const _StepFitnessLevel({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      title: 'FITNESS LEVEL',
      subtitle: 'How would you describe your current training experience?',
      child: Column(
        children: [
          _OptionTile(
            label: 'Beginner',
            sublabel: 'Less than 1 year of consistent training',
            icon: Icons.star_outline,
            selected: value == FitnessLevel.beginner,
            color: TechnoColors.neonGreen,
            onTap: () => onChanged(FitnessLevel.beginner),
          ),
          const SizedBox(height: 12),
          _OptionTile(
            label: 'Intermediate',
            sublabel: '1–3 years of consistent training',
            icon: Icons.star_half,
            selected: value == FitnessLevel.intermediate,
            color: TechnoColors.neonYellow,
            onTap: () => onChanged(FitnessLevel.intermediate),
          ),
          const SizedBox(height: 12),
          _OptionTile(
            label: 'Advanced',
            sublabel: '3+ years of consistent training',
            icon: Icons.star,
            selected: value == FitnessLevel.advanced,
            color: TechnoColors.neonPink,
            onTap: () => onChanged(FitnessLevel.advanced),
          ),
        ],
      ),
    );
  }
}

// ─── Step 3 — Default Location ────────────────────────────────────────────────

class _StepLocation extends StatelessWidget {
  final bool preferGym;
  final ValueChanged<bool> onChanged;
  final List<EquipmentType> homeEquipment;
  final ValueChanged<EquipmentType> onEquipmentToggle;

  const _StepLocation({
    required this.preferGym,
    required this.onChanged,
    required this.homeEquipment,
    required this.onEquipmentToggle,
  });

  static const _homeOptions = [
    EquipmentType.dumbbells,
    EquipmentType.barbell,
    EquipmentType.kettlebell,
    EquipmentType.resistanceBands,
    EquipmentType.pullupBar,
    EquipmentType.bench,
  ];

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      title: 'DEFAULT LOCATION',
      subtitle: 'Where do you usually work out?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OptionTile(
            label: 'Gym',
            sublabel: 'Access to machines, barbells, cables & full equipment',
            icon: Icons.fitness_center,
            selected: preferGym,
            color: TechnoColors.neonCyan,
            onTap: () => onChanged(true),
          ),
          const SizedBox(height: 12),
          _OptionTile(
            label: 'Home / Outdoors',
            sublabel: 'Minimal equipment — bodyweight, dumbbells, bands',
            icon: Icons.home_outlined,
            selected: !preferGym,
            color: TechnoColors.neonGreen,
            onTap: () => onChanged(false),
          ),
          // Equipment picker — visible only when Home/Outdoors is selected
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: !preferGym
                ? Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WHAT EQUIPMENT DO YOU HAVE?',
                          style: GoogleFonts.orbitron(
                            color: TechnoColors.neonGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _homeOptions.map((eq) {
                            final selected = homeEquipment.contains(eq);
                            return GestureDetector(
                              onTap: () => onEquipmentToggle(eq),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 9),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? TechnoColors.neonGreen
                                          .withValues(alpha: 0.15)
                                      : TechnoColors.bgSecondary,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selected
                                        ? TechnoColors.neonGreen
                                        : TechnoColors.textMuted
                                            .withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  eq.label,
                                  style: GoogleFonts.rajdhani(
                                    color: selected
                                        ? TechnoColors.neonGreen
                                        : TechnoColors.textSecondary,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: TechnoColors.neonCyan.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: TechnoColors.neonCyan.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: TechnoColors.neonCyan, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'No-equipment exercises are always included and will be recommended to you regardless of your equipment preferences.',
                                  style: GoogleFonts.rajdhani(
                                    color: TechnoColors.neonCyan,
                                    fontSize: 13,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ─── Step 4 — Injuries ────────────────────────────────────────────────────────

class _StepInjuries extends StatelessWidget {
  final List<InjuryArea> selected;
  final Map<InjuryArea, List<InjurySide>> injurySides;
  final ValueChanged<InjuryArea> onAreaToggle;
  final void Function(InjuryArea, InjurySide) onSideToggle;

  const _StepInjuries({
    required this.selected,
    required this.injurySides,
    required this.onAreaToggle,
    required this.onSideToggle,
  });

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      title: 'ANY INJURIES?',
      subtitle:
          'Select areas we should avoid or be careful with. You can skip this.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Area chips ──────────────────────────────────────────────────
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: InjuryArea.values.map((injury) {
              final isSelected = selected.contains(injury);
              return GestureDetector(
                onTap: () => onAreaToggle(injury),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? TechnoColors.neonOrange.withValues(alpha: 0.15)
                        : TechnoColors.bgSecondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? TechnoColors.neonOrange
                          : TechnoColors.textMuted.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        const Icon(Icons.warning_amber_rounded,
                            color: TechnoColors.neonOrange, size: 14),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        injury.label,
                        style: GoogleFonts.rajdhani(
                          color: isSelected
                              ? TechnoColors.neonOrange
                              : TechnoColors.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          // ── Side selectors for each chosen injury ───────────────────────
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            child: selected.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WHICH SIDE IS YOUR INJURY ON?',
                          style: GoogleFonts.orbitron(
                            color: TechnoColors.neonOrange,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...selected.map((injury) {
                          final sides = injurySides[injury] ?? [];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded,
                                    color: TechnoColors.neonOrange, size: 14),
                                const SizedBox(width: 6),
                                SizedBox(
                                  width: 110,
                                  child: Text(
                                    injury.label,
                                    style: GoogleFonts.rajdhani(
                                      color: TechnoColors.neonOrange,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                ...InjurySide.values.map((side) {
                                  final active = sides.contains(side);
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: GestureDetector(
                                      onTap: () =>
                                          onSideToggle(injury, side),
                                      child: AnimatedContainer(
                                        duration: const Duration(
                                            milliseconds: 150),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 7),
                                        decoration: BoxDecoration(
                                          color: active
                                              ? TechnoColors.neonOrange
                                                  .withValues(alpha: 0.2)
                                              : TechnoColors.bgSecondary,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: active
                                                ? TechnoColors.neonOrange
                                                : TechnoColors.textMuted
                                                    .withValues(alpha: 0.4),
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Text(
                                          side.label,
                                          style: GoogleFonts.rajdhani(
                                            color: active
                                                ? TechnoColors.neonOrange
                                                : TechnoColors.textSecondary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 5 — Goals ───────────────────────────────────────────────────────────

class _StepGoals extends StatelessWidget {
  final List<FitnessGoal> selected;
  final ValueChanged<FitnessGoal> onToggle;
  const _StepGoals({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      title: 'YOUR GOALS',
      subtitle: 'What do you want to achieve? Pick one or more.',
      child: Column(
        children: FitnessGoal.values.map((goal) {
          final isSelected = selected.contains(goal);
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () => onToggle(goal),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? TechnoColors.neonCyan.withValues(alpha: 0.12)
                      : TechnoColors.bgSecondary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? TechnoColors.neonCyan
                        : TechnoColors.textMuted.withValues(alpha: 0.35),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Text(goal.emoji, style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        goal.label,
                        style: GoogleFonts.rajdhani(
                          color: isSelected
                              ? TechnoColors.neonCyan
                              : TechnoColors.textSecondary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    AnimatedOpacity(
                      opacity: isSelected ? 1 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: const Icon(Icons.check_circle,
                          color: TechnoColors.neonCyan, size: 20),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Step 6 — Goal Weight ─────────────────────────────────────────────────────

class _StepGoalWeight extends StatelessWidget {
  final double currentWeightKg;
  final double goalWeightKg;
  final bool preferKg;
  final ValueChanged<double> onChanged;

  const _StepGoalWeight({
    required this.currentWeightKg,
    required this.goalWeightKg,
    required this.preferKg,
    required this.onChanged,
  });

  Future<void> _pickGoalWeight(BuildContext context) async {
    final result = await showModalBottomSheet<_WeightResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WeightPickerSheet(
        initialKg: goalWeightKg,
        initialIsKg: preferKg,
      ),
    );
    if (result != null) onChanged(result.kg);
  }

  @override
  Widget build(BuildContext context) {
    final diff = currentWeightKg - goalWeightKg;
    final isRealistic = diff > 0;

    return _StepShell(
      title: 'YOUR GOAL WEIGHT',
      subtitle: 'What is your target weight? Tap the card to set it.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MeasurementCard(
            icon: Icons.flag_outlined,
            label: 'GOAL WEIGHT',
            value: _fmtWeight(goalWeightKg, preferKg),
            color: TechnoColors.neonGreen,
            onTap: () => _pickGoalWeight(context),
          ),
          const SizedBox(height: 20),
          if (isRealistic)
            NeonCard(
              borderColor: TechnoColors.neonCyan.withValues(alpha: 0.3),
              child: Row(
                children: [
                  const Icon(Icons.trending_down,
                      color: TechnoColors.neonCyan, size: 22),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TO LOSE',
                          style: GoogleFonts.orbitron(
                              color: TechnoColors.textMuted,
                              fontSize: 9,
                              letterSpacing: 1.5)),
                      Text(_fmtWeight(diff, preferKg),
                          style: GoogleFonts.orbitron(
                              color: TechnoColors.neonCyan,
                              fontSize: 18,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Goal is above your current weight — check the value.',
                style: GoogleFonts.rajdhani(
                    color: TechnoColors.neonOrange,
                    fontSize: 14,
                    height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Weight picker bottom sheet ───────────────────────────────────────────────

class _WeightResult {
  final double kg;
  final bool isKg;
  const _WeightResult(this.kg, this.isKg);
}

class _WeightPickerSheet extends StatefulWidget {
  final double initialKg;
  final bool initialIsKg;
  const _WeightPickerSheet(
      {required this.initialKg, required this.initialIsKg});

  @override
  State<_WeightPickerSheet> createState() => _WeightPickerSheetState();
}

class _WeightPickerSheetState extends State<_WeightPickerSheet> {
  late bool _isKg;
  late int _wholeIndex;
  late int _decIndex;
  late int _unitIndex;

  late FixedExtentScrollController _wholeCtrl;
  late FixedExtentScrollController _decCtrl;
  late FixedExtentScrollController _unitCtrl;

  static const int _kgMax = 300;
  static const int _lbsMax = 660;

  @override
  void initState() {
    super.initState();
    _isKg = widget.initialIsKg;
    _unitIndex = _isKg ? 0 : 1;
    if (_isKg) {
      _wholeIndex = widget.initialKg.floor().clamp(0, _kgMax);
      _decIndex = ((widget.initialKg - widget.initialKg.floor()) * 10)
          .round()
          .clamp(0, 9);
    } else {
      final lbs = widget.initialKg * 2.20462;
      _wholeIndex = lbs.floor().clamp(0, _lbsMax);
      _decIndex = ((lbs - lbs.floor()) * 10).round().clamp(0, 9);
    }
    _wholeCtrl = FixedExtentScrollController(initialItem: _wholeIndex);
    _decCtrl   = FixedExtentScrollController(initialItem: _decIndex);
    _unitCtrl  = FixedExtentScrollController(initialItem: _unitIndex);
  }

  @override
  void dispose() {
    _wholeCtrl.dispose();
    _decCtrl.dispose();
    _unitCtrl.dispose();
    super.dispose();
  }

  double _currentKg() {
    final displayVal = _wholeIndex + _decIndex / 10.0;
    return _isKg ? displayVal : displayVal / 2.20462;
  }

  void _onUnitChanged(int index) {
    if (index == _unitIndex) return;
    final kgNow = _currentKg();
    final newIsKg = index == 0;
    final newDisplay = newIsKg ? kgNow : kgNow * 2.20462;
    final newMax     = newIsKg ? _kgMax : _lbsMax;
    final newWhole   = newDisplay.floor().clamp(0, newMax);
    final newDec     = ((newDisplay - newDisplay.floor()) * 10).round().clamp(0, 9);
    setState(() {
      _isKg = newIsKg;
      _unitIndex = index;
      _wholeIndex = newWhole;
      _decIndex = newDec;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_wholeCtrl.hasClients) _wholeCtrl.jumpToItem(_wholeIndex);
      if (_decCtrl.hasClients)   _decCtrl.jumpToItem(_decIndex);
    });
  }

  void _confirm() =>
      Navigator.pop(context, _WeightResult(_currentKg(), _isKg));

  @override
  Widget build(BuildContext context) {
    final maxWhole = _isKg ? _kgMax : _lbsMax;
    return _PickerSheetContainer(
      title: 'WEIGHT',
      accentColor: TechnoColors.neonPink,
      onDone: _confirm,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _WheelColumn(
            width: 90,
            controller: _wholeCtrl,
            items: List.generate(maxWhole + 1, (i) => '$i'),
            color: TechnoColors.neonPink,
            onChanged: (i) => setState(() => _wholeIndex = i),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text('.',
                style: GoogleFonts.orbitron(
                    color: TechnoColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900)),
          ),
          _WheelColumn(
            width: 56,
            controller: _decCtrl,
            items: List.generate(10, (i) => '$i'),
            color: TechnoColors.neonPink,
            onChanged: (i) => setState(() => _decIndex = i),
          ),
          const SizedBox(width: 16),
          _WheelColumn(
            width: 72,
            controller: _unitCtrl,
            items: const ['kg', 'lbs'],
            color: TechnoColors.neonCyan,
            onChanged: _onUnitChanged,
          ),
        ],
      ),
    );
  }
}

// ─── Height picker bottom sheet ───────────────────────────────────────────────

class _HeightResult {
  final double cm;
  final bool isCm;
  const _HeightResult(this.cm, this.isCm);
}

class _HeightPickerSheet extends StatefulWidget {
  final double initialCm;
  final bool initialIsCm;
  const _HeightPickerSheet(
      {required this.initialCm, required this.initialIsCm});

  @override
  State<_HeightPickerSheet> createState() => _HeightPickerSheetState();
}

class _HeightPickerSheetState extends State<_HeightPickerSheet> {
  late bool _isCm;
  late int _cmIndex;
  late int _feetIndex;
  late int _inchesIndex;

  late FixedExtentScrollController _cmCtrl;
  late FixedExtentScrollController _feetCtrl;
  late FixedExtentScrollController _inchesCtrl;

  static const int _cmMin = 100;
  static const int _cmMax = 250;

  @override
  void initState() {
    super.initState();
    _isCm = widget.initialIsCm;
    final cm = widget.initialCm.round().clamp(_cmMin, _cmMax);
    _cmIndex = cm - _cmMin;
    final totalIn = (widget.initialCm / 2.54).round();
    _feetIndex   = ((totalIn ~/ 12) - 3).clamp(0, 5);
    _inchesIndex = (totalIn % 12).clamp(0, 11);
    _cmCtrl     = FixedExtentScrollController(initialItem: _cmIndex);
    _feetCtrl   = FixedExtentScrollController(initialItem: _feetIndex);
    _inchesCtrl = FixedExtentScrollController(initialItem: _inchesIndex);
  }

  @override
  void dispose() {
    _cmCtrl.dispose();
    _feetCtrl.dispose();
    _inchesCtrl.dispose();
    super.dispose();
  }

  double _currentCm() {
    if (_isCm) return (_cmMin + _cmIndex).toDouble();
    return ((3 + _feetIndex) * 12 + _inchesIndex) * 2.54;
  }

  void _switchUnit(bool toCm) {
    if (_isCm == toCm) return;
    final cur = _currentCm();
    setState(() => _isCm = toCm);
    if (toCm) {
      final idx = (cur.round() - _cmMin).clamp(0, _cmMax - _cmMin);
      setState(() => _cmIndex = idx);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_cmCtrl.hasClients) _cmCtrl.jumpToItem(idx);
      });
    } else {
      final totalIn = (cur / 2.54).round();
      final ft = ((totalIn ~/ 12) - 3).clamp(0, 5);
      final inch = (totalIn % 12).clamp(0, 11);
      setState(() { _feetIndex = ft; _inchesIndex = inch; });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_feetCtrl.hasClients)   _feetCtrl.jumpToItem(ft);
        if (_inchesCtrl.hasClients) _inchesCtrl.jumpToItem(inch);
      });
    }
  }

  void _confirm() => Navigator.pop(context, _HeightResult(_currentCm(), _isCm));

  @override
  Widget build(BuildContext context) {
    return _PickerSheetContainer(
      title: 'HEIGHT',
      accentColor: TechnoColors.neonCyan,
      onDone: _confirm,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _UnitToggleChip(
                label: 'cm',
                selected: _isCm,
                color: TechnoColors.neonCyan,
                onTap: () => _switchUnit(true),
              ),
              const SizedBox(width: 10),
              _UnitToggleChip(
                label: 'ft & in',
                selected: !_isCm,
                color: TechnoColors.neonCyan,
                onTap: () => _switchUnit(false),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isCm)
            _WheelColumn(
              width: 140,
              controller: _cmCtrl,
              items: List.generate(_cmMax - _cmMin + 1, (i) => '${_cmMin + i}'),
              color: TechnoColors.neonCyan,
              onChanged: (i) => setState(() => _cmIndex = i),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _WheelColumn(
                  width: 100,
                  controller: _feetCtrl,
                  items: List.generate(6, (i) => '${3 + i} ft'),
                  color: TechnoColors.neonCyan,
                  onChanged: (i) => setState(() => _feetIndex = i),
                ),
                const SizedBox(width: 16),
                _WheelColumn(
                  width: 100,
                  controller: _inchesCtrl,
                  items: List.generate(12, (i) => '$i in'),
                  color: TechnoColors.neonCyan,
                  onChanged: (i) => setState(() => _inchesIndex = i),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Picker shared widgets ────────────────────────────────────────────────────

/// Dark neon bottom sheet container for pickers.
class _PickerSheetContainer extends StatelessWidget {
  final String title;
  final Color accentColor;
  final VoidCallback onDone;
  final Widget child;

  const _PickerSheetContainer({
    required this.title,
    required this.accentColor,
    required this.onDone,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TechnoColors.bgSecondary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: accentColor.withValues(alpha: 0.3), width: 1.5),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: TechnoColors.textMuted.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: GoogleFonts.orbitron(
                      color: accentColor,
                      fontSize: 13,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700)),
              GestureDetector(
                onTap: onDone,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: accentColor.withValues(alpha: 0.5)),
                  ),
                  child: Text('DONE',
                      style: GoogleFonts.orbitron(
                          color: accentColor,
                          fontSize: 11,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Single column scroll wheel with inline tap-to-edit on the selected item.
class _WheelColumn extends StatefulWidget {
  final List<String> items;
  final FixedExtentScrollController controller;
  final ValueChanged<int> onChanged;
  final Color color;
  final double width;

  static const double itemExtent = 46;
  static const double height = 180;

  const _WheelColumn({
    required this.items,
    required this.controller,
    required this.onChanged,
    required this.color,
    required this.width,
  });

  @override
  State<_WheelColumn> createState() => _WheelColumnState();
}

class _WheelColumnState extends State<_WheelColumn> {
  bool _editing = false;
  late final TextEditingController _editCtrl;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _editCtrl  = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && _editing) _commit();
    });
  }

  @override
  void dispose() {
    _editCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _currentItemText() {
    final idx = widget.controller.hasClients
        ? widget.controller.selectedItem.clamp(0, widget.items.length - 1)
        : 0;
    return widget.items[idx];
  }

  // Strip unit suffixes so the field shows just the number (e.g. "11 in" → "11")
  String _numericPart(String s) {
    final stripped = s.replaceAll(RegExp(r'[^0-9.]'), '');
    return stripped.isEmpty ? s : stripped;
  }

  void _startEditing() {
    final text = _numericPart(_currentItemText());
    _editCtrl.value = TextEditingValue(
      text: text,
      selection: TextSelection(baseOffset: 0, extentOffset: text.length),
    );
    setState(() => _editing = true);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  /// Find the index whose numeric part matches the user's input.
  int _findIndex(String input) {
    final trimmed = input.trim();
    // exact match (e.g. unit wheel: "kg" / "lbs")
    final exact = widget.items.indexOf(trimmed);
    if (exact != -1) return exact;
    // numeric match: compare stripped numbers
    final inputNum = int.tryParse(trimmed.replaceAll(RegExp(r'[^0-9]'), ''));
    if (inputNum != null) {
      for (int i = 0; i < widget.items.length; i++) {
        final itemNum =
            int.tryParse(widget.items[i].replaceAll(RegExp(r'[^0-9]'), ''));
        if (itemNum == inputNum) return i;
      }
    }
    return -1;
  }

  void _commit() {
    if (!_editing) return;
    setState(() => _editing = false); // flag first — prevents recursive call from the unfocus listener below
    _focusNode.unfocus(); // explicitly release the text-input connection before the TextField leaves the tree
    final idx = _findIndex(_editCtrl.text);
    if (idx == -1) return;
    widget.onChanged(idx);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.controller.hasClients) widget.controller.jumpToItem(idx);
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(6);
    final dimSide = BorderSide(color: widget.color.withValues(alpha: 0.7));
    return SizedBox(
      width: widget.width,
      height: _WheelColumn.height,
      child: Stack(
        children: [
          // ── Scroll wheel ────────────────────────────────────────────
          ListWheelScrollView.useDelegate(
            controller: widget.controller,
            itemExtent: _WheelColumn.itemExtent,
            physics: const FixedExtentScrollPhysics(),
            overAndUnderCenterOpacity: _editing ? 0.08 : 0.25,
            perspective: 0.003,
            onSelectedItemChanged: widget.onChanged,
            childDelegate: ListWheelChildListDelegate(
              children: widget.items
                  .map((item) => Center(
                        child: Text(
                          item,
                          style: GoogleFonts.orbitron(
                            color: TechnoColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),

          // ── Selection band ──────────────────────────────────────────
          IgnorePointer(
            child: Center(
              child: Container(
                height: _WheelColumn.itemExtent,
                decoration: BoxDecoration(
                  color: widget.color.withValues(alpha: 0.08),
                  border: Border.symmetric(
                    horizontal: BorderSide(
                        color: widget.color.withValues(alpha: 0.45), width: 1),
                  ),
                ),
              ),
            ),
          ),

          // ── Inline text field (while editing) ───────────────────────
          if (_editing)
            Center(
              child: SizedBox(
                height: _WheelColumn.itemExtent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 4, vertical: 5),
                  child: TextField(
                    controller: _editCtrl,
                    focusNode: _focusNode,
                    autofocus: true,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.orbitron(
                      color: widget.color,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      filled: true,
                      fillColor: TechnoColors.bgPrimary,
                      border: OutlineInputBorder(borderRadius: borderRadius, borderSide: dimSide),
                      enabledBorder: OutlineInputBorder(borderRadius: borderRadius, borderSide: dimSide),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: borderRadius,
                        borderSide: BorderSide(color: widget.color, width: 1.5),
                      ),
                    ),
                    onSubmitted: (_) => _commit(),
                    onEditingComplete: _commit,
                  ),
                ),
              ),
            ),

          // ── Tap target over the band (only when not editing) ────────
          if (!_editing)
            Positioned(
              top: (_WheelColumn.height - _WheelColumn.itemExtent) / 2,
              left: 0,
              right: 0,
              height: _WheelColumn.itemExtent,
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _startEditing,
              ),
            ),
        ],
      ),
    );
  }
}

/// Toggle chip for unit selection (cm / ft&in).
class _UnitToggleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _UnitToggleChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : TechnoColors.textMuted.withValues(alpha: 0.4),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.orbitron(
            color: selected ? color : TechnoColors.textSecondary,
            fontSize: 11,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}

// ─── Reusable measurement tap-card ───────────────────────────────────────────

class _MeasurementCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _MeasurementCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeonCard(
        borderColor: color.withValues(alpha: 0.4),
        child: Row(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.orbitron(
                          color: TechnoColors.textMuted,
                          fontSize: 9,
                          letterSpacing: 1.5)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: GoogleFonts.orbitron(
                          color: color,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Shared step layout ───────────────────────────────────────────────────────

class _StepShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _StepShell({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.orbitron(
              color: TechnoColors.neonCyan,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.rajdhani(
              color: TechnoColors.textSecondary,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }
}

// ─── Reusable option tile ─────────────────────────────────────────────────────

class _OptionTile extends StatelessWidget {
  final String label;
  final String sublabel;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.12)
              : TechnoColors.bgSecondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? color
                : TechnoColors.textMuted.withValues(alpha: 0.35),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: selected ? color : TechnoColors.textMuted, size: 26),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.rajdhani(
                      color: selected ? color : TechnoColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: GoogleFonts.rajdhani(
                      color: TechnoColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              opacity: selected ? 1 : 0,
              duration: const Duration(milliseconds: 150),
              child: Icon(Icons.check_circle, color: color, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}
