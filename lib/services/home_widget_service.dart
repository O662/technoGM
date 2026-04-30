import 'package:home_widget/home_widget.dart';
import 'water_service.dart';

// Background callback — must be a top-level function.
// Called by the Hydration widget's +mL buttons without opening the app.
@pragma('vm:entry-point')
Future<void> homeWidgetBackgroundCallback(Uri? uri) async {
  if (uri == null) return;
  if (uri.host == 'addwater') {
    final amount = double.tryParse(uri.queryParameters['amount'] ?? '250') ?? 250.0;
    final newTotal = await WaterService.addWater(amount);
    await HomeWidget.saveWidgetData<int>('water_ml', newTotal.round());
    await Future.wait([
      HomeWidget.updateWidget(androidName: 'ProgressWidgetProvider'),
      HomeWidget.updateWidget(androidName: 'WaterWidgetProvider'),
    ]);
  }
}

class HomeWidgetService {
  static const String _appGroupId = 'group.com.technogm.technogm';

  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
    await HomeWidget.registerInteractivityCallback(homeWidgetBackgroundCallback);
  }

  static Future<void> updateAll({
    int? steps,
    double? calories,
    int? activeMinutes,
    double? waterMl,
    int? streak,
    String? lastWorkoutName,
  }) async {
    await Future.wait([
      HomeWidget.saveWidgetData<int>('steps', steps ?? 0),
      HomeWidget.saveWidgetData<int>('calories', (calories ?? 0).round()),
      HomeWidget.saveWidgetData<int>('active_minutes', activeMinutes ?? 0),
      HomeWidget.saveWidgetData<int>('water_ml', (waterMl ?? 0).round()),
      HomeWidget.saveWidgetData<int>('streak', streak ?? 0),
      HomeWidget.saveWidgetData<String>('last_workout', lastWorkoutName ?? ''),
    ]);
    await _triggerAll();
  }

  static Future<void> updateWaterOnly(double waterMl) async {
    await HomeWidget.saveWidgetData<int>('water_ml', waterMl.round());
    await Future.wait([
      HomeWidget.updateWidget(androidName: 'ProgressWidgetProvider'),
      HomeWidget.updateWidget(androidName: 'WaterWidgetProvider'),
    ]);
  }

  static Future<void> updateStreak(int streak) async {
    await HomeWidget.saveWidgetData<int>('streak', streak);
    await HomeWidget.updateWidget(androidName: 'ProgressWidgetProvider');
  }

  static Future<void> updateLastWorkout(String name) async {
    await HomeWidget.saveWidgetData<String>('last_workout', name);
    await HomeWidget.updateWidget(androidName: 'ExerciseWidgetProvider');
  }

  static Future<void> _triggerAll() async {
    await Future.wait([
      HomeWidget.updateWidget(androidName: 'ProgressWidgetProvider'),
      HomeWidget.updateWidget(androidName: 'WaterWidgetProvider'),
      HomeWidget.updateWidget(androidName: 'ExerciseWidgetProvider'),
    ]);
  }
}
