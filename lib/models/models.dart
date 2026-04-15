import 'package:uuid/uuid.dart';

// ─── Enums ───────────────────────────────────────────────────────────────────

enum WorkoutType { strength, cardio, hiit, bodyweight, mixed }

enum FitnessLevel { beginner, intermediate, advanced }

enum MuscleGroup {
  chest,
  back,
  shoulders,
  biceps,
  triceps,
  forearms,
  quadriceps,
  hamstrings,
  glutes,
  calves,
  core,
  fullBody,
  cardio,
}

enum EquipmentType {
  none,
  dumbbells,
  barbell,
  machine,
  cables,
  pullupBar,
  resistanceBands,
  kettlebell,
  bench,
  fullGym,
}

enum InjuryArea { shoulder, lowerBack, knee, wrist, hip, ankle, elbow, neck }

enum InjurySide { left, right }

extension InjurySideX on InjurySide {
  String get label {
    switch (this) {
      case InjurySide.left:
        return 'Left';
      case InjurySide.right:
        return 'Right';
    }
  }
}

enum FitnessGoal {
  buildMuscle,
  loseWeight,
  improveEndurance,
  increaseStrength,
  improveFlexibility,
  generalFitness,
}

extension FitnessGoalX on FitnessGoal {
  String get label {
    switch (this) {
      case FitnessGoal.buildMuscle:
        return 'Build Muscle';
      case FitnessGoal.loseWeight:
        return 'Lose Weight';
      case FitnessGoal.improveEndurance:
        return 'Improve Endurance';
      case FitnessGoal.increaseStrength:
        return 'Increase Strength';
      case FitnessGoal.improveFlexibility:
        return 'Improve Flexibility';
      case FitnessGoal.generalFitness:
        return 'General Fitness';
    }
  }

  String get emoji {
    switch (this) {
      case FitnessGoal.buildMuscle:
        return '💪';
      case FitnessGoal.loseWeight:
        return '🔥';
      case FitnessGoal.improveEndurance:
        return '🏃';
      case FitnessGoal.increaseStrength:
        return '🏋️';
      case FitnessGoal.improveFlexibility:
        return '🧘';
      case FitnessGoal.generalFitness:
        return '⭐';
    }
  }
}

// ─── Enum helpers ─────────────────────────────────────────────────────────────

extension WorkoutTypeX on WorkoutType {
  String get label {
    switch (this) {
      case WorkoutType.strength:
        return 'Strength';
      case WorkoutType.cardio:
        return 'Cardio';
      case WorkoutType.hiit:
        return 'HIIT';
      case WorkoutType.bodyweight:
        return 'Bodyweight';
      case WorkoutType.mixed:
        return 'Mixed';
    }
  }

  String get emoji {
    switch (this) {
      case WorkoutType.strength:
        return '🏋️';
      case WorkoutType.cardio:
        return '🏃';
      case WorkoutType.hiit:
        return '⚡';
      case WorkoutType.bodyweight:
        return '💪';
      case WorkoutType.mixed:
        return '🔥';
    }
  }
}

extension MuscleGroupX on MuscleGroup {
  String get label {
    switch (this) {
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.back:
        return 'Back';
      case MuscleGroup.shoulders:
        return 'Shoulders';
      case MuscleGroup.biceps:
        return 'Biceps';
      case MuscleGroup.triceps:
        return 'Triceps';
      case MuscleGroup.forearms:
        return 'Forearms';
      case MuscleGroup.quadriceps:
        return 'Quads';
      case MuscleGroup.hamstrings:
        return 'Hamstrings';
      case MuscleGroup.glutes:
        return 'Glutes';
      case MuscleGroup.calves:
        return 'Calves';
      case MuscleGroup.core:
        return 'Core';
      case MuscleGroup.fullBody:
        return 'Full Body';
      case MuscleGroup.cardio:
        return 'Cardio';
    }
  }
}

