import 'package:fast_ui/fast_ui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/controller/data_controller.dart';

class StatsView extends StatelessWidget {
  final _controller = GetIt.I<DataController>();

  StatsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FastBuilder(() {
      if (_controller.submittedPackageName.value.isEmpty) {
        // If the user has not submitted a package name, show nothing
        return const SizedBox.shrink();
      }
      return Text('');
    });
  }

  Widget _buildGlobalStatsWidget() {
    return Column(
      children: [],
    );
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Text('No stats available for ${_controller.submittedPackageName}'),
    );
  }
}
