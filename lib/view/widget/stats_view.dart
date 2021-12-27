import 'package:fast_ui/fast_ui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/controller/data_controller.dart';
import 'package:pub_stats/view/widget/global_stats_view.dart';
import 'package:pub_stats/view/widget/stats_graphs.dart';

class StatsView extends StatelessWidget {
  final _controller = GetIt.I<DataController>();

  StatsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FastBuilder(
      () {
        if (_controller.submittedPackageName.value.isEmpty ||
            _controller.loadedStats.isEmpty) {
          // If the user has not submitted a package name and data is not loading
          return GlobalStatsView(stats: _controller.globalStats);
        } else {
          return StatsCharts(
            package: _controller.submittedPackageName.value,
            stats: _controller.loadedStats,
          );
        }
      },
    );
  }
}
