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
  static const _constraints = BoxConstraints(maxWidth: 250);
  final _dataController = GetIt.I<DataController>();

  final GlobalStats stats;

  GlobalStatsView({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final statItems = [
      GlobalStatItem(
        stat: stats.mostPopularPackage,
        label: 'Most popular package',
        onTap: () => _dataController.fetchStats(stats.mostPopularPackage),
      ),
      GlobalStatItem(
        stat: stats.mostLikedPackage,
        label: 'Most liked package',
        onTap: () => _dataController.fetchStats(stats.mostLikedPackage),
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
        if (AppTheme.isWide(context))
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                constraints: _constraints,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    statItems[0],
                    statItems[2],
                  ],
                ),
              ),
              Container(
                constraints: _constraints,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    statItems[1],
                    statItems[3],
                  ],
                ),
              ),
            ],
          )
        else
          Center(
            child: Container(
              constraints: _constraints,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: statItems,
              ),
            ),
          ),
        const SizedBox(height: 16),
        PackageCountChart(spots: _createPackageCountSpots()),
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
              Text(stat, style: context.textTheme.titleLarge),
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
      spots: spots,
      label: 'Total Package Count',
      builder: (singleY, barData) => LineChart(
        LineChartData(
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
