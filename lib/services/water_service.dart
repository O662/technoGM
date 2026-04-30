import 'package:shared_preferences/shared_preferences.dart';

class WaterService {
  static const double dailyGoalMl = 2000.0;

  static String _todayKey() {
    final n = DateTime.now();
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    return 'water_ml_${n.year}_${m}_$d';
  }

  static Future<double> getTodayWater() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_todayKey()) ?? 0.0;
  }

  static Future<double> addWater(double ml) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _todayKey();
    final current = prefs.getDouble(key) ?? 0.0;
    final newTotal = (current + ml).clamp(0.0, 9999.0);
    await prefs.setDouble(key, newTotal);
    return newTotal;
  }

  static Future<void> setWater(double ml) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_todayKey(), ml.clamp(0.0, 9999.0));
  }
}
