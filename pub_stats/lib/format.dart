String titleCase(String input) {
  final spaced = input.replaceAllMapped(
    RegExp(r'([a-z0-9])([A-Z])'),
    (match) => '${match[1]} ${match[2]}',
  );
  return spaced
      .split(RegExp(r'[_\s]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String formatNumber(num value) {
  final negative = value < 0;
  final digits = value.abs().round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return negative ? '-$buffer' : buffer.toString();
}

String formatLargeNum(num? number) {
  if (number == null) return 'null';

  var temp = number.abs().toDouble();
  if (temp < 1000) return number.toInt().toString();

  const suffixes = ['K', 'M', 'B', 'T'];
  var suffixIndex = -1;
  while (temp >= 1000 && suffixIndex < suffixes.length - 1) {
    temp /= 1000;
    suffixIndex++;
  }

  final integerDigits = temp.floor().toString().length;
  var decimalDigits = 3 - integerDigits;
  if (decimalDigits < 0) decimalDigits = 0;

  var formatted = temp.toStringAsFixed(decimalDigits);
  if (formatted.contains('.')) {
    formatted = formatted.replaceAll(RegExp(r'0*$'), '');
    if (formatted.endsWith('.')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
  }

  final sign = number < 0 ? '-' : '';
  return '$sign$formatted${suffixes[suffixIndex]}';
}

String shortDate(DateTime date) {
  final local = date.toLocal();
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  final year = (local.year % 100).toString().padLeft(2, '0');
  return '$month/$day/$year';
}

String timeAgo(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.isNegative || diff.inSeconds < 45) return 'just now';
  if (diff.inMinutes < 60) return _ago(diff.inMinutes, 'minute');
  if (diff.inHours < 24) return _ago(diff.inHours, 'hour');
  if (diff.inDays < 30) return _ago(diff.inDays, 'day');
  if (diff.inDays < 365) return _ago(diff.inDays ~/ 30, 'month');
  return _ago(diff.inDays ~/ 365, 'year');
}

String _ago(int count, String unit) => '$count $unit${count == 1 ? '' : 's'} ago';
