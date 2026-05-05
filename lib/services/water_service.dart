import 'package:shared_preferences/shared_preferences.dart';

class WaterEntry {
  final DateTime time;
  final double ml;
  const WaterEntry({required this.time, required this.ml});
}

class WaterService {
  static const double dailyGoalMl = 2000.0;

  static String _todayKey() {
    final n = DateTime.now();
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    return 'water_ml_${n.year}_${m}_$d';
  }

  static String _entriesKey() {
    final n = DateTime.now();
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    return 'water_entries_${n.year}_${m}_$d';
  }

  static Future<double> getTodayWater() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_todayKey()) ?? 0.0;
  }

  static Future<double> getWaterForDay(DateTime day) async {
    final prefs = await SharedPreferences.getInstance();
    final m = day.month.toString().padLeft(2, '0');
    final d = day.day.toString().padLeft(2, '0');
    return prefs.getDouble('water_ml_${day.year}_${m}_$d') ?? 0.0;
  }

  static Future<List<WaterEntry>> getTodayEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_entriesKey()) ?? [];
    return raw.map((s) {
      final parts = s.split('|');
      return WaterEntry(
        time: DateTime.parse(parts[0]),
        ml: double.parse(parts[1]),
      );
    }).toList();
  }

  static Future<double> addWater(double ml) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _todayKey();
    final current = prefs.getDouble(key) ?? 0.0;
    final newTotal = (current + ml).clamp(0.0, 9999.0);
    await prefs.setDouble(key, newTotal);

    final entriesKey = _entriesKey();
    final entries = prefs.getStringList(entriesKey) ?? [];
    entries.add('${DateTime.now().toIso8601String()}|$ml');
    await prefs.setStringList(entriesKey, entries);

    return newTotal;
  }

  /// Removes the entry at [index] (chronological order) and recomputes the total.
  static Future<double> removeEntry(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final entriesKey = _entriesKey();
    final raw = prefs.getStringList(entriesKey) ?? [];
    if (index < 0 || index >= raw.length) {
      return prefs.getDouble(_todayKey()) ?? 0.0;
    }
    raw.removeAt(index);
    await prefs.setStringList(entriesKey, raw);

    // Recompute total from remaining entries so it stays accurate.
    final newTotal = raw.fold<double>(0.0, (sum, s) {
      final parts = s.split('|');
      return sum + double.parse(parts[1]);
    }).clamp(0.0, 9999.0);
    await prefs.setDouble(_todayKey(), newTotal);
    return newTotal;
  }

  static Future<void> setWater(double ml) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_todayKey(), ml.clamp(0.0, 9999.0));
  }
}
