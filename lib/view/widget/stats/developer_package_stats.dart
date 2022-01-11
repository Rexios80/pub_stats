import 'package:flutter/material.dart';
import 'package:pub_stats/model/loaded_stats.dart';
import 'package:pub_stats/view/widget/stats/stats_charts.dart';

class DeveloperPackageStats extends StatelessWidget {
  final List<LoadedStats> stats;

  const DeveloperPackageStats({Key? key, required this.stats})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: stats
          .expand(
            (e) => [
              StatsCharts(stats: e, showHint: false),
              const SizedBox(height: 32),
            ],
          )
          .toList(),
    );
  }
}
