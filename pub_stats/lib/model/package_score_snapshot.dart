import 'package:pub_stats_core/pub_stats_core.dart';
import 'package:meta/meta.dart';

@immutable
class PackageScoreSnapshot {
  final DateTime timestamp;
  final int likeCount;
  final int? legacyPopularityScore;
  final int? popularityScore;
  final int? downloadCount;

  const PackageScoreSnapshot._({
    required this.timestamp,
    required this.likeCount,
    required this.legacyPopularityScore,
    required this.popularityScore,
    required this.downloadCount,
  });

  factory PackageScoreSnapshot.fromMiniPackageScore({
    required int timestamp,
    required MiniPackageScore score,
  }) {
    return PackageScoreSnapshot._(
      timestamp: DateTimeExtension.fromSecondsSinceEpoch(timestamp),
      likeCount: score.likeCount,
      legacyPopularityScore: score.legacyPopularityScore,
      popularityScore: score.popularityScore,
      downloadCount: score.downloadCount,
    );
  }

  @override
  String toString() {
    return 'PackageScoreSnapshot{timestamp: $timestamp, likeCount: $likeCount, popularityScore: $popularityScore}';
  }
}
