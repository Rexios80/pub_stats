import 'package:recase/recase.dart';

enum TimeSpan {
  week(days: 7),
  month(days: 30),
  threeMonths(days: 90),
  year(days: 365),
  all(days: null);

  final int? days;

  const TimeSpan({required this.days});

  bool contains(DateTime date) {
    if (days == null) return true;
    final diff = DateTime.now().difference(date);
    return diff.inDays <= days!;
  }

  @override
  String toString() => name.titleCase;

  DateTime get start {
    final days = this.days;
    if (days == null) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days));
  }
}
