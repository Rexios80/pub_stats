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
}
