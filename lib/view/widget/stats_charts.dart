import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pub_stats/constant/app_theme.dart';
import 'package:pub_stats/constant/constants.dart';
import 'package:pub_stats/format/formatting.dart';
import 'package:pub_stats/model/loaded_stats.dart';
import 'package:fast_ui/fast_ui.dart';
import 'package:collection/collection.dart';
import 'package:url_launcher/url_launcher.dart';

class StatsCharts extends StatelessWidget {
  final LoadedStats stats;

  const StatsCharts({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final likeCountChart = LikeCountChart(spots: _createLikeCountSpots());
    final popularityScoreChart =
        PopularityScoreChart(spots: _createPopularityScoreSpots());

    return Column(
      children: [
        InkWell(
          borderRadius: AppTheme.pillRadius,
          onTap: () => launch(Constants.pubPackageBaseUrl + stats.package),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(stats.package, style: context.textTheme.headline6),
          ),
        ),
        const SizedBox(height: 32),
        if (AppTheme.isWide(context))
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              likeCountChart,
              popularityScoreChart,
            ],
          )
        else
          Column(
            children: [
              likeCountChart,
              popularityScoreChart,
            ],
          ),
        const SizedBox(height: 16),
        Text(
          'Hover/touch the charts for more information',
          style: context.textTheme.caption,
        ),
      ],
    );
  }

  List<FlSpot> _createLikeCountSpots() {
    return stats.stats
        .map(
          (e) => FlSpot(
            e.captureTimestamp.millisecondsSinceEpoch.toDouble(),
            e.likeCount.toDouble(),
          ),
        )
        .toList();
  }

  List<FlSpot> _createPopularityScoreSpots() {
    return stats.stats
        .map(
          (e) => FlSpot(
            e.captureTimestamp.millisecondsSinceEpoch.toDouble(),
            e.popularityScore.toDouble(),
          ),
        )
        .toList();
  }
}

class BaseStatChart extends StatelessWidget {
  static final defaultGridData = FlGridData(show: false);
  static final defaultTitlesData = FlTitlesData(
    topTitles: SideTitles(showTitles: false),
    bottomTitles: SideTitles(showTitles: false),
    rightTitles: SideTitles(showTitles: false),
  );

  final List<FlSpot> spots;
  final String label;
  final Widget Function(bool singleY, LineChartBarData barData) builder;

  const BaseStatChart({
    Key? key,
    required this.spots,
    required this.label,
    required this.builder,
  }) : super(key: key);

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
              if (spots.length < 2) ...[
                const Spacer(),
                Text(
                  spots.first.y.toInt().toString(),
                  style: context.textTheme.headline6,
                ),
                const Spacer(),
                const Text('Not enough data to show chart'),
              ] else ...[
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
        bottom: BorderSide(color: context.textTheme.bodyText1!.color!),
        left: BorderSide(color: context.textTheme.bodyText1!.color!),
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
            context.textTheme.bodyText1!,
          );
        }).toList(),
      ),
    );
  }

  LineChartBarData _createLineChartBarData() {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      preventCurveOverShooting: true,
      dotData: FlDotData(show: spots.length < 10),
    );
  }

  /// If the spots only have one unique y value
  bool _singleY() {
    return groupBy(spots, (FlSpot e) => e.y.toInt()).keys.length == 1;
  }
}

class LikeCountChart extends StatelessWidget {
  final List<FlSpot> spots;

  const LikeCountChart({Key? key, required this.spots}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseStatChart(
      spots: spots,
      label: 'Like Count',
      builder: (singleY, barData) {
        // If there is one unique Y value, the min/max Y values must be set manually
        final double? minY;
        final double? maxY;
        if (singleY) {
          final y = spots.first.y;
          minY = y < 10 ? 0 : y - 10;
          maxY = y + 10;
        } else {
          minY = null;
          maxY = null;
        }
        return LineChart(
          LineChartData(
            minY: minY,
            maxY: maxY,
            lineBarsData: [barData],
            gridData: BaseStatChart.defaultGridData,
            borderData: BaseStatChart.createDefaultBorderData(context),
            titlesData: BaseStatChart.defaultTitlesData,
            lineTouchData: BaseStatChart.createDefaultLineTouchData(context),
          ),
        );
      },
    );
  }
}

class PopularityScoreChart extends StatelessWidget {
  final List<FlSpot> spots;

  const PopularityScoreChart({Key? key, required this.spots}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseStatChart(
      spots: spots,
      label: 'Popularity Score',
      builder: (singleY, barData) => LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          lineBarsData: [barData],
          gridData: BaseStatChart.defaultGridData,
          borderData: BaseStatChart.createDefaultBorderData(context),
          titlesData: BaseStatChart.defaultTitlesData,
          lineTouchData: BaseStatChart.createDefaultLineTouchData(context),
        ),
      ),
    );
  }
}
