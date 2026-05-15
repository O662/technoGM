import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/step_service.dart';
import '../services/home_widget_service.dart';
import '../services/water_service.dart';
export '../services/water_service.dart' show WaterEntry;

enum RingsStatus { idle, loading, granted, denied, unavailable }

class ActivityRingsProvider extends ChangeNotifier {
  int? _steps;
  double? _caloriesKcal;
  int? _activeMinutes;
  List<ActivityEntry> _activityEntries = [];
  List<StepEntry> _stepEntries = [];
  List<CalorieEntry> _calorieEntries = [];
  double? _waterMl;
  List<WaterEntry> _waterEntries = [];
  int? _weeklyStepGoalDays;
  RingsStatus _status = RingsStatus.idle;
  DateTime? _lastSynced;
  Timer? _timer;
  int _stepsGoal;
  double _caloriesGoal;
  int _activeMinutesGoal;
  double _waterGoalMl;
  int _weeklyStepDaysGoal;

  ActivityRingsProvider({
    int initialStepsGoal = 10000,
    double initialCaloriesGoal = 2000.0,
    int initialActiveMinutesGoal = 30,
    double initialWaterGoalMl = 2000.0,
    int initialWeeklyStepDaysGoal = 5,
  })  : _stepsGoal = initialStepsGoal,
        _caloriesGoal = initialCaloriesGoal,
        _activeMinutesGoal = initialActiveMinutesGoal,
        _waterGoalMl = initialWaterGoalMl,
        _weeklyStepDaysGoal = initialWeeklyStepDaysGoal;

  int get stepsGoal => _stepsGoal;
  double get caloriesGoal => _caloriesGoal;
  int get activeMinutesGoal => _activeMinutesGoal;
  double get waterGoalMl => _waterGoalMl;
  int get weeklyStepDaysGoal => _weeklyStepDaysGoal;

  int? get steps => _steps;
  double? get caloriesKcal => _caloriesKcal;
  int? get activeMinutes => _activeMinutes;
  List<ActivityEntry> get activityEntries => _activityEntries;
  List<StepEntry> get stepEntries => _stepEntries;
  List<CalorieEntry> get calorieEntries => _calorieEntries;
  double? get waterMl => _waterMl;
  List<WaterEntry> get waterEntries => _waterEntries;
  int? get weeklyStepGoalDays => _weeklyStepGoalDays;
  RingsStatus get status => _status;
  DateTime? get lastSynced => _lastSynced;
  bool get isLoading => _status == RingsStatus.loading;

  double get stepsProgress => (_steps ?? 0) / _stepsGoal;
  double get caloriesProgress => (_caloriesKcal ?? 0) / _caloriesGoal;
  double get activeMinutesProgress => (_activeMinutes ?? 0) / _activeMinutesGoal;
  double get waterProgress => (_waterMl ?? 0) / _waterGoalMl;

  void setStepsGoal(int goal) {
    _stepsGoal = goal;
    notifyListeners();
    _silentRefresh();
  }

  void setCaloriesGoal(int goal) {
    _caloriesGoal = goal.toDouble();
    notifyListeners();
  }

  void setActiveMinutesGoal(int goal) {
    _activeMinutesGoal = goal;
    notifyListeners();
  }

  void setWaterGoal(int goalMl) {
    _waterGoalMl = goalMl.toDouble();
    notifyListeners();
  }

  void setWeeklyStepDaysGoal(int days) {
    _weeklyStepDaysGoal = days;
    notifyListeners();
  }

  double get weeklyStepGoalDaysProgress => _weeklyStepDaysGoal == 0
      ? 0.0
      : (_weeklyStepGoalDays ?? 0) / _weeklyStepDaysGoal;

  Future<void> refresh() async {
    if (_status == RingsStatus.loading) return;
    _status = RingsStatus.loading;
    notifyListeners();

    final available = await StepService.isAvailable();
    if (!available) {
      _status = RingsStatus.unavailable;
      notifyListeners();
      return;
    }

    final granted = await StepService.requestPermission();
    if (!granted) {
      _status = RingsStatus.denied;
      notifyListeners();
      return;
    }

    await _loadAll();
    _status = RingsStatus.granted;
    notifyListeners();
  }

  void startAutoRefresh() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _silentRefresh());
  }

  void stopAutoRefresh() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _loadAll() async {
    final weekStart = _weekStart(DateTime.now());
    final results = await Future.wait([
      StepService.todaySteps(),
      StepService.todayTotalCaloriesKcal(),
      StepService.todayActivityData(),
      StepService.todayWaterMl(),
      StepService.weekStepGoalDays(weekStart, stepsGoal),
      StepService.todayStepEntries(),
      StepService.todayCalorieEntries(),
      WaterService.getTodayEntries(),
    ]);
    _steps = results[0] as int?;
    _caloriesKcal = results[1] as double?;
    final activityResult = results[2] as ActivityResult?;
    _activeMinutes = activityResult?.minutes;
    _activityEntries = activityResult?.entries ?? [];
    _waterMl = results[3] as double?;
    _weeklyStepGoalDays = results[4] as int;
    _stepEntries = results[5] as List<StepEntry>;
    _calorieEntries = results[6] as List<CalorieEntry>;
    _waterEntries = results[7] as List<WaterEntry>;
    _lastSynced = DateTime.now();

    unawaited(HomeWidgetService.updateAll(
      steps: _steps,
      calories: _caloriesKcal,
      activeMinutes: _activeMinutes,
      waterMl: _waterMl,
    ));
  }

  Future<void> addWater(double ml) async {
    final newTotal = await WaterService.addWater(ml);
    _waterMl = newTotal;
    _waterEntries = await WaterService.getTodayEntries();
    notifyListeners();
    unawaited(HomeWidgetService.updateWaterOnly(newTotal));
  }

  /// [index] is the position in the chronological (stored) list.
  Future<void> removeWaterEntry(int index) async {
    final newTotal = await WaterService.removeEntry(index);
    _waterMl = newTotal;
    _waterEntries = await WaterService.getTodayEntries();
    notifyListeners();
    unawaited(HomeWidgetService.updateWaterOnly(newTotal));
  }

  static DateTime _weekStart(DateTime d) {
    final daysFromMonday = (d.weekday - 1) % 7;
    return DateTime(d.year, d.month, d.day - daysFromMonday);
  }

  Future<void> _silentRefresh() async {
    if (_status != RingsStatus.granted) return;
    await _loadAll();
    notifyListeners();
  }

  Future<void> openInstallPage() => StepService.installHealthConnect();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
