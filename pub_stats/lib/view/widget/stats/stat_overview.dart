import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatOverview extends StatelessWidget {
  final Iterable<FlSpot> spots;
  final String Function(int value) formatValue;

  static String _defaultFormatValue(int value) => value.toString();

  const StatOverview({
    super.key,
    required this.spots,
    this.formatValue = _defaultFormatValue,
  });

  @override
  Widget build(BuildContext context) {
    final last = spots.last.y;
    final secondToLast = spots.elementAt(spots.length - 2).y;
    final lastChange = (last - secondToLast).round();

    final lastChangeFormatted = formatValue(lastChange);
    final String lastChangeText;
    final Color changeColor;
    if (lastChange > 0) {
      lastChangeText = '(+$lastChangeFormatted)';
      changeColor = Colors.green;
    } else if (lastChange < 0) {
      // Don't need a negative sign for a negative number
      lastChangeText = '($lastChangeFormatted)';
      changeColor = Colors.red;
    } else {
      lastChangeText = '(+0)';
      changeColor = Colors.grey;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(formatValue(last.round())),
        const SizedBox(width: 8),
        Text(lastChangeText, style: TextStyle(color: changeColor)),
      ],
    );
  }
}
