import 'package:flutter/material.dart';
import 'package:pub_stats/model/package_stats.dart';
import 'package:pub_stats/view/widget/stats/stats_charts.dart';

class DeveloperPackageStats extends StatelessWidget {
  final List<PackageStats> stats;

  const DeveloperPackageStats({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          // Add padding to every item except the last one
          padding:
              EdgeInsets.only(bottom: index == (stats.length - 1) ? 0 : 32),
          child: StatsCharts(stats: [stats[index]], showHint: false),
        ),
        childCount: stats.length,
      ),
    );
  }
}
