import 'package:pub_stats_core/pub_stats_core.dart';

class PackageScoreSnapshot {
  final DateTime timestamp;
  final int likeCount;
  final int? popularityScore;
  final int? popularityScore2;

  PackageScoreSnapshot._({
    required this.timestamp,
    required this.likeCount,
    required this.popularityScore,
    required this.popularityScore2,
  });

  factory PackageScoreSnapshot.fromMiniPackageScore({
    required int timestamp,
    required MiniPackageScore score,
  }) {
    return PackageScoreSnapshot._(
      timestamp: DateTimeExtension.fromSecondsSinceEpoch(timestamp),
      likeCount: score.likeCount,
      popularityScore: score.popularityScore,
      popularityScore2: score.popularityScore2,
    );
  }

  @override
  String toString() {
    return 'PackageScoreSnapshot{timestamp: $timestamp, likeCount: $likeCount, popularityScore: $popularityScore}';
  }
}
