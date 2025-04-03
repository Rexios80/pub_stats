import 'package:fast_ui/fast_ui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/controller/data_controller.dart';
import 'package:pub_stats/view/widget/global_stats_view.dart';
import 'package:pub_stats/view/widget/stats/diff_list.dart';
import 'package:pub_stats/view/widget/stats/stats_charts.dart';
import 'package:sliver_tools/sliver_tools.dart';

class StatsView extends StatelessWidget {
  static final _controller = GetIt.I<DataController>();

  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return FastBuilder(() {
      if (_controller.loadedStats.isNotEmpty) {
        return MultiSliver(
          children: [
            SliverToBoxAdapter(
              child: StatsCharts(
                stats: _controller.loadedStats,
                onComparisonRemoved: _controller.removeStats,
              ),
            ),
            if (_controller.loadedStats.length == 1) ...[
              const SizedBox(height: 32),
              const SliverCrossAxisConstrained(
                maxCrossAxisExtent: 800,
                child: DiffList(),
              ),
            ],
          ],
        );
      } else {
        return SliverToBoxAdapter(
          child: GlobalStatsView(stats: _controller.globalStats),
        );
      }
    });
  }
}
