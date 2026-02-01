import 'dart:async';
import 'package:eye_care_app/app_usage/app_usage_model.dart';
import 'package:eye_care_app/app_usage/app_usage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppUsageProvider extends ChangeNotifier {
  final AppUsageService _service = AppUsageService();
  static const _channel = MethodChannel('eye_care/usage_stats');
  Timer? _refreshTimer;

  List<String> _selectedApps = [];
  List<String> get selectedApps => _selectedApps;

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

  Future<void> loadSelectedApps() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedApps = prefs.getStringList('selected_apps') ?? [];
    notifyListeners();
  }

  Future<void> saveSelectedApps(List<String> apps) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selected_apps', apps);
    _selectedApps = apps;
    notifyListeners();
    loadUsageStats(); // Reload data dengan filter baru
  }

  Future<List<Map<String, dynamic>>> getInstalledApps() async {
    final result = await _channel.invokeMethod('getInstalledApps');
    if (result is List) {
      return result.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }

  Future<void> loadUsageStats() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final List<dynamic> raw = await _channel.invokeMethod('getUsageStats', {
        'targetPackages': _selectedApps.isNotEmpty ? _selectedApps : null,
      });
      apps = raw.map((e) => AppUsageModel.fromMap(e)).toList();
    } catch (e) {
      error = 'Gagal mengambil data penggunaan aplikasi';
    }

    isLoading = false;
    _scheduleNextRefresh();
    notifyListeners();
  }

  void _scheduleNextRefresh() {
    _refreshTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final duration = nextMidnight.difference(now);
    _refreshTimer = Timer(duration + const Duration(seconds: 2), () {
      loadUsageStats();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}
