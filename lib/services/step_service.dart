import 'package:health/health.dart';

/// Reads today's step count via Android Health Connect (v12 API).
///
/// Health Connect is the single source of truth on Android — it automatically
/// deduplicates overlapping records from multiple apps (phone pedometer,
/// smartwatch, etc.) so the returned count never double-counts the same steps.
class StepService {
  static final _health = Health();
  static bool _configured = false;

  static Future<void> _configure() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  /// Returns true if Health Connect is installed and available on this device.
  static Future<bool> isAvailable() async {
    await _configure();
    return _health.isHealthConnectAvailable();
  }

  /// Opens the Play Store page for Health Connect so the user can install it.
  static Future<void> installHealthConnect() async {
    await _configure();
    await _health.installHealthConnect();
  }

  /// Requests READ_STEPS authorization from Health Connect.
  /// Returns true if the user grants permission.
  static Future<bool> requestPermission() async {
    await _configure();
    return _health.requestAuthorization(
      [HealthDataType.STEPS],
      permissions: [HealthDataAccess.READ],
    );
  }

  /// Returns today's total deduplicated step count, or null if the permission
  /// was denied or Health Connect is not available on this device.
  static Future<int?> todaySteps() async {
    try {
      await _configure();
      if (!await _health.isHealthConnectAvailable()) return null;

      final granted = await _health.requestAuthorization(
        [HealthDataType.STEPS],
        permissions: [HealthDataAccess.READ],
      );
      if (!granted) return null;

      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);
      return await _health.getTotalStepsInInterval(midnight, now);
    } catch (_) {
      return null;
    }
  }
}