extension InjuryAreaX on InjuryArea {
  String get label {
    switch (this) {
      case InjuryArea.shoulder:
        return 'Shoulder';
      case InjuryArea.lowerBack:
        return 'Lower Back';
      case InjuryArea.knee:
        return 'Knee';
      case InjuryArea.wrist:
        return 'Wrist';
      case InjuryArea.hip:
        return 'Hip';
      case InjuryArea.ankle:
        return 'Ankle';
      case InjuryArea.elbow:
        return 'Elbow';
      case InjuryArea.neck:
        return 'Neck';
    }
  }
}

extension EquipmentTypeX on EquipmentType {
  String get label {
    switch (this) {
      case EquipmentType.none:
        return 'No Equipment';
      case EquipmentType.dumbbells:
        return 'Dumbbells';
      case EquipmentType.barbell:
        return 'Barbell';
      case EquipmentType.machine:
        return 'Machine';
      case EquipmentType.cables:
        return 'Cables';
      case EquipmentType.pullupBar:
        return 'Pull-up Bar';
      case EquipmentType.resistanceBands:
        return 'Resistance Bands';
      case EquipmentType.kettlebell:
        return 'Kettlebell';
      case EquipmentType.bench:
        return 'Bench';
      case EquipmentType.fullGym:
        return 'Full Gym';
    }
  }
}

// ─── Exercise ─────────────────────────────────────────────────────────────────

class Exercise {
  final String id;
  final String name;
  final MuscleGroup primaryMuscle;
  final List<MuscleGroup> secondaryMuscles;
  final List<EquipmentType> requiredEquipment;
  final FitnessLevel difficulty;
  final WorkoutType type;
  final String instructions;
  final String tips;
  final bool isTimeBased;
  final int defaultSets;
  final int defaultRepsOrSeconds;
  final int restSeconds;
  final bool isCompound;

  const Exercise({
    required this.id,
    required this.name,
    required this.primaryMuscle,
    required this.secondaryMuscles,
    required this.requiredEquipment,
    required this.difficulty,
    required this.type,
    required this.instructions,
    this.tips = '',
    this.isTimeBased = false,
    this.defaultSets = 3,
    this.defaultRepsOrSeconds = 10,
    this.restSeconds = 60,
    this.isCompound = false,
  });
}

// ─── Workout Set ──────────────────────────────────────────────────────────────

class WorkoutSet {
  double weight;
  int repsOrSeconds;
  bool completed;

  WorkoutSet({
    this.weight = 0,
    this.repsOrSeconds = 10,
    this.completed = false,
  });

  WorkoutSet.fromJson(Map<String, dynamic> j)
    : weight = (j['weight'] as num).toDouble(),
      repsOrSeconds = j['repsOrSeconds'] as int,
      completed = j['completed'] as bool;

  Map<String, dynamic> toJson() => {
    'weight': weight,
    'repsOrSeconds': repsOrSeconds,
    'completed': completed,
  };
}

// ─── Workout Exercise Log ─────────────────────────────────────────────────────

class WorkoutExerciseLog {
  final String exerciseId;
  final String exerciseName;
  final MuscleGroup primaryMuscle;
  final bool isTimeBased;
  List<WorkoutSet> sets;
  String notes;

  WorkoutExerciseLog({
    required this.exerciseId,
    required this.exerciseName,
    required this.primaryMuscle,
    this.isTimeBased = false,
    required this.sets,
    this.notes = '',
  });

  WorkoutExerciseLog.fromJson(Map<String, dynamic> j)
    : exerciseId = j['exerciseId'] as String,
      exerciseName = j['exerciseName'] as String,
      primaryMuscle = MuscleGroup.values.firstWhere(
        (e) => e.name == j['primaryMuscle'],
        orElse: () => MuscleGroup.fullBody,
      ),
      isTimeBased = j['isTimeBased'] as bool? ?? false,
      sets = (j['sets'] as List).map((s) => WorkoutSet.fromJson(s)).toList(),
      notes = j['notes'] as String? ?? '';

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'primaryMuscle': primaryMuscle.name,
    'isTimeBased': isTimeBased,
    'sets': sets.map((s) => s.toJson()).toList(),
    'notes': notes,
  };

  double get totalVolume =>
      sets.where((s) => s.completed).fold(0, (sum, s) => sum + s.weight * s.repsOrSeconds);
}

