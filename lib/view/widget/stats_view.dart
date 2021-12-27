import 'package:fast_ui/fast_ui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/controller/data_controller.dart';
import 'package:pub_stats/view/widget/global_stats_view.dart';

class StatsView extends StatelessWidget {
  final _controller = GetIt.I<DataController>();

  StatsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FastBuilder(() {
      if (_controller.submittedPackageName.value.isEmpty ||
          _controller.loading.value) {
        // If the user has not submitted a package name or data is loading
        return GlobalStatsView(stats: _controller.globalStats);
      } else if (_controller.loadedStats.isEmpty) {
        // If there are no stats for the given package
        return _buildNoDataWidget();
      } else {
        return _buildStatsWidget();
      }
    });
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Text('No stats available for ${_controller.submittedPackageName}'),
    );
  }

  Widget _buildStatsWidget() {
    return Column(
      children: [],
    );
  }
}
