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
import 'muscle_map_tab.dart';

class WorkoutHubScreen extends StatefulWidget {
  const WorkoutHubScreen({super.key});

  @override
  State<WorkoutHubScreen> createState() => _WorkoutHubScreenState();
}

class _WorkoutHubScreenState extends State<WorkoutHubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
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
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: TechnoColors.neonCyan,
          indicatorWeight: 2,
          labelColor: TechnoColors.neonCyan,
          unselectedLabelColor: TechnoColors.textMuted,
          labelStyle: GoogleFonts.orbitron(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
          unselectedLabelStyle: GoogleFonts.orbitron(
            fontSize: 10,
            letterSpacing: 2,
          ),
          tabs: const [
            Tab(text: 'WORKOUTS'),
            Tab(text: 'MUSCLES'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          // ── Tab 1: Workout hub content ───────────────────────────────────
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
                ..._workoutTypes(context, provider),
              ],
            ),
          ),

          // ── Tab 2: Muscle map ────────────────────────────────────────────
          const MuscleMapTab(),
        ],
      ),
    );
  }

  List<Widget> _workoutTypes(BuildContext context, AppProvider provider) {
    final types = [
      _WorkoutTypeInfo(
        icon: '🏋️',
        name: 'Strength Training',
        description: 'Build muscle and increase strength with progressive overload.',
        color: TechnoColors.neonCyan,
        type: WorkoutType.strength,
        equipment: [EquipmentType.dumbbells, EquipmentType.barbell, EquipmentType.bench],
      ),
      _WorkoutTypeInfo(
        icon: '🏃',
        name: 'Cardio',
        description: 'Improve endurance and burn calories with sustained aerobic effort.',
        color: TechnoColors.neonOrange,
        type: WorkoutType.cardio,
        equipment: [EquipmentType.none],
      ),
      _WorkoutTypeInfo(
        icon: '⚡',
        name: 'HIIT',
        description: 'High-Intensity Interval Training — maximum results in minimum time.',
        color: TechnoColors.neonYellow,
        type: WorkoutType.hiit,
        equipment: [EquipmentType.none],
      ),
      _WorkoutTypeInfo(
        icon: '💪',
        name: 'Bodyweight',
        description: 'Train anywhere with zero equipment using your own bodyweight.',
        color: TechnoColors.neonGreen,
        type: WorkoutType.bodyweight,
        equipment: [EquipmentType.none],
      ),
    ];

    return types.map((t) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _WorkoutTypeTile(info: t, provider: provider),
    )).toList();
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

class _WorkoutTypeTile extends StatelessWidget {
  final _WorkoutTypeInfo info;
  final AppProvider provider;

  const _WorkoutTypeTile({required this.info, required this.provider});

  @override
  Widget build(BuildContext context) {
    return NeonCard(
      borderColor: info.color.withValues(alpha: 0.3),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GenerateWorkoutScreen(
            presetType: info.type,
            presetEquipment: info.equipment,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(info.icon, style: const TextStyle(fontSize: 30)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  info.name,
                  style: GoogleFonts.rajdhani(
                    color: TechnoColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  info.description,
                  style: GoogleFonts.rajdhani(
                    color: TechnoColors.textSecondary,
                    fontSize: 13,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: info.color, size: 16),
        ],
      ),
    );
  }
}
