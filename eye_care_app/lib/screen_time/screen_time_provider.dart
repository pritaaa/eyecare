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
}
