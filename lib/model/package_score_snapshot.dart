import 'package:pub_stats_core/pub_stats_core.dart';

class PackageScoreSnapshot {
  final DateTime captureTimestamp;
  final int likeCount;
  final int popularityScore;

  PackageScoreSnapshot._({
    required this.captureTimestamp,
    required this.likeCount,
    required this.popularityScore,
  });

  factory PackageScoreSnapshot.fromMiniPackageScore({
    required int captureTimestamp,
    required MiniPackageScore score,
  }) {
    return PackageScoreSnapshot._(
      captureTimestamp:
          DateTime.fromMillisecondsSinceEpoch(captureTimestamp * 1000),
      likeCount: score.l,
      popularityScore: score.p,
    );
  }

  @override
  String toString() {
    return 'PackageScoreSnapshot{captureTimestamp: $captureTimestamp, likeCount: $likeCount, popularityScore: $popularityScore}';
  }
}
