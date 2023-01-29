import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pub_stats/constant/app_theme.dart';
import 'package:pub_stats/constant/constants.dart';
import 'package:pub_stats/format/formatting.dart';
import 'package:pub_stats/model/loaded_stats.dart';
import 'package:fast_ui/fast_ui.dart';
import 'package:pub_stats/view/widget/stats/base_stat_chart.dart';
import 'package:url_launcher/url_launcher_string.dart';

class StatsCharts extends StatelessWidget {
  final LoadedStats stats;
  final bool showHint;

  const StatsCharts({Key? key, required this.stats, this.showHint = true})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final likeCountChart = LikeCountChart(spots: _createLikeCountSpots());
    final popularityScoreChart =
        PopularityScoreChart(spots: _createPopularityScoreSpots());

    return Column(
      children: [
        InkWell(
          borderRadius: AppTheme.pillRadius,
          onTap: () =>
              launchUrlString(Constants.pubPackageBaseUrl + stats.package),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(stats.package, style: context.textTheme.titleLarge),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Last updated ${stats.stats.isNotEmpty ? Formatting.timeAgo(stats.stats.last.timestamp) : 'never'}',
          style: context.textTheme.bodySmall,
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
        if (showHint) ...[
          const SizedBox(height: 16),
          Text(
            'Hover/touch the charts for more information',
            style: context.textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  List<FlSpot> _createLikeCountSpots() {
    return stats.stats
        .map(
          (e) => FlSpot(
            e.timestamp.millisecondsSinceEpoch.toDouble(),
            e.likeCount.toDouble(),
          ),
        )
        .toList();
  }

  List<FlSpot> _createPopularityScoreSpots() {
    return stats.stats
        .map(
          (e) => FlSpot(
            e.timestamp.millisecondsSinceEpoch.toDouble(),
            e.popularityScore.toDouble(),
          ),
        )
        .toList();
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
          swapAnimationDuration: Duration.zero,
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
        swapAnimationDuration: Duration.zero,
      ),
    );
  }
}
