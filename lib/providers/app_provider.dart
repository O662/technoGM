import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/step_service.dart';
import '../services/storage_service.dart';

class AppProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  AppData _data = AppData();
  ActiveWorkout? _activeWorkout;
  bool _isLoading = true;

  AppData get data => _data;
  ActiveWorkout? get activeWorkout => _activeWorkout;
  bool get isLoading => _isLoading;
  bool get hasActiveWorkout => _activeWorkout != null;
  bool get hasCompletedOnboarding => _data.hasCompletedOnboarding;

  // ─── Init ──────────────────────────────────────────────────────────────────

  Future<void> init() async {
    _data = await _storage.load();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _save() async {
    await _storage.save(_data);
  }

  // ─── Profile ───────────────────────────────────────────────────────────────

  Future<void> updateProfile(UserProfile profile) async {
    _data.profile = profile;
    await _save();
    notifyListeners();
  }

  /// Called at the end of onboarding. Saves profile, optional first weight
  /// entry, and marks onboarding complete in one atomic save.
  Future<void> completeOnboarding({
    required UserProfile profile,
    double? initialWeightKg,
  }) async {
    _data.profile = profile;
    if (initialWeightKg != null && initialWeightKg > 0) {
      _data.weightHistory.add(BodyWeightEntry(
        date: DateTime.now(),
        weightKg: initialWeightKg,
      ));
    }
    _data.hasCompletedOnboarding = true;
    await _save();
    notifyListeners();
  }

  // ─── Body Weight ───────────────────────────────────────────────────────────

  Future<void> addWeightEntry(double kg, {String notes = ''}) async {
    _data.weightHistory.add(BodyWeightEntry(
      date: DateTime.now(),
      weightKg: kg,
      notes: notes,
    ));
    _data.weightHistory.sort((a, b) => a.date.compareTo(b.date));
    await _save();
    notifyListeners();
  }

  Future<void> removeWeightEntry(DateTime date) async {
    _data.weightHistory.removeWhere(
      (e) => e.date.year == date.year && e.date.month == date.month && e.date.day == date.day,
    );
    await _save();
    notifyListeners();
  }

  double? get latestWeight =>
      _data.weightHistory.isEmpty ? null : _data.weightHistory.last.weightKg;

  // ─── Active Workout ────────────────────────────────────────────────────────

  void startWorkout({
    required String name,
    required WorkoutType type,
    required bool isAtGym,
    required List<WorkoutExerciseLog> exercises,
  }) {
    _activeWorkout = ActiveWorkout(
      name: name,
      type: type,
      isAtGym: isAtGym,
      exercises: exercises,
    );
    notifyListeners();
  }

  void updateActiveExercise(int index, WorkoutExerciseLog updated) {
    if (_activeWorkout == null) return;
    _activeWorkout!.exercises[index] = updated;
    notifyListeners();
  }

  void addExerciseToActive(WorkoutExerciseLog exercise) {
    _activeWorkout?.exercises.add(exercise);
    notifyListeners();
  }

  void removeExerciseFromActive(int index) {
    _activeWorkout?.exercises.removeAt(index);
    notifyListeners();
  }

  Future<CompletedWorkout> finishWorkout({String notes = ''}) async {
    final active = _activeWorkout!;
    final now = DateTime.now();

    // Estimate calories (rough: ~5 cal/min for strength, ~8 for cardio/HIIT)
    final mins = active.elapsedMinutes;
    final calRate = (active.type == WorkoutType.cardio || active.type == WorkoutType.hiit) ? 8 : 5;
    final calories = (mins * calRate).round();

    final completed = CompletedWorkout(
      name: active.name,
      startTime: active.startTime,
      endTime: now,
      type: active.type,
      isAtGym: active.isAtGym,
      exercises: active.exercises,
      notes: notes,
      caloriesBurned: calories,
    );

    _data.workouts.insert(0, completed);
    _activeWorkout = null;

    // Update personal records
    _updatePRs(completed);

    // Update streaks
    await _updateStreak();

    await _save();
    notifyListeners();
    return completed;
  }

  void cancelWorkout() {
    _activeWorkout = null;
    notifyListeners();
  }

  // ─── History ───────────────────────────────────────────────────────────────

  Future<void> deleteWorkout(String id) async {
    _data.workouts.removeWhere((w) => w.id == id);
    await _save();
    notifyListeners();
  }

  // ─── Streak logic ──────────────────────────────────────────────────────────

  Future<void> _updateStreak() async {
    final streak = _data.streak;
    final now = DateTime.now();

    int streak0 = 0;
    DateTime checkWeek = _weekStart(now);
    while (true) {
      final ws = _workoutsInWeek(checkWeek);
      final stepDays = await StepService.weekStepGoalDays(checkWeek, 10000);
      if (_weekQualifies(ws, streak, stepDays)) {
        streak0++;
        checkWeek = checkWeek.subtract(const Duration(days: 7));
      } else {
        break;
      }
    }

    streak.currentWeekStreak = streak0;
    if (streak0 > streak.bestWeekStreak) {
      streak.bestWeekStreak = streak0;
    }
  }

  DateTime _weekStart(DateTime d) {
    final daysFromMonday = (d.weekday - 1) % 7;
    return DateTime(d.year, d.month, d.day - daysFromMonday);
  }

  List<CompletedWorkout> _workoutsInWeek(DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return _data.workouts.where((w) {
      return w.startTime.isAfter(weekStart.subtract(const Duration(seconds: 1))) &&
          w.startTime.isBefore(weekEnd);
    }).toList();
  }

  bool _weekQualifies(List<CompletedWorkout> workouts, StreakData streak, int stepDays) {
    if (stepDays < streak.weeklyStepDaysGoal) return false;
    if (workouts.length >= streak.weeklySessionGoal) return true;
    final totalMins = workouts.fold(0, (sum, w) => sum + w.durationMinutes);
    return totalMins >= streak.weeklyMinutesGoal;
  }

  // Current week stats
  int get thisWeekSessions {
    return _workoutsInWeek(_weekStart(DateTime.now())).length;
  }

  int get thisWeekMinutes {
    return _workoutsInWeek(_weekStart(DateTime.now()))
        .fold(0, (sum, w) => sum + w.durationMinutes);
  }

  Future<bool> get thisWeekComplete async {
    final w = _workoutsInWeek(_weekStart(DateTime.now()));
    final stepDays = await StepService.weekStepGoalDays(_weekStart(DateTime.now()), 10000);
    return _weekQualifies(w, _data.streak, stepDays);
  }

  // ─── Personal Records ──────────────────────────────────────────────────────

  void _updatePRs(CompletedWorkout workout) {
    for (final ex in workout.exercises) {
      if (ex.isTimeBased) continue;
      for (final set in ex.sets) {
        if (!set.completed || set.weight <= 0 || set.repsOrSeconds <= 0) continue;
        final existing = _data.personalRecords.where((pr) => pr.exerciseId == ex.exerciseId);
        final newPR = PersonalRecord(
          exerciseId: ex.exerciseId,
          exerciseName: ex.exerciseName,
          weightKg: set.weight,
          reps: set.repsOrSeconds,
          date: workout.endTime,
        );
        if (existing.isEmpty) {
          _data.personalRecords.add(newPR);
        } else {
          final best = existing.reduce((a, b) => a.oneRepMax >= b.oneRepMax ? a : b);
          if (newPR.oneRepMax > best.oneRepMax) {
            _data.personalRecords.removeWhere((pr) => pr.exerciseId == ex.exerciseId);
            _data.personalRecords.add(newPR);
          }
        }
      }
    }
  }

  // ─── Stats helpers ─────────────────────────────────────────────────────────

  /// Workouts per week for the last [weeks] weeks
  List<int> workoutsPerWeek(int weeks) {
    final result = <int>[];
    for (int i = weeks - 1; i >= 0; i--) {
      final ws = _weekStart(DateTime.now()).subtract(Duration(days: i * 7));
      result.add(_workoutsInWeek(ws).length);
    }
    return result;
  }

  /// Total volume per muscle group (for pie chart)
  Map<MuscleGroup, double> volumeByMuscle() {
    final map = <MuscleGroup, double>{};
    for (final w in _data.workouts) {
      for (final ex in w.exercises) {
        final v = ex.totalVolume;
        map[ex.primaryMuscle] = (map[ex.primaryMuscle] ?? 0) + v;
      }
    }
    return map;
  }

  /// Workout type distribution
  Map<WorkoutType, int> workoutTypeCount() {
    final map = <WorkoutType, int>{};
    for (final w in _data.workouts) {
      map[w.type] = (map[w.type] ?? 0) + 1;
    }
    return map;
  }

  // ─── Export / Import ───────────────────────────────────────────────────────

  Future<bool> exportData() async {
    return _storage.export(_data);
  }

  Future<bool> importData() async {
    final imported = await _storage.import();
    if (imported == null) return false;
    _data = imported;
    await _save();
    notifyListeners();
    return true;
  }

  Future<void> clearAllData() async {
    await _storage.clearAll();
    _data = AppData();
    _activeWorkout = null;
    notifyListeners();
  }

  Future<void> updateStreakSettings({int? sessions, int? minutes}) async {
    if (sessions != null) _data.streak.weeklySessionGoal = sessions;
    if (minutes != null) _data.streak.weeklyMinutesGoal = minutes;
    await _save();
    notifyListeners();
  }
}
