import 'package:health/health.dart';

class StepService {
  static final _health = Health();
  static bool _configured = false;

  static Future<void> _configure() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  static Future<bool> isAvailable() async {
    await _configure();
    return _health.isHealthConnectAvailable();
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
        HealthDataType.WORKOUT,
      ],
      permissions: [
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
      if (!await _health.isHealthConnectAvailable()) return null;
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
      if (!await _health.isHealthConnectAvailable()) return null;
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
    int count = 0;
    final todayStart = _todayStart();
    for (int i = 0; i < 7; i++) {
      final day = weekStart.add(Duration(days: i));
      if (day.isAfter(todayStart)) break;
      final steps = await stepsForDay(day) ?? 0;
      if (steps >= goal) count++;
    }
    return count;
  }

  static Future<double?> todayActiveCaloriesKcal() async {
    try {
      await _configure();
      if (!await _health.isHealthConnectAvailable()) return null;
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

  static Future<int?> todayActiveMinutes() async {
    try {
      await _configure();
      if (!await _health.isHealthConnectAvailable()) return null;
      final start = _todayStart();
      final records = await _health.getHealthDataFromTypes(
        types: [HealthDataType.WORKOUT],
        startTime: start,
        endTime: start.add(const Duration(days: 1)),
      );
      int total = 0;
      for (final r in records) {
        total += r.dateTo.difference(r.dateFrom).inMinutes;
      }
      return total;
    } catch (_) {
      return null;
    }
  }

  /// Water is tracked in-app only (no Health Connect permission on Android).
  /// Returns null until app-internal hydration logging is wired up.
  static Future<double?> todayWaterMl() async => null;

  static DateTime _todayStart() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }
}