// ─── Completed Workout ────────────────────────────────────────────────────────

class CompletedWorkout {
  final String id;
  String name;
  final DateTime startTime;
  final DateTime endTime;
  WorkoutType type;
  bool isAtGym;
  List<WorkoutExerciseLog> exercises;
  String notes;
  int caloriesBurned;

  CompletedWorkout({
    String? id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.type,
    required this.isAtGym,
    required this.exercises,
    this.notes = '',
    this.caloriesBurned = 0,
  }) : id = id ?? const Uuid().v4();

  int get durationMinutes => endTime.difference(startTime).inMinutes;

  double get totalVolume =>
      exercises.fold(0.0, (sum, e) => sum + e.totalVolume);

  int get totalSets => exercises.fold(0, (sum, e) => sum + e.sets.where((s) => s.completed).length);

  CompletedWorkout.fromJson(Map<String, dynamic> j)
    : id = j['id'] as String,
      name = j['name'] as String,
      startTime = DateTime.parse(j['startTime'] as String),
      endTime = DateTime.parse(j['endTime'] as String),
      type = WorkoutType.values.firstWhere(
        (e) => e.name == j['type'],
        orElse: () => WorkoutType.mixed,
      ),
      isAtGym = j['isAtGym'] as bool? ?? false,
      exercises =
          (j['exercises'] as List).map((e) => WorkoutExerciseLog.fromJson(e)).toList(),
      notes = j['notes'] as String? ?? '',
      caloriesBurned = j['caloriesBurned'] as int? ?? 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'type': type.name,
    'isAtGym': isAtGym,
    'exercises': exercises.map((e) => e.toJson()).toList(),
    'notes': notes,
    'caloriesBurned': caloriesBurned,
  };
}

// ─── Body Weight Entry ────────────────────────────────────────────────────────

class BodyWeightEntry {
  final DateTime date;
  final double weightKg;
  final String notes;

  BodyWeightEntry({
    required this.date,
    required this.weightKg,
    this.notes = '',
  });

  BodyWeightEntry.fromJson(Map<String, dynamic> j)
    : date = DateTime.parse(j['date'] as String),
      weightKg = (j['weightKg'] as num).toDouble(),
      notes = j['notes'] as String? ?? '';

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'weightKg': weightKg,
    'notes': notes,
  };
}

// ─── Streak Data ──────────────────────────────────────────────────────────────

class StreakData {
  int currentWeekStreak;
  int bestWeekStreak;
  int weeklySessionGoal;
  int weeklyMinutesGoal;

  StreakData({
    this.currentWeekStreak = 0,
    this.bestWeekStreak = 0,
    this.weeklySessionGoal = 3,
    this.weeklyMinutesGoal = 150,
  });

  StreakData.fromJson(Map<String, dynamic> j)
    : currentWeekStreak = j['currentWeekStreak'] as int? ?? 0,
      bestWeekStreak = j['bestWeekStreak'] as int? ?? 0,
      weeklySessionGoal = j['weeklySessionGoal'] as int? ?? 3,
      weeklyMinutesGoal = j['weeklyMinutesGoal'] as int? ?? 150;

  Map<String, dynamic> toJson() => {
    'currentWeekStreak': currentWeekStreak,
    'bestWeekStreak': bestWeekStreak,
    'weeklySessionGoal': weeklySessionGoal,
    'weeklyMinutesGoal': weeklyMinutesGoal,
  };
}

