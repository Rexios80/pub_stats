import 'package:fast_ui/fast_ui.dart';
import 'package:firebase_ui_database/firebase_ui_database.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/controller/data_controller.dart';
import 'package:pub_stats/view/widget/global_stats_view.dart';
import 'package:pub_stats/view/widget/stats/developer_package_stats.dart';
import 'package:pub_stats/view/widget/stats/stats_charts.dart';
import 'package:sliver_tools/sliver_tools.dart';

class StatsView extends StatelessWidget {
  final _controller = GetIt.I<DataController>();

  StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return FastBuilder(
      () {
        if (_controller.loadedStats.isNotEmpty) {
          final singlePackage = _controller.loadedStats.length == 1
              ? _controller.loadedStats.first.package
              : null;
          return MultiSliver(
            children: [
              SliverToBoxAdapter(
                child: StatsCharts(
                  stats: _controller.loadedStats,
                  onComparisonRemoved: _controller.removeStats,
                ),
              ),
              if (singlePackage != null)
                FirebaseDatabaseListView(
                  query: _controller.diffQuery(singlePackage),
                  reverse: true,
                  itemBuilder: (context, snapshot) {
                    return const ListTile(
                      title: Text('asdf'),
                    );
                  },
                ),
            ],
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
