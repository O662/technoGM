import 'package:flutter/foundation.dart';
import '../services/step_service.dart';

enum StepStatus { idle, loading, granted, denied, unavailable }

/// Holds today's step count fetched from Health Connect.
///
/// Call [refresh] once (e.g. in a widget's initState) to trigger the
/// permission prompt and load data. The widget tree rebuilds via
/// [ChangeNotifier] whenever the state changes.
class StepProvider extends ChangeNotifier {
  int? _steps;
  StepStatus _status = StepStatus.idle;

  int? get steps => _steps;
  StepStatus get status => _status;
  bool get isLoading => _status == StepStatus.loading;

  Future<void> refresh() async {
    if (_status == StepStatus.loading) return;
    _status = StepStatus.loading;
    notifyListeners();

    final available = await StepService.isAvailable();
    if (!available) {
      _status = StepStatus.unavailable;
      notifyListeners();
      return;
    }

    final result = await StepService.todaySteps();
    if (result == null) {
      _status = StepStatus.denied;
    } else {
      _steps = result;
      _status = StepStatus.granted;
    }
    notifyListeners();
  }

  Future<void> openInstallPage() => StepService.installHealthConnect();
}