// ─── Personal Record ──────────────────────────────────────────────────────────

class PersonalRecord {
  final String exerciseId;
  final String exerciseName;
  final double weightKg;
  final int reps;
  final DateTime date;

  PersonalRecord({
    required this.exerciseId,
    required this.exerciseName,
    required this.weightKg,
    required this.reps,
    required this.date,
  });

  PersonalRecord.fromJson(Map<String, dynamic> j)
    : exerciseId = j['exerciseId'] as String,
      exerciseName = j['exerciseName'] as String,
      weightKg = (j['weightKg'] as num).toDouble(),
      reps = j['reps'] as int,
      date = DateTime.parse(j['date'] as String);

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'exerciseName': exerciseName,
    'weightKg': weightKg,
    'reps': reps,
    'date': date.toIso8601String(),
  };

  double get oneRepMax => weightKg * (1 + reps / 30.0);
}

// ─── User Profile ─────────────────────────────────────────────────────────────

class UserProfile {
  String name;
  double heightCm;
  List<InjuryArea> injuries;
  FitnessLevel fitnessLevel;
  List<MuscleGroup> focusAreas;
  List<FitnessGoal> goals;
  bool preferKg;
  bool preferGym;
  List<EquipmentType> homeEquipment;
  Map<InjuryArea, List<InjurySide>> injurySides;
  double? goalWeightKg;

  UserProfile({
    this.name = '',
    this.heightCm = 170,
    this.injuries = const [],
    this.fitnessLevel = FitnessLevel.intermediate,
    this.focusAreas = const [],
    this.goals = const [],
    this.preferKg = true,
    this.preferGym = true,
    this.homeEquipment = const [],
    this.injurySides = const {},
    this.goalWeightKg,
  });

  UserProfile.fromJson(Map<String, dynamic> j)
    : name = j['name'] as String? ?? '',
      heightCm = (j['heightCm'] as num?)?.toDouble() ?? 170,
      injuries =
          (j['injuries'] as List? ?? [])
              .map(
                (e) => InjuryArea.values.firstWhere(
                  (i) => i.name == e,
                  orElse: () => InjuryArea.shoulder,
                ),
              )
              .toList(),
      fitnessLevel = FitnessLevel.values.firstWhere(
        (e) => e.name == j['fitnessLevel'],
        orElse: () => FitnessLevel.intermediate,
      ),
      focusAreas =
          (j['focusAreas'] as List? ?? [])
              .map(
                (e) => MuscleGroup.values.firstWhere(
                  (m) => m.name == e,
                  orElse: () => MuscleGroup.fullBody,
                ),
              )
              .toList(),
      goals =
          (j['goals'] as List? ?? [])
              .map(
                (e) => FitnessGoal.values.firstWhere(
                  (g) => g.name == e,
                  orElse: () => FitnessGoal.generalFitness,
                ),
              )
              .toList(),
      preferKg = j['preferKg'] as bool? ?? true,
      preferGym = j['preferGym'] as bool? ?? true,
      homeEquipment =
          (j['homeEquipment'] as List? ?? [])
              .map(
                (e) => EquipmentType.values.firstWhere(
                  (eq) => eq.name == e,
                  orElse: () => EquipmentType.none,
                ),
              )
              .toList(),
      injurySides = (j['injurySides'] as Map<String, dynamic>? ?? {}).map(
        (k, v) => MapEntry(
          InjuryArea.values.firstWhere(
            (a) => a.name == k,
            orElse: () => InjuryArea.shoulder,
          ),
          (v as List)
              .map((s) => InjurySide.values.firstWhere(
                    (side) => side.name == s,
                    orElse: () => InjurySide.left,
                  ))
              .toList(),
        ),
      ),
      goalWeightKg = (j['goalWeightKg'] as num?)?.toDouble();

