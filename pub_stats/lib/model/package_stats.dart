import 'package:pub_stats/model/package_score_snapshot.dart';

class PackageStats {
  final String package;
  final List<PackageScoreSnapshot> stats;
  final DateTime firstScan;

  PackageStats({
    required this.package,
    required this.stats,
    required this.firstScan,
  });
}
