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

      _todayReport = await ScreenTimeService.fetchTodayReport();
      _weeklyReport = await ScreenTimeService.fetchWeeklyReport();
    } catch (e) {
      debugPrint("Error loading screen time: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // METHOD BARU: Load Weekly Report
  Future<void> loadWeeklyReport() async {
    try {
      _loading = true;
      notifyListeners();

      _weeklyReport = await ScreenTimeService.fetchWeeklyReport();
      
      // DEBUG: Print untuk cek data weekly
      debugPrint("📊 Weekly Report loaded: ${_weeklyReport.length} days");
      for (var day in _weeklyReport) {
        debugPrint("   ${day['label']}: ${day['usageMs']} ms");
      }
    } catch (e) {
      debugPrint("Error loading weekly report: $e");
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}