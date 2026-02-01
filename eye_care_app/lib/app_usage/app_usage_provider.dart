import 'package:eye_care_app/app_usage/app_usage_model.dart';
import 'package:eye_care_app/app_usage/app_usage_service.dart';
import 'package:flutter/material.dart';

class AppUsageProvider extends ChangeNotifier {
  final AppUsageService _service = AppUsageService();

  bool hasPermission = false;
  bool isLoading = false;
  String? error;

  List<AppUsageModel> apps = [];

  Future<void> checkPermission() async {
    hasPermission = await _service.hasPermission();
    notifyListeners();
  }

  Future<void> requestPermission() async {
    await _service.openSettings();
  }

  Future<void> loadUsageStats() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final raw = await _service.getUsageStatsRaw();
      apps = raw.map((e) => AppUsageModel.fromMap(e)).toList();
    } catch (e) {
      error = 'Gagal mengambil data penggunaan aplikasi';
    }

    isLoading = false;
    notifyListeners();
  }
}
