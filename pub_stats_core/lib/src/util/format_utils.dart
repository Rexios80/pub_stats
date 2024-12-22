String formatLargeNum(num? number) {
  if (number == null) return 'null';
  if (number < 1000) return number.toInt().toString();

  const suffixes = ['K', 'M', 'B', 'T'];
  var suffixIndex = -1;
  var temp = number.toDouble();

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
  final formatted = temp
      .toStringAsFixed(decimalDigits)
      // Remove any trailing zeros and possible decimal point
      .replaceAll(RegExp(r'\.?0+$'), '');

  return '$formatted${suffixes[suffixIndex]}';
}
