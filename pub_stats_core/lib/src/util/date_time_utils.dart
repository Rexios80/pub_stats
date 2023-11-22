extension DateTimeExtension on DateTime {
  static DateTime fromSecondsSinceEpoch(int seconds) =>
      DateTime.fromMillisecondsSinceEpoch(seconds * 1000);

  int get secondsSinceEpoch => (millisecondsSinceEpoch / 1000).round();
}
