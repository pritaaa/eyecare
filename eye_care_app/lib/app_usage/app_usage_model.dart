import 'dart:typed_data';

class AppUsageModel {
  final String packageName;
  final String appName;
  final int minutes;
  final Uint8List? appIcon;

  AppUsageModel({
    required this.packageName,
    required this.appName,
    required this.minutes,
    this.appIcon,
  });

  factory AppUsageModel.fromMap(Map<dynamic, dynamic> map) {
    return AppUsageModel(
      packageName: map['package'],
      appName: map['appName'] ?? map['package'],
      minutes: map['minutes'],
      appIcon: map['appIcon'],
    );
  }
}
