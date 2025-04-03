import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/constant/app_theme.dart';
import 'package:pub_stats/controller/data_controller.dart';
import 'package:pub_stats/format/formatting.dart';
import 'package:pub_stats/view/widget/stats/base_stat_chart.dart';
import 'package:pub_stats_core/pub_stats_core.dart';
import 'package:fast_ui/fast_ui.dart';

class GlobalStatsView extends StatelessWidget {
  final _dataController = GetIt.I<DataController>();

  final GlobalStats stats;

  GlobalStatsView({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final statItems = [
      GlobalStatItem(
        stat: stats.mostDownloadedPackage,
        label: 'Most downloaded package',
        onTap: () => _dataController.fetchStats(stats.mostDownloadedPackage),
      ),
      GlobalStatItem(
        stat: stats.mostLikedPackage,
        label: 'Most liked package',
        onTap: () => _dataController.fetchStats(stats.mostLikedPackage),
      ),
      GlobalStatItem(
        stat: stats.mostDependedPackage,
        label: 'Most depended package',
        onTap: () => _dataController.fetchStats(stats.mostDependedPackage),
      ),
      GlobalStatItem(
        stat: Formatting.number(stats.packageCount),
        label: 'Packages scanned',
      ),
      GlobalStatItem(
        stat: Formatting.timeAgo(stats.lastUpdated),
        label: 'Last updated',
      ),
    ];
    return Column(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Wrap(
            alignment: WrapAlignment.center,
            children:
                statItems.map((e) => SizedBox(width: 250, child: e)).toList(),
          ),
        ),
        const SizedBox(height: 16),
        FastBuilder(() => PackageCountChart(spots: _createPackageCountSpots())),
      ],
    );
  }

  List<FlSpot> _createPackageCountSpots() {
    return _dataController.packageCounts
        .map(
          (e) => FlSpot(
            e.timestamp.millisecondsSinceEpoch.toDouble(),
            e.count.toDouble(),
          ),
        )
        .toList();
  }
}

class GlobalStatItem extends StatelessWidget {
  final String stat;
  final String label;
  final VoidCallback? onTap;

  const GlobalStatItem({
    super.key,
    required this.stat,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppTheme.pillRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(stat, style: context.textTheme.titleLarge),
              ),
              const SizedBox(height: 4),
              Text(label, style: context.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class PackageCountChart extends StatelessWidget {
  final List<FlSpot> spots;

  const PackageCountChart({super.key, required this.spots});

  @override
  Widget build(BuildContext context) {
    return BaseStatChart(
      spots: [spots],
      label: 'Total Package Count',
      builder:
          (singleY, barData) => LineChart(
            LineChartData(
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
