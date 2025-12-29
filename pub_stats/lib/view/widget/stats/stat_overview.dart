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
    final first = spots.first.y;
    final change = (last - first).round();

    final changeFormatted = formatValue(change);
    final String lastChangeText;
    final Color changeColor;
    if (change > 0) {
      lastChangeText = '(+$changeFormatted)';
      changeColor = Colors.green;
    } else if (change < 0) {
      // Don't need a negative sign for a negative number
      lastChangeText = '($changeFormatted)';
      changeColor = Colors.red;
    } else {
      lastChangeText = '(0)';
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
