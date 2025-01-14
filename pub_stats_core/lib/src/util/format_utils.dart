String formatLargeNum(num? number) {
  if (number == null) return 'null';

  var temp = number.abs().toDouble();
  if (temp < 1000) return number.toInt().toString();

  const suffixes = ['K', 'M', 'B', 'T'];
  var suffixIndex = -1;

  // Determine the appropriate suffix
  while (temp >= 1000 && suffixIndex < suffixes.length - 1) {
    temp /= 1000;
    suffixIndex++;
  }

  // Calculate the number of digits before the decimal point
  final integerDigits = temp.floor().toString().length;

  // Determine the number of decimal places to ensure a total of 3 digits
  var decimalDigits = 3 - integerDigits;
  if (decimalDigits < 0) decimalDigits = 0;

  // Format the number with the appropriate number of decimal places
  var formatted = temp.toStringAsFixed(decimalDigits);

  if (formatted.contains('.')) {
    // Remove trailing zeros
    formatted = formatted.replaceAll(RegExp(r'0*$'), '');
  }

  final sign = number < 0 ? '-' : '';
  final suffix = suffixes[suffixIndex];
  return '$sign$formatted$suffix';
}
