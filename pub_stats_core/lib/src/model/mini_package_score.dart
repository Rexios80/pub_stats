import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pub_api_client/pub_api_client.dart';

part 'mini_package_score.g.dart';

/// Optimize the storage used by [PackageScore]s
@JsonSerializable(includeIfNull: false)
class MiniPackageScore extends Equatable {
  /// Like count
  @JsonKey(name: 'l')
  final int likeCount;

  /// Old popularity score calculated by pub
  @JsonKey(name: 'p')
  final int? legacyPopularityScore;

  /// New popularity score calculated by pub_stats
  @JsonKey(name: 'p2')
  final int? popularityScore;

  /// Download count
  @JsonKey(name: 'd')
  final int? downloadCount;

  const MiniPackageScore({
    required this.likeCount,
    required this.legacyPopularityScore,
    required this.popularityScore,
    required this.downloadCount,
  });

  factory MiniPackageScore.fromJson(Map<String, dynamic> json) =>
      _$MiniPackageScoreFromJson(json);

  Map<String, dynamic> toJson() => _$MiniPackageScoreToJson(this);

  @override
  List<Object?> get props => [
    likeCount,
    legacyPopularityScore,
    popularityScore,
    downloadCount,
  ];
}
