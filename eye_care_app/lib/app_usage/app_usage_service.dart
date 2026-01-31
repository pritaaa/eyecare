import 'package:flutter/services.dart';

class AppUsageService {
  static const _channel = MethodChannel('eye_care/usage_stats');

  Future<bool> hasPermission() async {
    return await _channel.invokeMethod('hasUsagePermission');
  }

  Future<void> openSettings() async {
    await _channel.invokeMethod('openUsageSettings');
  }

  Future<List<dynamic>> getUsageStatsRaw() async {
    return await _channel.invokeMethod('getUsageStats');
  }
}
