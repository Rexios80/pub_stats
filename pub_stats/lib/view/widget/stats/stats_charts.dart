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
import 'package:pub_stats/view/widget/stats/shields_badge.dart';
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
    final firstDate = stats
        .map((package) => package.stats.first.timestamp)
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final lastDate = stats
        .map((package) => package.stats.last.timestamp)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    final likeCountChart = LikeCountChart(
      spots: _createSpots((e) => e.likeCount),
      firstDate: firstDate,
      lastDate: lastDate,
    );
    final popularityScoreChart = PopularityScoreChart(
      spots: _createSpots((e) => e.popularityScore),
      legacySpots: _createSpots((e) => e.legacyPopularityScore),
      firstDate: firstDate,
      lastDate: lastDate,
    );
    final downloadCountChart = DownloadCountChart(
      spots: _createSpots((e) => e.downloadCount),
      firstDate: firstDate,
      lastDate: lastDate,
    );

    return Column(
      children: [
        if (stats.length == 1)
          ..._buildPackageHeader(context)
        else
          ..._buildCompareHeader(context),
        const SizedBox(height: 32),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          runSpacing: 4,
          children: [likeCountChart, popularityScoreChart, downloadCountChart],
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

  List<Widget> _buildPackageHeader(BuildContext context) {
    final package = stats.first.package;
    final packageStats = stats.first.stats;
    final lastUpdated =
        packageStats.isNotEmpty
            ? Formatting.timeAgo(packageStats.last.timestamp)
            : 'never';
    final data = stats.first.data;
    final overallRank = data.overallRank;
    return [
      InkWell(
        borderRadius: AppTheme.pillRadius,
        onTap: () => launchUrlString(Constants.pubPackageBaseUrl + package),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(package, style: context.textTheme.titleLarge),
        ),
      ),
      Text('Last updated $lastUpdated', style: context.textTheme.bodySmall),
      const SizedBox(height: 12),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          ShieldsBadge(
            package: package,
            type: BadgeType.popularity,
            value: data.popularityScore,
          ),
          ShieldsBadge(
            package: package,
            type: BadgeType.rank,
            value: overallRank != null ? overallRank + 1 : null,
          ),
          ShieldsBadge(
            package: package,
            type: BadgeType.dependents,
            value: data.numDependents,
          ),
        ],
      ),
      const SizedBox(height: 12),
      Text(
        'Click a badge to copy its markdown',
        style: context.textTheme.bodySmall,
      ),
    ];
  }

  List<Widget> _buildCompareHeader(BuildContext context) {
    return [
      Text('Comparing', style: context.textTheme.titleLarge),
      const SizedBox(height: 16),
      Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        children:
            stats
                .mapIndexed(
                  (index, e) => Chip(
                    label: Text(e.package),
                    onDeleted: () => onComparisonRemoved?.call(e.package),
                    deleteIconColor: AppColors.chartLineColors.elementAt(index),
                  ),
                )
                .toList(),
      ),
    ];
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
  final DateTime firstDate;
  final DateTime lastDate;

  const LikeCountChart({
    super.key,
    required this.spots,
    required this.firstDate,
    required this.lastDate,
  });

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
            minX: firstDate.millisecondsSinceEpoch.toDouble(),
            maxX: lastDate.millisecondsSinceEpoch.toDouble(),
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
  final DateTime firstDate;
  final DateTime lastDate;

  const PopularityScoreChart({
    super.key,
    required this.spots,
    required this.legacySpots,
    required this.firstDate,
    required this.lastDate,
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
          onPressed:
              () => showDialog(
                context: context,
                builder:
                    (context) => const AlertDialog(
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
          icon: Icon(
            Icons.swap_horiz,
            color: switch (type) {
              PopularityScoreType.modern => null,
              PopularityScoreType.legacy => AppColors.primary,
            },
          ),
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
      builder:
          (singleY, barData) => LineChart(
            LineChartData(
              minY: 0,
              maxY: 100,
              minX: widget.firstDate.millisecondsSinceEpoch.toDouble(),
              maxX: widget.lastDate.millisecondsSinceEpoch.toDouble(),
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
  final DateTime firstDate;
  final DateTime lastDate;

  const DownloadCountChart({
    super.key,
    required this.spots,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return BaseStatChart(
      spots: spots,
      label: 'Download Count',
      formatValue: formatLargeNum,
      builder:
          (singleY, barData) => LineChart(
            LineChartData(
              lineBarsData: barData,
              minX: firstDate.millisecondsSinceEpoch.toDouble(),
              maxX: lastDate.millisecondsSinceEpoch.toDouble(),
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
