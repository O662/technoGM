import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/app_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_card.dart';
import 'active_workout_screen.dart';
import 'generate_workout_screen.dart';
import 'muscle_chart_tab.dart';
import 'running_plan_screen.dart';

class WorkoutHubScreen extends StatefulWidget {
  const WorkoutHubScreen({super.key});

  @override
  State<WorkoutHubScreen> createState() => _WorkoutHubScreenState();
}

class _WorkoutHubScreenState extends State<WorkoutHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  int _selectedDuration = 30;
  String? _selectedEquipment;
  String? _selectedBodyPart;
  String? _selectedFormat;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('WORKOUTS'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TabBar(
              controller: _tabs,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: TechnoColors.neonCyan.withValues(alpha: 0.15),
                border: Border.all(color: TechnoColors.neonCyan, width: 1.5),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: TechnoColors.neonCyan,
              unselectedLabelColor: TechnoColors.textMuted,
              labelStyle: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
              unselectedLabelStyle: GoogleFonts.orbitron(
                fontSize: 10,
                letterSpacing: 1.5,
              ),
              labelPadding: const EdgeInsets.symmetric(horizontal: 16),
              tabs: const [
                Tab(text: 'FEATURED'),
                Tab(text: 'WORKOUTS'),
                Tab(text: 'PLANS'),
                Tab(text: 'MUSCLES'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          // ── Tab 1: Featured ──────────────────────────────────────────────
          const _FeaturedTab(),

          // ── Tab 2: Workout hub content ───────────────────────────────────
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (provider.hasActiveWorkout) ...[
                  _ActiveWorkoutBanner(provider: provider),
                  const SizedBox(height: 16),
                ],
                NeonButton(
                  label: 'GENERATE WORKOUT',
                  icon: Icons.bolt,
                  color: TechnoColors.neonCyan,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const GenerateWorkoutScreen()),
                  ),
                ),
                const SizedBox(height: 10),
                NeonButton(
                  label: 'START BLANK WORKOUT',
                  icon: Icons.play_arrow,
                  color: TechnoColors.neonPurple,
                  outlined: true,
                  onTap: () => _startBlank(context, provider),
                ),
                const SizedBox(height: 24),
                Text(
                  'WORKOUT TYPES',
                  style: GoogleFonts.orbitron(
                    color: TechnoColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                _workoutTypesRow(context, provider),
                const SizedBox(height: 24),
                Text(
                  'DURATION',
                  style: GoogleFonts.orbitron(
                    color: TechnoColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                _durationRow(),
                const SizedBox(height: 24),
                Text(
                  'EQUIPMENT',
                  style: GoogleFonts.orbitron(
                    color: TechnoColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                _pillRow(
                  items: const [
                    'NO EQUIPMENT',
                    'DUMBBELLS',
                    'RESISTANCE BANDS',
                    'BARBELL',
                    'KETTLEBELL',
                    'PULL-UP BAR',
                    'CABLE MACHINE',
                    'FULL GYM',
                  ],
                  selected: _selectedEquipment,
                  onSelect: (v) => setState(() =>
                      _selectedEquipment = _selectedEquipment == v ? null : v),
                ),
                const SizedBox(height: 24),
                Text(
                  'BODY PART',
                  style: GoogleFonts.orbitron(
                    color: TechnoColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                _pillRow(
                  items: const [
                    'FULL BODY',
                    'CHEST',
                    'BACK',
                    'SHOULDERS',
                    'ARMS',
                    'BICEPS',
                    'TRICEPS',
                    'ABS',
                    'CORE',
                    'UPPER BODY',
                    'LOWER BODY',
                    'LEGS',
                    'GLUTES',
                    'HAMSTRINGS',
                    'QUADS',
                    'CALVES',
                  ],
                  selected: _selectedBodyPart,
                  onSelect: (v) => setState(() =>
                      _selectedBodyPart = _selectedBodyPart == v ? null : v),
                ),
                const SizedBox(height: 24),
                Text(
                  'FORMAT',
                  style: GoogleFonts.orbitron(
                    color: TechnoColors.textSecondary,
                    fontSize: 11,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 10),
                _pillRow(
                  items: const ['SETS & REPS', 'FOLLOW ALONG'],
                  selected: _selectedFormat,
                  onSelect: (v) => setState(() =>
                      _selectedFormat = _selectedFormat == v ? null : v),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),

          // ── Tab 3: Plans ─────────────────────────────────────────────────
          const _PlansTab(),

          // ── Tab 4: Muscle Chart ───────────────────────────────────────────
          const MuscleChartTab(),

        ],
      ),
    );
  }

  static const _workoutTypeList = [
    _WorkoutTypeInfo(
      icon: '🏋️',
      name: 'Strength',
      description: 'Build muscle with progressive overload.',
      color: TechnoColors.neonCyan,
      type: WorkoutType.strength,
      equipment: [EquipmentType.dumbbells, EquipmentType.barbell, EquipmentType.bench],
    ),
    _WorkoutTypeInfo(
      icon: '🏃',
      name: 'Cardio',
      description: 'Improve endurance and burn calories.',
      color: TechnoColors.neonOrange,
      type: WorkoutType.cardio,
      equipment: [EquipmentType.none],
    ),
    _WorkoutTypeInfo(
      icon: '⚡',
      name: 'HIIT',
      description: 'Maximum results in minimum time.',
      color: TechnoColors.neonYellow,
      type: WorkoutType.hiit,
      equipment: [EquipmentType.none],
    ),
    _WorkoutTypeInfo(
      icon: '💪',
      name: 'Bodyweight',
      description: 'Train anywhere with zero equipment.',
      color: TechnoColors.neonGreen,
      type: WorkoutType.bodyweight,
      equipment: [EquipmentType.none],
    ),
    _WorkoutTypeInfo(
      icon: '🧘',
      name: 'Mobility',
      description: 'Improve flexibility and range of motion.',
      color: TechnoColors.neonPurple,
      type: WorkoutType.mixed,
      equipment: [EquipmentType.none],
    ),
    _WorkoutTypeInfo(
      icon: '🔥',
      name: 'Warm Up',
      description: 'Prep your body and prevent injury.',
      color: TechnoColors.neonOrange,
      type: WorkoutType.mixed,
      equipment: [EquipmentType.none],
    ),
    _WorkoutTypeInfo(
      icon: '🤸',
      name: 'Stretch',
      description: 'Cool down and improve recovery.',
      color: TechnoColors.neonGreen,
      type: WorkoutType.mixed,
      equipment: [EquipmentType.none],
    ),
  ];

  Widget _workoutTypesRow(BuildContext context, AppProvider provider) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _workoutTypeList.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) =>
            _WorkoutTypeCard(info: _workoutTypeList[i], provider: provider),
      ),
    );
  }

  Widget _durationRow() {
    const durations = [15, 20, 30, 45, 60];
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: durations.map((d) {
          final selected = _selectedDuration == d;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedDuration = d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: selected
                      ? TechnoColors.neonCyan.withValues(alpha: 0.15)
                      : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? TechnoColors.neonCyan
                        : TechnoColors.textMuted.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  d == 60 ? '60+ MIN' : '$d MIN',
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                    color: selected ? TechnoColors.neonCyan : TechnoColors.textMuted,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _pillRow({
    required List<String> items,
    required String? selected,
    required void Function(String) onSelect,
  }) {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: items.map((item) {
          final isSelected = selected == item;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onSelect(item),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isSelected
                      ? TechnoColors.neonCyan.withValues(alpha: 0.15)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? TechnoColors.neonCyan
                        : TechnoColors.textMuted.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  item,
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                    color: isSelected ? TechnoColors.neonCyan : TechnoColors.textMuted,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _startBlank(BuildContext context, AppProvider provider) {
    if (provider.hasActiveWorkout) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Finish your current workout first!')),
      );
      return;
    }
    provider.startWorkout(
      name: 'My Workout',
      type: WorkoutType.mixed,
      isAtGym: provider.data.profile.preferGym,
      exercises: [],
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
    );
  }
}

class _ActiveWorkoutBanner extends StatelessWidget {
  final AppProvider provider;
  const _ActiveWorkoutBanner({required this.provider});

  @override
  Widget build(BuildContext context) {
    final workout = provider.activeWorkout!;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
      ),
      child: NeonCard(
        borderColor: TechnoColors.neonGreen,
        child: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: TechnoColors.neonGreen,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'WORKOUT IN PROGRESS',
                    style: GoogleFonts.orbitron(
                      color: TechnoColors.neonGreen,
                      fontSize: 10,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    workout.name,
                    style: GoogleFonts.rajdhani(
                      color: TechnoColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: TechnoColors.neonGreen, size: 16),
          ],
        ),
      ),
    );
  }
}

class _WorkoutTypeInfo {
  final String icon;
  final String name;
  final String description;
  final Color color;
  final WorkoutType type;
  final List<EquipmentType> equipment;

  const _WorkoutTypeInfo({
    required this.icon,
    required this.name,
    required this.description,
    required this.color,
    required this.type,
    required this.equipment,
  });
}

class _FeaturedTab extends StatelessWidget {
  const _FeaturedTab();

  @override
  Widget build(BuildContext context) {
    final featured = [
      _FeaturedWorkout(
        title: '30-Min Full Body Blast',
        subtitle: 'Strength · Intermediate',
        emoji: '🔥',
        color: TechnoColors.neonOrange,
      ),
      _FeaturedWorkout(
        title: '20-Min HIIT Cardio',
        subtitle: 'HIIT · Beginner',
        emoji: '⚡',
        color: TechnoColors.neonYellow,
      ),
      _FeaturedWorkout(
        title: 'Upper Body Power',
        subtitle: 'Strength · Advanced',
        emoji: '💪',
        color: TechnoColors.neonCyan,
      ),
      _FeaturedWorkout(
        title: 'Core & Mobility Flow',
        subtitle: 'Bodyweight · All Levels',
        emoji: '🧘',
        color: TechnoColors.neonGreen,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'FEATURED WORKOUTS',
            style: GoogleFonts.orbitron(
              color: TechnoColors.textSecondary,
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          ...featured.map((w) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: NeonCard(
              borderColor: w.color.withValues(alpha: 0.3),
              child: Row(
                children: [
                  Text(w.emoji, style: const TextStyle(fontSize: 30)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w.title,
                          style: GoogleFonts.rajdhani(
                            color: TechnoColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          w.subtitle,
                          style: GoogleFonts.rajdhani(
                            color: TechnoColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: w.color, size: 16),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}

class _FeaturedWorkout {
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  const _FeaturedWorkout({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
  });
}

class _PlansTab extends StatefulWidget {
  const _PlansTab();

  @override
  State<_PlansTab> createState() => _PlansTabState();
}

class _PlansTabState extends State<_PlansTab> {
  int _selectedDays = 4;

  static const _plans = [
    _PlanInfo(
      emoji: '🏃',
      title: '10-Week Beginner Running Plan',
      meta: '10 weeks · 3 days/week · Cardio',
      color: TechnoColors.neonOrange,
    ),
    _PlanInfo(
      emoji: '🔥',
      title: 'Fat Loss Plan',
      meta: '8 weeks · 4 days/week · HIIT + Strength',
      color: TechnoColors.neonYellow,
    ),
    _PlanInfo(
      emoji: '💪',
      title: 'Beginner Mass Builder',
      meta: '12 weeks · 4 days/week · Strength',
      color: TechnoColors.neonCyan,
    ),
    _PlanInfo(
      emoji: '⚡',
      title: 'Beginner Conditioning Plan',
      meta: '6 weeks · 3 days/week · HIIT',
      color: TechnoColors.neonGreen,
    ),
    _PlanInfo(
      emoji: '🧘',
      title: 'Beginner Mobility Program',
      meta: '4 weeks · 5 days/week · Mobility',
      color: TechnoColors.neonPurple,
    ),
    _PlanInfo(
      emoji: '🏋️',
      title: 'Strength Foundations',
      meta: '8 weeks · 3 days/week · Strength',
      color: TechnoColors.neonCyan,
    ),
    _PlanInfo(
      emoji: '🤸',
      title: '30-Day Flexibility Challenge',
      meta: '4 weeks · 7 days/week · Stretch',
      color: TechnoColors.neonGreen,
    ),
    _PlanInfo(
      emoji: '🧱',
      title: 'Bodyweight Build',
      meta: '8 weeks · 4 days/week · Bodyweight',
      color: TechnoColors.neonPurple,
    ),
    _PlanInfo(
      emoji: '🚴',
      title: 'Cardio Endurance Builder',
      meta: '6 weeks · 4 days/week · Cardio',
      color: TechnoColors.neonOrange,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DAYS PER WEEK',
            style: GoogleFonts.orbitron(
              color: TechnoColors.textSecondary,
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [3, 4, 5, 6, 7].map((d) {
                final selected = _selectedDays == d;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDays = d),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: selected
                            ? TechnoColors.neonCyan.withValues(alpha: 0.15)
                            : Colors.transparent,
                        border: Border.all(
                          color: selected
                              ? TechnoColors.neonCyan
                              : TechnoColors.textMuted.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '$d DAYS',
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                          color: selected ? TechnoColors.neonCyan : TechnoColors.textMuted,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'BROWSE PLANS',
            style: GoogleFonts.orbitron(
              color: TechnoColors.textSecondary,
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          ..._plans.map((plan) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () {
                if (plan.title == '10-Week Beginner Running Plan') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const RunningPlanScreen()),
                  );
                }
              },
              child: NeonCard(
                borderColor: plan.color.withValues(alpha: 0.3),
                child: Row(
                children: [
                  Text(plan.emoji, style: const TextStyle(fontSize: 30)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.title,
                          style: GoogleFonts.rajdhani(
                            color: TechnoColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          plan.meta,
                          style: GoogleFonts.rajdhani(
                            color: TechnoColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: plan.color, size: 16),
                ],
              ),
            ),
          ),
          )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _PlanInfo {
  final String emoji;
  final String title;
  final String meta;
  final Color color;

  const _PlanInfo({
    required this.emoji,
    required this.title,
    required this.meta,
    required this.color,
  });
}

class _WorkoutTypeCard extends StatelessWidget {
  final _WorkoutTypeInfo info;
  final AppProvider provider;

  const _WorkoutTypeCard({required this.info, required this.provider});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GenerateWorkoutScreen(
            presetType: info.type,
            presetEquipment: info.equipment,
          ),
        ),
      ),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: info.color.withValues(alpha: 0.07),
          border: Border.all(color: info.color.withValues(alpha: 0.35), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(info.icon, style: const TextStyle(fontSize: 32)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.name,
                  style: GoogleFonts.rajdhani(
                    color: TechnoColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  info.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.rajdhani(
                    color: TechnoColors.textSecondary,
                    fontSize: 11,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
