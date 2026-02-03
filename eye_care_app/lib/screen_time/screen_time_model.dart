class ScreenTimeModel {
  final int totalMs;

  ScreenTimeModel({required this.totalMs});

  // Duration untuk display
  Duration get duration => Duration(milliseconds: totalMs);

  // Format jam dan menit
  int get hours => duration.inHours;
  int get minutes => duration.inMinutes % 60;

  // Format string untuk display
  String get formatted => '${hours}h ${minutes}m';
}
