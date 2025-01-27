import 'package:pub_stats/model/package_score_snapshot.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

class PackageStats {
  final String package;
  final List<PackageScoreSnapshot> stats;
  final DateTime firstScan;
  final PackageData data;

  PackageStats({
    required this.package,
    required this.stats,
    required this.firstScan,
    required this.data,
  });
}
