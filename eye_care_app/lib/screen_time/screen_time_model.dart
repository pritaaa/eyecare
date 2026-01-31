class ScreenTimeModel {
  final int screenOnMs;
  final int screenOnCount;

  ScreenTimeModel({required this.screenOnMs, required this.screenOnCount});

  Duration get screenOnDuration => Duration(milliseconds: screenOnMs);

  Duration get screenOffDuration {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final totalDayMs =
        now.millisecondsSinceEpoch - startOfDay.millisecondsSinceEpoch;

    final offMs = totalDayMs - screenOnMs;
    return Duration(milliseconds: offMs < 0 ? 0 : offMs);
  }

  int get screenOffCount => screenOnCount;
}
