import 'package:eye_care_app/screen_time/screen_time_model.dart';
import 'package:flutter/services.dart';

class ScreenTimeService {
  static const _channel = MethodChannel('screen_usage');

  static Future<ScreenTimeModel> fetchTodayReport() async {
    final result = await _channel.invokeMethod('getTodayReport');

    return ScreenTimeModel(
      screenOnMs: result['screenOnMs'] ?? 0,
      screenOnCount: result['screenOnCount'] ?? 0,
    );
  }

  static Future<List<Map<String, dynamic>>> fetchWeeklyReport() async {
    final result = await _channel.invokeMethod('getWeeklyScreenTime');
    if (result is List) {
      return result.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    return [];
  }
}
