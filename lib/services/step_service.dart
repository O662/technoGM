import 'package:health/health.dart';
import 'water_service.dart';

/// A single calorie record from Health Connect.
class CalorieEntry {
  final DateTime start;
  final DateTime end;
  final double kcal;

  const CalorieEntry({
    required this.start,
    required this.end,
    required this.kcal,
  });
}

/// A raw step record from Health Connect with its step count.
class StepEntry {
  final DateTime start;
  final DateTime end;
  final int steps;

  const StepEntry({
    required this.start,
    required this.end,
    required this.steps,
  });

  int get durationMinutes {
    final fromMin = start.millisecondsSinceEpoch ~/ 60000;
    final toMin = end.millisecondsSinceEpoch ~/ 60000;
    return (toMin - fromMin).clamp(0, 1440);
  }
}

/// A single qualifying activity interval from Health Connect.
class ActivityEntry {
  final DateTime start;
  final DateTime end;
  final bool isWorkout;
  final String? workoutType;

  const ActivityEntry({
    required this.start,
    required this.end,
    required this.isWorkout,
    this.workoutType,
  });

  /// Calendar-minutes covered by this interval (clamped to [0, 1440]).
  int get durationMinutes {
    final fromMin = start.millisecondsSinceEpoch ~/ 60000;
    final toMin = end.millisecondsSinceEpoch ~/ 60000;
    return (toMin - fromMin).clamp(0, 1440);
  }

  String get label {
    if (isWorkout && workoutType != null) return workoutType!;
    if (isWorkout) return 'Workout';
    return 'Steps';
  }
}

/// Holds the de-duplicated active-minute count and the raw interval list.
class ActivityResult {
  final int minutes;
  final List<ActivityEntry> entries;
  const ActivityResult({required this.minutes, required this.entries});
}

class StepService {
  static final _health = Health();
  static bool _configured = false;
  static bool _available = false;

  static Future<void> _configure() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  static Future<bool> isAvailable() async {
    await _configure();
    _available = await _health.isHealthConnectAvailable();
    return _available;
  }

  static Future<void> installHealthConnect() async {
    await _configure();
    await _health.installHealthConnect();
  }

  /// Requests all ring permissions. Shows a single Health Connect dialog for
  /// all four types. Returns true as long as STEPS was granted — the other
  /// rings degrade gracefully to 0 if their permissions are denied.
  static Future<bool> requestPermission() async {
    await _configure();
    await _health.requestAuthorization(
      [
        HealthDataType.STEPS,
        HealthDataType.ACTIVE_ENERGY_BURNED,
        HealthDataType.TOTAL_CALORIES_BURNED,
        HealthDataType.WORKOUT,
      ],
      permissions: [
        HealthDataAccess.READ,
        HealthDataAccess.READ,
        HealthDataAccess.READ,
        HealthDataAccess.READ,
      ],
    );
    // Gate on steps — the most critical metric.
    return await _health.hasPermissions(
          [HealthDataType.STEPS],
          permissions: [HealthDataAccess.READ],
        ) ??
        false;
  }

  static Future<int?> todaySteps() async {
    try {
      await _configure();
      if (!_available) return null;
      final start = _todayStart();
      // Query to end-of-day so Samsung Health's full-day record is fully
      // inside the window and is not prorated by Health Connect's aggregate.
      return await _health.getTotalStepsInInterval(
          start, start.add(const Duration(days: 1)));
    } catch (_) {
      return null;
    }
  }

  static Future<int?> stepsForDay(DateTime day) async {
    try {
      await _configure();
      if (!_available) return null;
      final start = DateTime(day.year, day.month, day.day);
      return await _health.getTotalStepsInInterval(
          start, start.add(const Duration(days: 1)));
    } catch (_) {
      return null;
    }
  }

