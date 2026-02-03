import 'package:flutter/services.dart';

class ScreenTimeService {
  static const _channel = MethodChannel(
    'eye_care/usage_stats',
  ); // ✅ Ganti channel

  // ✅ Method baru - ambil dari getTodayScreenTime (tidak ada screenOnCount lagi)
  static Future<Map<String, dynamic>> fetchTodayScreenTime() async {
    final result = await _channel.invokeMethod('getTodayScreenTime');
    return Map<String, dynamic>.from(result);
  }

  static Future<List<Map<String, dynamic>>> fetchWeeklyReport() async {
    final result = await _channel.invokeMethod('getWeeklyScreenTime');
    if (result is List) {
      return result.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }
}
