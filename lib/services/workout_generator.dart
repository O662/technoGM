import '../models/models.dart';
import '../data/exercise_database.dart';

class WorkoutGenerator {
  // ─── Generate ──────────────────────────────────────────────────────────────

  static List<WorkoutExerciseLog> generate(WorkoutRequest req) {
    // 1. Get all exercises
    var pool = List<Exercise>.from(kExercises);

    // 2. Filter by injury exclusions
    final excludedIds = <String>{};
    for (final injury in req.injuries) {
      excludedIds.addAll(kInjuryExclusions[injury] ?? []);
    }
    pool.removeWhere((e) => excludedIds.contains(e.id));

    // 3. Filter by available equipment
    pool.removeWhere((e) => !_hasEquipment(e.requiredEquipment, req.availableEquipment));

    // 4. Filter by workout type
    switch (req.type) {
      case WorkoutType.cardio:
        pool.removeWhere((e) => e.type != WorkoutType.cardio);
        break;
      case WorkoutType.bodyweight:
        pool.removeWhere(
          (e) => !e.requiredEquipment.every((eq) => eq == EquipmentType.none || eq == EquipmentType.pullupBar),
        );
        break;
      case WorkoutType.hiit:
        pool.removeWhere((e) => e.type == WorkoutType.strength && !e.isCompound);
        break;
      case WorkoutType.strength:
        pool.removeWhere((e) => e.type == WorkoutType.cardio);
        break;
      case WorkoutType.mixed:
        break;
    }

    // 5. Filter by focus areas (if specified)
    List<Exercise> focusPool = [];
    if (req.focusAreas.isNotEmpty && !req.focusAreas.contains(MuscleGroup.fullBody)) {
      focusPool = pool
          .where(
            (e) =>
                req.focusAreas.contains(e.primaryMuscle) ||
                e.secondaryMuscles.any((m) => req.focusAreas.contains(m)),
          )
          .toList();
    } else {
      focusPool = pool;
    }

    if (focusPool.isEmpty) focusPool = pool;

    // 6. Determine exercise count from duration
    final exerciseCount = _exerciseCount(req.targetMinutes, req.type);

    // 7. Select exercises: compounds first, then isolations
    final compounds = focusPool.where((e) => e.isCompound).toList();
    final isolations = focusPool.where((e) => !e.isCompound).toList();

    compounds.shuffle();
    isolations.shuffle();

    final selected = <Exercise>[];

    // Pick compounds first
    final compoundTarget = (exerciseCount * 0.6).round();
    selected.addAll(compounds.take(compoundTarget));

    // Fill rest with isolations
    final remaining = exerciseCount - selected.length;
    selected.addAll(isolations.take(remaining));

    // If still not enough, take from full pool
    if (selected.length < exerciseCount) {
      for (final e in focusPool) {
        if (!selected.any((s) => s.id == e.id)) {
          selected.add(e);
          if (selected.length >= exerciseCount) break;
        }
      }
    }

    // 8. Convert to WorkoutExerciseLogs with appropriate sets/reps
    return selected.map((e) => _buildLog(e, req)).toList();
  }

  // ─── Private helpers ───────────────────────────────────────────────────────

  static bool _hasEquipment(
    List<EquipmentType> required,
    List<EquipmentType> available,
  ) {
    if (required.isEmpty || required.every((r) => r == EquipmentType.none)) return true;
    if (available.contains(EquipmentType.fullGym)) return true;
    return required.any((r) => r == EquipmentType.none || available.contains(r));
  }

  static int _exerciseCount(int minutes, WorkoutType type) {
    if (type == WorkoutType.cardio) return (minutes / 10).ceil().clamp(2, 5);
    if (minutes <= 20) return 3;
    if (minutes <= 35) return 4;
    if (minutes <= 50) return 5;
    if (minutes <= 65) return 6;
    return 7;
  }

  static WorkoutExerciseLog _buildLog(Exercise e, WorkoutRequest req) {
    int sets = e.defaultSets;
    int repsOrSeconds = e.defaultRepsOrSeconds;

    // Adjust for fitness level
    switch (req.fitnessLevel) {
      case FitnessLevel.beginner:
        sets = (sets - 1).clamp(2, 4);
        if (!e.isTimeBased) repsOrSeconds = (repsOrSeconds * 0.8).round().clamp(6, 20);
        break;
      case FitnessLevel.intermediate:
        // defaults are fine
        break;
      case FitnessLevel.advanced:
        sets = (sets + 1).clamp(3, 6);
        if (!e.isTimeBased) repsOrSeconds = (repsOrSeconds * 1.1).round().clamp(5, 20);
        break;
    }

    // Adjust for HIIT
    if (req.type == WorkoutType.hiit) {
      if (!e.isTimeBased) {
        repsOrSeconds = 15;
      }
    }

    return WorkoutExerciseLog(
      exerciseId: e.id,
      exerciseName: e.name,
      primaryMuscle: e.primaryMuscle,
      isTimeBased: e.isTimeBased,
      sets: List.generate(
        sets,
        (_) => WorkoutSet(repsOrSeconds: repsOrSeconds),
      ),
    );
  }

  // ─── Quick workout templates ───────────────────────────────────────────────

  static List<WorkoutExerciseLog> quickUpperBody(FitnessLevel level, List<InjuryArea> injuries) {
    return generate(WorkoutRequest(
      type: WorkoutType.strength,
      focusAreas: [MuscleGroup.chest, MuscleGroup.back, MuscleGroup.shoulders],
      availableEquipment: [EquipmentType.dumbbells, EquipmentType.bench, EquipmentType.pullupBar],
      fitnessLevel: level,
      injuries: injuries,
      targetMinutes: 45,
      isAtGym: false,
    ));
  }

  static List<WorkoutExerciseLog> quickLowerBody(FitnessLevel level, List<InjuryArea> injuries) {
    return generate(WorkoutRequest(
      type: WorkoutType.strength,
      focusAreas: [MuscleGroup.quadriceps, MuscleGroup.hamstrings, MuscleGroup.glutes],
      availableEquipment: [EquipmentType.none],
      fitnessLevel: level,
      injuries: injuries,
      targetMinutes: 40,
      isAtGym: false,
    ));
  }

  static List<WorkoutExerciseLog> quickHIIT(FitnessLevel level, List<InjuryArea> injuries) {
    return generate(WorkoutRequest(
      type: WorkoutType.hiit,
      focusAreas: [MuscleGroup.fullBody],
      availableEquipment: [EquipmentType.none],
      fitnessLevel: level,
      injuries: injuries,
      targetMinutes: 20,
      isAtGym: false,
    ));
  }

  static List<WorkoutExerciseLog> quickCore(FitnessLevel level, List<InjuryArea> injuries) {
    return generate(WorkoutRequest(
      type: WorkoutType.bodyweight,
      focusAreas: [MuscleGroup.core],
      availableEquipment: [EquipmentType.none],
      fitnessLevel: level,
      injuries: injuries,
      targetMinutes: 20,
      isAtGym: false,
    ));
  }
}