  /// How many days in the week starting on [weekStart] (Monday) reached [goal]
  /// steps. Only counts days up to and including today.
  static Future<int> weekStepGoalDays(DateTime weekStart, int goal) async {
    final today = _todayStart();
    final days = <DateTime>[];
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      if (day.isAfter(today)) break;
      days.add(day);
    }
    final results = await Future.wait(days.map((d) => stepsForDay(d)));
    return results.where((s) => (s ?? 0) >= goal).length;
  }

  static Future<double?> todayActiveCaloriesKcal() async {
    try {
      await _configure();
      if (!_available) return null;
      final start = _todayStart();
      final records = await _health.getHealthDataFromTypes(
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
        startTime: start,
        endTime: start.add(const Duration(days: 1)),
      );
      return records.fold<double>(
        0.0,
        (s, p) => s + (p.value as NumericHealthValue).numericValue.toDouble(),
      );
    } catch (_) {
      return null;
    }
  }

  static Future<double?> todayTotalCaloriesKcal() async =>
      _caloriesKcalFor(_todayStart());

  static Future<double?> caloriesForDay(DateTime day) async =>
      _caloriesKcalFor(DateTime(day.year, day.month, day.day));

  static Future<double?> _caloriesKcalFor(DateTime dayStart) async {
    try {
      await _configure();
      if (!_available) return null;
      final end = dayStart.add(const Duration(days: 1));
      // Try TOTAL_CALORIES_BURNED first; fall back to ACTIVE_ENERGY_BURNED
      // because some sources (e.g. Samsung Health) only write the latter.
      for (final type in [
        HealthDataType.TOTAL_CALORIES_BURNED,
        HealthDataType.ACTIVE_ENERGY_BURNED,
      ]) {
        final records = await _health.getHealthDataFromTypes(
          types: [type],
          startTime: dayStart,
          endTime: end,
        );
        if (records.isEmpty) continue;
        return records.fold<double>(
          0.0,
          (s, p) => s + (p.value as NumericHealthValue).numericValue.toDouble(),
        );
      }
      return 0.0;
    } catch (_) {
      return null;
    }
  }

  static Future<List<CalorieEntry>> todayCalorieEntries() async {
    try {
      await _configure();
      if (!_available) return [];
      final start = _todayStart();
      final end = start.add(const Duration(days: 1));
      for (final type in [
        HealthDataType.TOTAL_CALORIES_BURNED,
        HealthDataType.ACTIVE_ENERGY_BURNED,
      ]) {
        final records = await _health.getHealthDataFromTypes(
          types: [type],
          startTime: start,
          endTime: end,
        );
        if (records.isEmpty) continue;
        final entries = <CalorieEntry>[];
        for (final r in records) {
          final kcal = (r.value as NumericHealthValue).numericValue.toDouble();
          if (kcal <= 0) continue;
          entries.add(CalorieEntry(start: r.dateFrom, end: r.dateTo, kcal: kcal));
        }
        entries.sort((a, b) => a.start.compareTo(b.start));
        return entries;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // Minimum steps-per-minute to treat a STEPS record as genuine movement.
  // Aggregated daily/hourly records (e.g. Samsung Health syncing 8 000 steps
  // over 23 h ≈ 5.8 spm) fall well below this; real walking is ≥ ~60 spm.
  static const int _minStepsPerMin = 30;

  /// Fetches today's STEPS and WORKOUT records and returns the de-duplicated
  /// active-minute count plus the raw list of qualifying intervals (sorted by
  /// start time). Overlapping intervals are counted only once.
  static Future<ActivityResult?> todayActivityData() async =>
      _activityDataFor(_todayStart());

  static Future<int?> todayActiveMinutes() async =>
      (await todayActivityData())?.minutes;

  static Future<int?> activeMinutesForDay(DateTime day) async =>
      (await _activityDataFor(DateTime(day.year, day.month, day.day)))?.minutes;

  static Future<ActivityResult?> _activityDataFor(DateTime dayStart) async {
    try {
      await _configure();
      if (!_available) return null;
      final end = dayStart.add(const Duration(days: 1));
      final records = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WORKOUT, HealthDataType.STEPS],
        startTime: dayStart,
        endTime: end,
      );

      final entries = <ActivityEntry>[];
      for (final r in records) {
        final fromMin = r.dateFrom.millisecondsSinceEpoch ~/ 60000;
        final toMin = r.dateTo.millisecondsSinceEpoch ~/ 60000;
        final durationMins = toMin - fromMin;

        if (r.type == HealthDataType.STEPS) {
          if (durationMins <= 0) continue;
          // Reject aggregated/cumulative step records. Apps like Samsung Health
          // can write a single record spanning many hours with the day's total
          // steps; using its full time window would wildly inflate active time.
          final steps =
              (r.value as NumericHealthValue).numericValue.toDouble();
          if (steps / durationMins < _minStepsPerMin) continue;
          entries.add(ActivityEntry(
            start: r.dateFrom,
            end: r.dateTo,
            isWorkout: false,
          ));
        } else if (r.type == HealthDataType.WORKOUT) {
          if (durationMins <= 0) continue;
          String? wType;
          final v = r.value;
          if (v is WorkoutHealthValue) {
            wType = _formatWorkoutType(v.workoutActivityType);
          }
          entries.add(ActivityEntry(
            start: r.dateFrom,
            end: r.dateTo,
            isWorkout: true,
            workoutType: wType,
          ));
        }
      }

      // Collect every calendar-minute touched by any qualifying interval.
      // The Set de-duplicates overlapping workout and step intervals so a
      // minute shared by both is counted exactly once.
      final activeSlots = <int>{};
      for (final e in entries) {
        final fromMin = e.start.millisecondsSinceEpoch ~/ 60000;
        final toMin = e.end.millisecondsSinceEpoch ~/ 60000;
        for (int m = fromMin; m < toMin; m++) {
          activeSlots.add(m);
        }
      }

      entries.sort((a, b) => a.start.compareTo(b.start));
      return ActivityResult(minutes: activeSlots.length, entries: entries);
    } catch (_) {
      return null;
    }
  }

  /// Returns every individual STEPS record for today, sorted by start time.
  static Future<List<StepEntry>> todayStepEntries() async {
    try {
      await _configure();
      if (!_available) return [];
      final start = _todayStart();
      final records = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: start,
        endTime: start.add(const Duration(days: 1)),
      );
      final entries = <StepEntry>[];
      for (final r in records) {
        final steps =
            (r.value as NumericHealthValue).numericValue.round();
        if (steps <= 0) continue;
        entries.add(StepEntry(start: r.dateFrom, end: r.dateTo, steps: steps));
      }
      entries.sort((a, b) => a.start.compareTo(b.start));
      return entries;
    } catch (_) {
      return [];
    }
  }

  static Future<double?> todayWaterMl() async => WaterService.getTodayWater();

  static DateTime _todayStart() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  static String _formatWorkoutType(HealthWorkoutActivityType type) {
    return type.name
        .split('_')
        .map((w) => w.isEmpty
            ? ''
            : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
        .join(' ');
  }
}
