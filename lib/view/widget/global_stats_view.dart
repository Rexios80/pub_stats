import 'package:flutter/material.dart';
import 'package:pub_stats/constant/app_theme.dart';
import 'package:pub_stats/format/formatting.dart';
import 'package:pub_stats_core/pub_stats_core.dart';
import 'package:fast_ui/fast_ui.dart';

class GlobalStatsView extends StatelessWidget {
  static const _constraints = BoxConstraints(maxWidth: 250);

  final GlobalStats stats;

  const GlobalStatsView({
    Key? key,
    required this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statItems = [
      GlobalStatItem(
        stat: stats.mostPopularPackage,
        label: 'Most popular package',
      ),
      GlobalStatItem(
        stat: stats.mostLikedPackage,
        label: 'Most liked package',
      ),
      GlobalStatItem(
        stat: Formatting.number(stats.packageCount),
        label: 'Packages scanned',
      ),
      GlobalStatItem(
        stat: Formatting.timeAgo(stats.lastUpdated),
        label: 'Last updated',
      ),
    ];
    if (AppTheme.isWide(context)) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            constraints: _constraints,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                statItems[0],
                statItems[2],
              ],
            ),
          ),
          Container(
            constraints: _constraints,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                statItems[1],
                statItems[3],
              ],
            ),
          ),
        ],
      );
    } else {
      return Container(
        constraints: _constraints,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: statItems,
        ),
      );
    }
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
    return Card(
      // TODO: Put in theme
      shape: RoundedRectangleBorder(borderRadius: AppTheme.pillRadius),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(stat, style: context.textTheme.headline6),
            const SizedBox(height: 4),
            Text(label, style: context.textTheme.caption),
          ],
        ),
      ),
    );
  }
}