  Map<String, dynamic> toJson() => {
    'name': name,
    'heightCm': heightCm,
    'injuries': injuries.map((e) => e.name).toList(),
    'fitnessLevel': fitnessLevel.name,
    'focusAreas': focusAreas.map((e) => e.name).toList(),
    'goals': goals.map((e) => e.name).toList(),
    'preferKg': preferKg,
    'preferGym': preferGym,
    'homeEquipment': homeEquipment.map((e) => e.name).toList(),
    'injurySides': injurySides.map(
      (k, v) => MapEntry(k.name, v.map((s) => s.name).toList()),
    ),
    'goalWeightKg': goalWeightKg,
  };
}

// ─── App Data (root) ──────────────────────────────────────────────────────────

class AppData {
  UserProfile profile;
  List<CompletedWorkout> workouts;
  List<BodyWeightEntry> weightHistory;
  StreakData streak;
  List<PersonalRecord> personalRecords;
  DateTime? lastExported;
  bool hasCompletedOnboarding;

  AppData({
    UserProfile? profile,
    List<CompletedWorkout>? workouts,
    List<BodyWeightEntry>? weightHistory,
    StreakData? streak,
    List<PersonalRecord>? personalRecords,
    this.lastExported,
    this.hasCompletedOnboarding = false,
  }) : profile = profile ?? UserProfile(),
       workouts = workouts ?? [],
       weightHistory = weightHistory ?? [],
       streak = streak ?? StreakData(),
       personalRecords = personalRecords ?? [];

  AppData.fromJson(Map<String, dynamic> j)
    : profile = UserProfile.fromJson(j['profile'] as Map<String, dynamic>? ?? {}),
      workouts =
          (j['workouts'] as List? ?? [])
              .map((e) => CompletedWorkout.fromJson(e))
              .toList(),
      weightHistory =
          (j['weightHistory'] as List? ?? [])
              .map((e) => BodyWeightEntry.fromJson(e))
              .toList(),
      streak = StreakData.fromJson(j['streak'] as Map<String, dynamic>? ?? {}),
      personalRecords =
          (j['personalRecords'] as List? ?? [])
              .map((e) => PersonalRecord.fromJson(e))
              .toList(),
      lastExported =
          j['lastExported'] != null ? DateTime.parse(j['lastExported'] as String) : null,
      hasCompletedOnboarding = j['hasCompletedOnboarding'] as bool? ?? false;

  Map<String, dynamic> toJson() => {
    'profile': profile.toJson(),
    'workouts': workouts.map((e) => e.toJson()).toList(),
    'weightHistory': weightHistory.map((e) => e.toJson()).toList(),
    'streak': streak.toJson(),
    'personalRecords': personalRecords.map((e) => e.toJson()).toList(),
    'lastExported': lastExported?.toIso8601String(),
    'hasCompletedOnboarding': hasCompletedOnboarding,
    '_exportedAt': DateTime.now().toIso8601String(),
    '_version': '1.0.0',
  };
}

// ─── Active Workout (transient, not persisted) ────────────────────────────────

class ActiveWorkout {
  String name;
  WorkoutType type;
  bool isAtGym;
  final DateTime startTime;
  List<WorkoutExerciseLog> exercises;

  ActiveWorkout({
    required this.name,
    required this.type,
    required this.isAtGym,
    required this.exercises,
  }) : startTime = DateTime.now();

  int get elapsedMinutes => DateTime.now().difference(startTime).inMinutes;
}

// ─── Workout Request (for generator) ─────────────────────────────────────────

class WorkoutRequest {
  WorkoutType type;
  List<MuscleGroup> focusAreas;
  List<EquipmentType> availableEquipment;
  FitnessLevel fitnessLevel;
  List<InjuryArea> injuries;
  int targetMinutes;
  bool isAtGym;

  WorkoutRequest({
    required this.type,
    required this.focusAreas,
    required this.availableEquipment,
    required this.fitnessLevel,
    required this.injuries,
    required this.targetMinutes,
    required this.isAtGym,
  });
}
