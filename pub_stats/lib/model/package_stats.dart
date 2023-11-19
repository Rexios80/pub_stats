import 'package:pub_stats/model/package_score_snapshot.dart';

class PackageStats {
  final String package;
  final List<PackageScoreSnapshot> stats;

  PackageStats({
    required this.package,
    required this.stats,
  });
}
