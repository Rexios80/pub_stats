import 'package:get_time_ago/get_time_ago.dart';
import 'package:intl/intl.dart';

class Formatting {
  Formatting._();

  static final _numberFormat = NumberFormat();

  static String number(num number) => _numberFormat.format(number);
  static String timeAgo(DateTime date) => GetTimeAgo.parse(date);
}
