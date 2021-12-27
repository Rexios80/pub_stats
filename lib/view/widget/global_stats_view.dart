import 'package:flutter/material.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

class GlobalStatsView extends StatelessWidget {
  final GlobalStats stats;

  const GlobalStatsView({
    Key? key,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}

class GlobalStatItem extends StatelessWidget {
  final String stat;
  final String label;

  const GlobalStatItem({
    Key? key,
    required this.stat,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.shrink();
  }
}
