import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pub_stats/constant/app_colors.dart';
import 'package:pub_stats/constant/app_theme.dart';
import 'package:pub_stats/constant/constants.dart';
import 'package:pub_stats/format/formatting.dart';
import 'package:pub_stats/model/package_score_snapshot.dart';
import 'package:pub_stats/model/package_stats.dart';
import 'package:fast_ui/fast_ui.dart';
import 'package:pub_stats/view/widget/stats/base_stat_chart.dart';
import 'package:pub_stats_core/pub_stats_core.dart';
import 'package:url_launcher/url_launcher_string.dart';

class StatsCharts extends StatelessWidget {
  final List<PackageStats> stats;
  final bool showHint;
  final void Function(String package)? onComparisonRemoved;

  const StatsCharts({
    super.key,
    required this.stats,
    this.showHint = true,
    this.onComparisonRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final likeCountChart =
        LikeCountChart(spots: _createSpots((e) => e.likeCount));
    final popularityScoreChart = PopularityScoreChart(
      spots: _createSpots((e) => e.popularityScore),
      legacySpots: _createSpots((e) => e.legacyPopularityScore),
    );
    final downloadCountChart =
        DownloadCountChart(spots: _createSpots((e) => e.downloadCount));

    final overallRank = stats.first.overallRank;
    return Column(
      children: [
        if (stats.length == 1) ...[
          InkWell(
            borderRadius: AppTheme.pillRadius,
            onTap: () => launchUrlString(
              Constants.pubPackageBaseUrl + stats.first.package,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text(
                stats.first.package,
                style: context.textTheme.titleLarge,
              ),
            ),
          ),
          if (overallRank != null)
            Text(
              'Rank ${overallRank + 1}',
              style: context.textTheme.labelSmall,
            ),
          const SizedBox(height: 12),
          Text(
            'Last updated ${stats.first.stats.isNotEmpty ? Formatting.timeAgo(stats.first.stats.last.timestamp) : 'never'}',
            style: context.textTheme.bodySmall,
          ),
        ] else ...[
          Text('Comparing', style: context.textTheme.titleLarge),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: stats
                .mapIndexed(
                  (index, e) => Chip(
                    label: Text(e.package),
                    onDeleted: () => onComparisonRemoved?.call(e.package),
                    deleteIconColor: AppColors.chartLineColors.elementAt(index),
                  ),
                )
                .toList(),
          ),
        ],
        const SizedBox(height: 32),
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            likeCountChart,
            popularityScoreChart,
            downloadCountChart,
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

  List<List<FlSpot>> _createSpots(
    num? Function(PackageScoreSnapshot stats) getValue,
  ) {
    final groups = <List<FlSpot>>[];
    for (final package in stats) {
      final spots = <FlSpot>[];
      for (final stat in package.stats) {
        final value = getValue(stat);
        if (value == null) continue;
        final spot = FlSpot(
          stat.timestamp.millisecondsSinceEpoch.toDouble(),
          value.toDouble(),
        );
        spots.add(spot);
      }
      groups.add(spots);
    }
    return groups;
  }
}

class LikeCountChart extends StatelessWidget {
  final List<List<FlSpot>> spots;

  const LikeCountChart({super.key, required this.spots});

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
          final y = barData.first.spots.first.y;
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
            lineBarsData: barData,
            gridData: BaseStatChart.defaultGridData,
            borderData: BaseStatChart.createDefaultBorderData(context),
            titlesData: BaseStatChart.defaultTitlesData,
            lineTouchData: BaseStatChart.createDefaultLineTouchData(context),
          ),
          duration: Duration.zero,
        );
      },
    );
  }
}

class PopularityScoreChart extends StatefulWidget {
  final List<List<FlSpot>> spots;
  final List<List<FlSpot>> legacySpots;

  const PopularityScoreChart({
    super.key,
    required this.spots,
    required this.legacySpots,
  });

  @override
  State<StatefulWidget> createState() => PopularityScoreChartState();
}

class PopularityScoreChartState extends State<PopularityScoreChart> {
  var type = PopularityScoreType.modern;

  @override
  Widget build(BuildContext context) {
    return BaseStatChart(
      spots: switch (type) {
        PopularityScoreType.modern => widget.spots,
        PopularityScoreType.legacy => widget.legacySpots,
      },
      label: 'Popularity Score',
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => showDialog(
            context: context,
            builder: (context) => const AlertDialog(
              title: Text('About Popularity Score'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '''
Popularity score is a metric that attempts to quantify the overall popularity of a package.

Modern popularity scores are calculated by pub_stats based on the raw download count of a package relative to others.

Legacy popularity scores were calculated by pub.dev based on a filtered download count, but are no longer computed.''',
                  ),
                ],
              ),
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.swap_horiz),
          tooltip: switch (type) {
            PopularityScoreType.modern => 'Show legacy scores',
            PopularityScoreType.legacy => 'Show modern scores',
          },
          onPressed: () {
            setState(() {
              type = switch (type) {
                PopularityScoreType.modern => PopularityScoreType.legacy,
                PopularityScoreType.legacy => PopularityScoreType.modern,
              };
            });
          },
        ),
      ],
      builder: (singleY, barData) => LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          lineBarsData: barData,
          gridData: BaseStatChart.defaultGridData,
          borderData: BaseStatChart.createDefaultBorderData(context),
          titlesData: BaseStatChart.defaultTitlesData,
          lineTouchData: BaseStatChart.createDefaultLineTouchData(context),
        ),
        duration: Duration.zero,
      ),
    );
  }
}

enum PopularityScoreType { modern, legacy }

class DownloadCountChart extends StatelessWidget {
  final List<List<FlSpot>> spots;

  const DownloadCountChart({super.key, required this.spots});

  @override
  Widget build(BuildContext context) {
    return BaseStatChart(
      spots: spots,
      label: 'Download Count',
      formatValue: formatLargeNum,
      builder: (singleY, barData) => LineChart(
        LineChartData(
          lineBarsData: barData,
          gridData: BaseStatChart.defaultGridData,
          borderData: BaseStatChart.createDefaultBorderData(context),
          titlesData: BaseStatChart.defaultTitlesData,
          lineTouchData: BaseStatChart.createDefaultLineTouchData(
            context,
            formatValue: formatLargeNum,
          ),
        ),
        duration: Duration.zero,
      ),
    );
  }
}
