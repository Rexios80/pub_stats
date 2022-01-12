import 'package:fast_ui/fast_ui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/controller/data_controller.dart';
import 'package:pub_stats/view/widget/global_stats_view.dart';
import 'package:pub_stats/view/widget/stats/developer_package_stats.dart';
import 'package:pub_stats/view/widget/stats/stats_charts.dart';

class StatsView extends StatelessWidget {
  final _controller = GetIt.I<DataController>();

  StatsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FastBuilder(
      () {
        if (_controller.loadedStats.value.stats.isNotEmpty) {
          return SliverToBoxAdapter(
            child: StatsCharts(stats: _controller.loadedStats.value),
          );
        } else if (_controller.developerPackageStats.isNotEmpty) {
          return DeveloperPackageStats(
            stats: _controller.developerPackageStats,
          );
        } else {
          return SliverToBoxAdapter(
            child: GlobalStatsView(stats: _controller.globalStats),
          );
        }
      },
    );
  }
}
