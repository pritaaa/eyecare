import 'package:eye_care_app/screen_time/screen_time_model.dart';
import 'package:eye_care_app/screen_time/screen_time_service.dart';
import 'package:flutter/material.dart';

class ScreenTimeProvider extends ChangeNotifier {
  ScreenTimeModel? _todayReport;
  List<Map<String, dynamic>> _weeklyReport = [];
  bool _loading = false;

  ScreenTimeModel? get report => _todayReport;
  List<Map<String, dynamic>> get weeklyReport => _weeklyReport;
  bool get isLoading => _loading;

  Future<void> loadTodayReport() async {
    try {
      _loading = true;
      notifyListeners();

      // ✅ Ambil data dari method baru
      final result = await ScreenTimeService.fetchTodayScreenTime();

      _todayReport = ScreenTimeModel(totalMs: result['totalMs'] ?? 0);

      // DEBUG
      debugPrint("📱 Today Screen Time: ${_todayReport?.totalMs} ms");
      debugPrint("📱 Formatted: ${_todayReport?.formatted}");
    } catch (e) {
      debugPrint("❌ Error loading screen time: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadWeeklyReport() async {
    try {
      _loading = true;
      notifyListeners();

      _weeklyReport = await ScreenTimeService.fetchWeeklyReport();

      // DEBUG
      debugPrint("📊 Weekly Report loaded: ${_weeklyReport.length} days");
      for (var day in _weeklyReport) {
        final ms = day['usageMs'] as int;
        final hours = (ms / (1000 * 60 * 60)).toStringAsFixed(1);
        debugPrint("   ${day['label']}: $hours hours");
      }
    } catch (e) {
      debugPrint("❌ Error loading weekly report: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ✅ Load both today and weekly dalam satu method
  Future<void> loadAllReports() async {
    try {
      _loading = true;
      notifyListeners();

      // Load both secara paralel untuk efisiensi
      final results = await Future.wait([
        ScreenTimeService.fetchTodayScreenTime(),
        ScreenTimeService.fetchWeeklyReport(),
      ]);

      _todayReport = ScreenTimeModel(
        totalMs: (results[0] as Map<String, dynamic>)['totalMs'] ?? 0,
      );

      _weeklyReport = results[1] as List<Map<String, dynamic>>;

      debugPrint("✅ All reports loaded successfully");
    } catch (e) {
      debugPrint("❌ Error loading reports: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
