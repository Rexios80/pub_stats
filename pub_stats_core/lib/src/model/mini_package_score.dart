import 'package:json_annotation/json_annotation.dart';
import 'package:pub_api_client/pub_api_client.dart';

part 'mini_package_score.g.dart';

/// Optimize the storage used by [PackageScore]s
@JsonSerializable()
class MiniPackageScore {
  /// Like count
  @JsonKey(name: 'l')
  final int likeCount;

  /// Popularity score
  @JsonKey(name: 'p')
  final int popularityScore;

  MiniPackageScore(this.likeCount, this.popularityScore);

  static MiniPackageScore? fromPackageScore(PackageScore score) {
    final popularityScore = score.popularityScore;
    if (popularityScore == null) return null;
    final popularityPercent = (popularityScore * 100).round();

    return MiniPackageScore(score.likeCount, popularityPercent);
  }

  factory MiniPackageScore.fromJson(Map<String, dynamic> json) =>
      _$MiniPackageScoreFromJson(json);

  Map<String, dynamic> toJson() => _$MiniPackageScoreToJson(this);
}
