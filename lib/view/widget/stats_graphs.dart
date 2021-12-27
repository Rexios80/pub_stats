import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pub_stats/constant/app_theme.dart';
import 'package:pub_stats/model/package_score_snapshot.dart';
import 'package:fast_ui/fast_ui.dart';

class StatsCharts extends StatelessWidget {
  static const _chartConstraints =
      BoxConstraints(maxWidth: 400, maxHeight: 300);

  final List<PackageScoreSnapshot> stats;

  const StatsCharts({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final likeCountChart = Container(
      constraints: _chartConstraints,
      child: LikeCountChart(spots: _createLikeCountSpots()),
    );
    final popularityScoreChart = Container(
      constraints: _chartConstraints,
      child: PopularityScoreChart(spots: _createPopularityScoreSpots()),
    );

    if (AppTheme.isWide(context)) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          likeCountChart,
          popularityScoreChart,
        ],
      );
    } else {
      return Column(
        children: [
          likeCountChart,
          popularityScoreChart,
        ],
      );
    }
  }

  List<FlSpot> _createLikeCountSpots() {
    return stats
        .map(
          (e) => FlSpot(
            e.captureTimestamp.millisecondsSinceEpoch.toDouble(),
            e.likeCount.toDouble(),
          ),
        )
        .toList();
  }

  List<FlSpot> _createPopularityScoreSpots() {
    return stats
        .map(
          (e) => FlSpot(
            e.captureTimestamp.millisecondsSinceEpoch.toDouble(),
            e.popularityScore.toDouble(),
          ),
        )
        .toList();
  }
}

class BaseStatChart extends StatelessWidget {
  final List<FlSpot> spots;
  final String notEnoughDataLabel;
  final Widget child;

  const BaseStatChart({
    Key? key,
    required this.spots,
    required this.notEnoughDataLabel,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      // TODO: Part of theme
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Builder(
          builder: (context) {
            if (spots.length < 2) {
              return Column(
                children: [
                  const Spacer(),
                  Text(
                    spots.first.y.toInt().toString(),
                    style: context.textTheme.headline6,
                  ),
                  const SizedBox(height: 4),
                  Text(notEnoughDataLabel, style: context.textTheme.caption),
                  const Spacer(),
                  const Text('Not enough data to show chart'),
                ],
              );
            }
            return child;
          },
        ),
      ),
    );
  }
}

// TODO: Absract these somehow?
class LikeCountChart extends StatelessWidget {
  final List<FlSpot> spots;

  const LikeCountChart({Key? key, required this.spots}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseStatChart(
      spots: spots,
      notEnoughDataLabel: 'Current like count',
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          lineBarsData: [LineChartBarData(spots: spots)],
        ),
      ),
    );
  }
}

class PopularityScoreChart extends StatelessWidget {
  final List<FlSpot> spots;

  const PopularityScoreChart({Key? key, required this.spots}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseStatChart(
      notEnoughDataLabel: 'Current popularity score',
      spots: spots,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 100,
          lineBarsData: [LineChartBarData(spots: spots)],
        ),
      ),
    );
  }
}
