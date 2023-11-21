import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pub_api_client/pub_api_client.dart';

part 'mini_package_score.g.dart';

/// Optimize the storage used by [PackageScore]s
@JsonSerializable()
class MiniPackageScore extends Equatable {
  /// Like count
  @JsonKey(name: 'l')
  final int likeCount;

  /// Popularity score
  @JsonKey(name: 'p')
  final int popularityScore;

  MiniPackageScore({
    required this.likeCount,
    required this.popularityScore,
  });

  factory MiniPackageScore.fromJson(Map<String, dynamic> json) =>
      _$MiniPackageScoreFromJson(json);

  Map<String, dynamic> toJson() => _$MiniPackageScoreToJson(this);

  @override
  List<Object?> get props => [likeCount, popularityScore];
}
