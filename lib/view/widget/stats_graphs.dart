import 'package:flutter/material.dart';
import 'package:pub_stats/model/package_score_snapshot.dart';

class StatsGraphs extends StatelessWidget {
  final List<PackageScoreSnapshot> stats;

  const StatsGraphs({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(stats.toString());
  }
}
