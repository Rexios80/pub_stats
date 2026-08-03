extension DateTimeExtension on DateTime {
  static DateTime fromSecondsSinceEpoch(int seconds) =>
      DateTime.fromMillisecondsSinceEpoch(seconds * 1000);

  static DateTime fromHoursSinceEpoch(int hours) =>
      DateTime.fromMillisecondsSinceEpoch(hours * 3600 * 1000);

  int get secondsSinceEpoch => (millisecondsSinceEpoch / 1000).round();

  int get hoursSinceEpoch => millisecondsSinceEpoch ~/ 3600000;
}
