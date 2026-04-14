import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_card.dart';

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

  // ── Collected answers ──────────────────────────────────────────────────────
  String _name = '';
  double _heightCm = 175;
  double _weightKg = 70;
  bool _preferKg = true;   // set by weight picker unit wheel
  FitnessLevel _fitnessLevel = FitnessLevel.intermediate;
  bool _preferGym = true;
  final List<InjuryArea> _injuries = [];
  final List<FitnessGoal> _goals = [];

  static const int _totalPages = 6;

  void _next() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
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
      fitnessLevel: _fitnessLevel,
      preferKg: _preferKg,
      preferGym: _preferGym,
      injuries: List.from(_injuries),
      goals: List.from(_goals),
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
                        value: (_currentPage + 1) / _totalPages,
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
                    '${_currentPage + 1}/$_totalPages',
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
                    onHeightChanged: (cm) =>
                        setState(() => _heightCm = cm),
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
                  ),
                  // 4 — Injuries
                  _StepInjuries(
                    selected: _injuries,
                    onToggle: (injury) => setState(() {
                      if (_injuries.contains(injury)) {
                        _injuries.remove(injury);
                      } else {
                        _injuries.add(injury);
                      }
                    }),
                  ),
                  // 5 — Goals
                  _StepGoals(
                    selected: _goals,
                    onToggle: (goal) => setState(() {
                      if (_goals.contains(goal)) {
                        _goals.remove(goal);
                      } else {
                        _goals.add(goal);
                      }
                    }),
                  ),
                ],
              ),
            ),

            // ── Bottom continue button ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: NeonButton(
                label:
                    _currentPage == _totalPages - 1 ? "LET'S GO!" : 'CONTINUE',
                icon: _currentPage == _totalPages - 1
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

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.name);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      title: "WHAT'S YOUR NAME?",
      subtitle: 'How should we address you?',
      child: TextField(
        controller: _ctrl,
        autofocus: true,
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
  final ValueChanged<double> onHeightChanged;
  final void Function(double kg, bool isKg) onWeightChanged;

  const _StepHeightWeight({
    required this.heightCm,
    required this.weightKg,
    required this.preferKg,
    required this.onHeightChanged,
    required this.onWeightChanged,
  });

  String _displayHeight() {
    // Decide display unit based on preferKg (same preference)
    if (preferKg) {
      return '${heightCm.round()} cm';
    } else {
      final totalIn = (heightCm / 2.54).round();
      final ft = totalIn ~/ 12;
      final inches = totalIn % 12;
      return "$ft ft $inches in";
    }
  }

  String _displayWeight() {
    if (preferKg) {
      return '${weightKg.toStringAsFixed(1)} kg';
    } else {
      return '${(weightKg * 2.20462).toStringAsFixed(1)} lbs';
    }
  }

  Future<void> _pickHeight(BuildContext context) async {
    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _HeightPickerSheet(
        initialCm: heightCm,
        initialIsCm: preferKg, // match the weight unit preference
      ),
    );
    if (result != null) onHeightChanged(result);
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
          // Height card
          GestureDetector(
            onTap: () => _pickHeight(context),
            child: NeonCard(
              borderColor: TechnoColors.neonCyan.withValues(alpha: 0.4),
              child: Row(
                children: [
                  const Icon(Icons.height,
                      color: TechnoColors.neonCyan, size: 26),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('HEIGHT',
                            style: GoogleFonts.orbitron(
                                color: TechnoColors.textMuted,
                                fontSize: 9,
                                letterSpacing: 1.5)),
                        const SizedBox(height: 2),
                        Text(_displayHeight(),
                            style: GoogleFonts.orbitron(
                                color: TechnoColors.neonCyan,
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: TechnoColors.neonCyan, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Weight card
          GestureDetector(
            onTap: () => _pickWeight(context),
            child: NeonCard(
              borderColor: TechnoColors.neonPink.withValues(alpha: 0.4),
              child: Row(
                children: [
                  const Icon(Icons.monitor_weight_outlined,
                      color: TechnoColors.neonPink, size: 26),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('WEIGHT',
                            style: GoogleFonts.orbitron(
                                color: TechnoColors.textMuted,
                                fontSize: 9,
                                letterSpacing: 1.5)),
                        const SizedBox(height: 2),
                        Text(_displayWeight(),
                            style: GoogleFonts.orbitron(
                                color: TechnoColors.neonPink,
                                fontSize: 20,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right,
                      color: TechnoColors.neonPink, size: 20),
                ],
              ),
            ),
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
  const _StepLocation({required this.preferGym, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      title: 'DEFAULT LOCATION',
      subtitle: 'Where do you usually work out?',
      child: Column(
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
        ],
      ),
    );
  }
}

// ─── Step 4 — Injuries ────────────────────────────────────────────────────────

class _StepInjuries extends StatelessWidget {
  final List<InjuryArea> selected;
  final ValueChanged<InjuryArea> onToggle;
  const _StepInjuries({required this.selected, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return _StepShell(
      title: 'ANY INJURIES?',
      subtitle:
          'Select areas we should avoid or be careful with. You can skip this.',
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: InjuryArea.values.map((injury) {
          final isSelected = selected.contains(injury);
          return GestureDetector(
            onTap: () => onToggle(injury),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
  late int _wholeIndex; // integer part of displayed value
  late int _decIndex;   // decimal digit 0-9
  late int _unitIndex;  // 0=kg, 1=lbs

  late FixedExtentScrollController _wholeCtrl;
  late FixedExtentScrollController _decCtrl;
  late FixedExtentScrollController _unitCtrl;

  // Ranges
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
    _decCtrl = FixedExtentScrollController(initialItem: _decIndex);
    _unitCtrl = FixedExtentScrollController(initialItem: _unitIndex);
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

    double newDisplay;
    int newMax;
    if (newIsKg) {
      newDisplay = kgNow;
      newMax = _kgMax;
    } else {
      newDisplay = kgNow * 2.20462;
      newMax = _lbsMax;
    }

    final newWhole = newDisplay.floor().clamp(0, newMax);
    final newDec = ((newDisplay - newDisplay.floor()) * 10).round().clamp(0, 9);

    setState(() {
      _isKg = newIsKg;
      _unitIndex = index;
      _wholeIndex = newWhole;
      _decIndex = newDec;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_wholeCtrl.hasClients) _wholeCtrl.jumpToItem(_wholeIndex);
      if (_decCtrl.hasClients) _decCtrl.jumpToItem(_decIndex);
    });
  }

  void _confirm() {
    Navigator.pop(context, _WeightResult(_currentKg(), _isKg));
  }

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
          // ── Whole number ──────────────────────────────────────────────
          _WheelColumn(
            width: 90,
            controller: _wholeCtrl,
            items: List.generate(maxWhole + 1, (i) => '$i'),
            color: TechnoColors.neonPink,
            onChanged: (i) => setState(() => _wholeIndex = i),
          ),
          // ── Decimal separator ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text('.',
                style: GoogleFonts.orbitron(
                    color: TechnoColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900)),
          ),
          // ── Decimal digit ─────────────────────────────────────────────
          _WheelColumn(
            width: 56,
            controller: _decCtrl,
            items: List.generate(10, (i) => '$i'),
            color: TechnoColors.neonPink,
            onChanged: (i) => setState(() => _decIndex = i),
          ),
          const SizedBox(width: 16),
          // ── Unit ──────────────────────────────────────────────────────
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
  // cm values: 100–250 → index = value - 100
  late int _cmIndex;
  // ft&in: feet 3–8, inches 0–11
  late int _feetIndex; // 0 = 3ft, 5 = 8ft
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
    _feetIndex = ((totalIn ~/ 12) - 3).clamp(0, 5);
    _inchesIndex = (totalIn % 12).clamp(0, 11);

    _cmCtrl = FixedExtentScrollController(initialItem: _cmIndex);
    _feetCtrl = FixedExtentScrollController(initialItem: _feetIndex);
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
    if (_isCm) {
      return (_cmMin + _cmIndex).toDouble();
    } else {
      final ft = 3 + _feetIndex;
      final totalIn = ft * 12 + _inchesIndex;
      return totalIn * 2.54;
    }
  }

  void _switchUnit(bool toCm) {
    if (_isCm == toCm) return;
    final currentCm = _currentCm();
    setState(() => _isCm = toCm);

    if (toCm) {
      final newCmIndex =
          (currentCm.round() - _cmMin).clamp(0, _cmMax - _cmMin);
      setState(() => _cmIndex = newCmIndex);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_cmCtrl.hasClients) _cmCtrl.jumpToItem(_cmIndex);
      });
    } else {
      final totalIn = (currentCm / 2.54).round();
      final newFt = ((totalIn ~/ 12) - 3).clamp(0, 5);
      final newIn = (totalIn % 12).clamp(0, 11);
      setState(() {
        _feetIndex = newFt;
        _inchesIndex = newIn;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_feetCtrl.hasClients) _feetCtrl.jumpToItem(_feetIndex);
        if (_inchesCtrl.hasClients) _inchesCtrl.jumpToItem(_inchesIndex);
      });
    }
  }

  void _confirm() {
    Navigator.pop(context, _currentCm());
  }

  @override
  Widget build(BuildContext context) {
    return _PickerSheetContainer(
      title: 'HEIGHT',
      accentColor: TechnoColors.neonCyan,
      onDone: _confirm,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Unit toggle ───────────────────────────────────────────────
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
          // ── Wheel(s) ──────────────────────────────────────────────────
          if (_isCm)
            _WheelColumn(
              width: 140,
              controller: _cmCtrl,
              items: List.generate(
                  _cmMax - _cmMin + 1, (i) => '${_cmMin + i}'),
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
                  items: List.generate(6, (i) => "${3 + i} ft"),
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

/// Single column scroll wheel.
class _WheelColumn extends StatelessWidget {
  final List<String> items;
  final FixedExtentScrollController controller;
  final ValueChanged<int> onChanged;
  final Color color;
  final double width;

  static const double _itemExtent = 46;
  static const double _height = 180;

  const _WheelColumn({
    required this.items,
    required this.controller,
    required this.onChanged,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: _height,
      child: Stack(
        children: [
          ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: _itemExtent,
            physics: const FixedExtentScrollPhysics(),
            overAndUnderCenterOpacity: 0.25,
            perspective: 0.003,
            onSelectedItemChanged: onChanged,
            childDelegate: ListWheelChildListDelegate(
              children: items
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
          // Selection band overlay
          IgnorePointer(
            child: Center(
              child: Container(
                height: _itemExtent,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  border: Border.symmetric(
                    horizontal: BorderSide(
                        color: color.withValues(alpha: 0.45), width: 1),
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
