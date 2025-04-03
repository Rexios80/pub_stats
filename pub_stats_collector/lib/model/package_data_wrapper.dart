import 'dart:math' as math;

import 'package:pub_api_client/pub_api_client.dart';
import 'package:pub_stats_core/pub_stats_core.dart';
import 'package:meta/meta.dart';

@immutable
class PackageDataWrapper {
  final String package;
  final PackageScore score;
  final PackageData data;
  final double? downloadScore;
  final double? likeScore;

  const PackageDataWrapper(
    this.package,
    this.score,
    this.data, {
    this.downloadScore,
    this.likeScore,
  });

  PackageDataWrapper copyWith({
    String? package,
    PackageScore? score,
    PackageData? data,
    double? downloadScore,
    double? likeScore,
  }) {
    return PackageDataWrapper(
      package ?? this.package,
      score ?? this.score,
      data ?? this.data,
      downloadScore: downloadScore ?? this.downloadScore,
      likeScore: likeScore ?? this.likeScore,
    );
  }

  /// https://github.com/dart-lang/pub-dev/blob/6ed6450a3d13d7cf2a8def2b21932ac133b359d4/app/lib/search/mem_index.dart#L316
  double get overallScore {
    final downloadScore = this.downloadScore ?? 0;
    final likeScore = this.likeScore ?? 0;
    final popularity = (downloadScore + likeScore) / 2;

    final grantedPoints = score.grantedPoints;
    final maxPoints = score.maxPoints;

    final points = (grantedPoints ?? 0) / math.max(1, maxPoints ?? 0);

    final overall = popularity * 0.5 + points * 0.5;

    // TODO: REMOVE THIS NOW
    print(
      '$package: (download: $downloadScore, like: $likeScore, popularity: $popularity, points: $points, overall: $overall',
    );

    return overall;
  }
}
