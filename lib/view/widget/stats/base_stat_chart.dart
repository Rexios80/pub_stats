import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/constant/app_colors.dart';
import 'package:pub_stats/controller/data_controller.dart';
import 'package:pub_stats/format/formatting.dart';
import 'package:pub_stats/view/widget/stats/stat_overview.dart';
import 'package:fast_ui/fast_ui.dart';
import 'package:collection/collection.dart';

class BaseStatChart extends StatelessWidget {
  static const defaultGridData = FlGridData(show: false);
  static const defaultTitlesData = FlTitlesData(
    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
    leftTitles: AxisTitles(
      sideTitles: SideTitles(showTitles: true, reservedSize: 50),
      drawBelowEverything: true,
    ),
  );

  final controller = GetIt.I<DataController>();

  final List<List<FlSpot>> spots;
  final String label;
  final Widget Function(bool singleY, List<LineChartBarData> barData) builder;

  List<List<FlSpot>> get filteredSpots {
    // Always access the timestamp value to register
    final timeSpan = controller.timeSpan.value;
    return spots
        .map(
          (e) => e.where((e) {
            final date = DateTime.fromMillisecondsSinceEpoch(e.x.toInt());
            return timeSpan.contains(date);
          }).toList(),
        )
        .toList();
  }

  BaseStatChart({
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
          child: FastBuilder(
            () => Column(
              children: [
                Text(label),
                if (filteredSpots.first.isEmpty) ...[
                  const Spacer(),
                  const Text('No data'),
                  const Spacer(),
                ] else if (filteredSpots.first.length < 2) ...[
                  const Spacer(),
                  Text(
                    filteredSpots.first.first.y.toInt().toString(),
                    style: context.textTheme.titleLarge,
                  ),
                  const Spacer(),
                  const Text('Not enough data to show chart'),
                ] else ...[
                  const SizedBox(height: 12),
                  StatOverview(spots: filteredSpots.first),
                  const SizedBox(height: 24),
                  Expanded(
                    child: builder(_singleY(), _createLineChartBarData()),
                  ),
                ],
              ],
            ),
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
        tooltipBgColor: context.theme.cardColor,
        getTooltipItems: (spots) => spots.mapIndexed((spotIndex, spot) {
          final barIndex = spot.barIndex;
          final valueString = spot.y.toInt().toString();
          final valueStyle =
              TextStyle(color: AppColors.chartLineColors[barIndex]);
          final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
          final dateString = Formatting.shortDate(date);

          if (spotIndex == 0) {
            return LineTooltipItem(
              dateString,
              const TextStyle(),
              children: [
                TextSpan(text: '\n$valueString', style: valueStyle),
              ],
            );
          } else {
            return LineTooltipItem(valueString, valueStyle);
          }
        }).toList(),
      ),
    );
  }

  List<LineChartBarData> _createLineChartBarData() {
    return filteredSpots
        .mapIndexed(
          (index, e) => LineChartBarData(
            spots: e.toList(),
            dotData: FlDotData(show: filteredSpots.first.length < 10),
            color: AppColors.chartLineColors[index],
          ),
        )
        .toList();
  }

  /// If the spots only have one unique y value
  bool _singleY() {
    if (filteredSpots.length > 1) return false;
    return groupBy<FlSpot, int>(filteredSpots.first, (e) => e.y.toInt())
            .keys
            .length ==
        1;
  }
}
