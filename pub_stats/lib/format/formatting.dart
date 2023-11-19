import 'package:get_time_ago/get_time_ago.dart';
import 'package:intl/intl.dart';

class Formatting {
  Formatting._();

  static final _numberFormat = NumberFormat();
  static final _dateFormat = DateFormat('MM/dd/yy');

  static String number(num number) => _numberFormat.format(number);
  static String timeAgo(DateTime date) => GetTimeAgo.parse(date);
  static String shortDate(DateTime data) => _dateFormat.format(data);
}
