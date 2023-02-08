import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pub_stats/constant/app_colors.dart';
import 'package:pub_stats/format/formatting.dart';
import 'package:pub_stats/view/widget/stats/stat_overview.dart';
import 'package:fast_ui/fast_ui.dart';
import 'package:collection/collection.dart';

class BaseStatChart extends StatelessWidget {
  static final defaultGridData = FlGridData(show: false);
  static final defaultTitlesData = FlTitlesData(
    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(showTitles: true, reservedSize: 50),
      drawBehindEverything: true,
    ),
  );

  final List<FlSpot> spots;
  final String label;
  final Widget Function(bool singleY, LineChartBarData barData) builder;

  const BaseStatChart({
    super.key,
    required this.spots,
    required this.label,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 300,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Text(label),
              if (spots.isEmpty) ...[
                const Spacer(),
                const Text('No data'),
                const Spacer(),
              ] else if (spots.length < 2) ...[
                const Spacer(),
                Text(
                  spots.first.y.toInt().toString(),
                  style: context.textTheme.titleLarge,
                ),
                const Spacer(),
                const Text('Not enough data to show chart'),
              ] else ...[
                const SizedBox(height: 12),
                StatOverview(spots: spots),
                const SizedBox(height: 24),
                Expanded(child: builder(_singleY(), _createLineChartBarData())),
              ]
            ],
          ),
        ),
      ),
    );
  }

  static FlBorderData createDefaultBorderData(BuildContext context) {
    return FlBorderData(
      border: Border(
        top: BorderSide.none,
        bottom: BorderSide(color: context.textTheme.bodyLarge!.color!),
        left: BorderSide(color: context.textTheme.bodyLarge!.color!),
        right: BorderSide.none,
      ),
    );
  }

  static LineTouchData createDefaultLineTouchData(BuildContext context) {
    return LineTouchData(
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (spots) => spots.map((e) {
          final valueString = e.y.toInt().toString();
          final date = DateTime.fromMillisecondsSinceEpoch(e.x.toInt());
          final dateString = Formatting.shortDate(date);
          return LineTooltipItem(
            '$valueString\n$dateString',
            context.textTheme.bodyLarge!,
          );
        }).toList(),
      ),
    );
  }

  LineChartBarData _createLineChartBarData() {
    return LineChartBarData(
      spots: spots,
      dotData: FlDotData(show: spots.length < 10),
      color: AppColors.primarySwatch,
    );
  }

  /// If the spots only have one unique y value
  bool _singleY() {
    return groupBy<FlSpot, int>(spots, (e) => e.y.toInt()).keys.length == 1;
  }
}
