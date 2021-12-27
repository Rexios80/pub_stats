import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pub_stats/constant/app_theme.dart';
import 'package:pub_stats/model/package_score_snapshot.dart';
import 'package:fast_ui/fast_ui.dart';
import 'package:collection/collection.dart';

class StatsCharts extends StatelessWidget {
  final List<PackageScoreSnapshot> stats;

  const StatsCharts({Key? key, required this.stats}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final likeCountChart = LikeCountChart(spots: _createLikeCountSpots());
    final popularityScoreChart =
        PopularityScoreChart(spots: _createPopularityScoreSpots());

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
  final String label;
  final Widget Function(bool singleY) builder;

  const BaseStatChart({
    Key? key,
    required this.spots,
    required this.label,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 300,
      child: Card(
        // TODO: Part of theme
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Text(label),
              if (spots.length < 2) ...[
                const Spacer(),
                Text(
                  spots.first.y.toInt().toString(),
                  style: context.textTheme.headline6,
                ),
                const Spacer(),
                const Text('Not enough data to show chart'),
              ] else
                Expanded(child: builder(_singleY())),
            ],
          ),
        ),
      ),
    );
  }

  /// If the spots only have one unique y value
  bool _singleY() {
    return groupBy(spots, (FlSpot e) => e.y.toInt()).keys.length == 1;
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
      label: 'Like Count',
      builder: (_) => LineChart(
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
      spots: spots,
      label: 'Popularity Score',
      builder: (singleY) {
        // If there is one unique Y value, the min/max Y values must be set manually
        final double? minY;
        final double? maxY;
        if (singleY) {
          final y = spots.first.y;
          minY = y < 10 ? 0 : y - 10;
          maxY = y + 10;
        } else {
          minY = null;
          maxY = null;
        }
        return LineChart(
          LineChartData(
            minY: minY,
            maxY: maxY,
            lineBarsData: [LineChartBarData(spots: spots)],
          ),
        );
      },
    );
  }
}
