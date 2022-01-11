import 'package:pub_stats/model/package_score_snapshot.dart';

class LoadedStats {
  final String package;
  final List<PackageScoreSnapshot> stats;

  LoadedStats({
    required this.package,
    required this.stats,
  });

  LoadedStats.empty() : this(package: '', stats: []);
}
