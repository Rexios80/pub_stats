import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatOverview extends StatelessWidget {
  final List<FlSpot> spots;

  const StatOverview({Key? key, required this.spots}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final last = spots.last.y;
    final secondToLast = spots[spots.length - 2].y;
    final lastChange = (last - secondToLast).round();

    final String lastChangeText;
    final Color changeColor;
    if (lastChange > 0) {
      lastChangeText = '(+$lastChange)';
      changeColor = Colors.green;
    } else if (lastChange < 0) {
      // Don't need a negative sign for a negative number
      lastChangeText = '($lastChange)';
      changeColor = Colors.red;
    } else {
      lastChangeText = '(+0)';
      changeColor = Colors.grey;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(last.round().toString()),
        const SizedBox(width: 8),
        Text(lastChangeText, style: TextStyle(color: changeColor)),
      ],
    );
  }
}