import 'package:json_annotation/json_annotation.dart';

part 'package_data.g.dart';

@JsonSerializable()
class PackageData {
  @JsonKey(name: 'p')
  final String? publisher;

  @JsonKey(name: 'v')
  final String version;

  @JsonKey(name: 'lc')
  final int likeCount;

  @JsonKey(name: 'ps')
  final int popularityScore;

  @JsonKey(name: 'id')
  final bool isDiscontinued;

  @JsonKey(name: 'iu')
  final bool isUnlisted;

  @JsonKey(name: 'd')
  final Set<String> dependents;

  PackageData({
    required this.publisher,
    required this.version,
    required this.likeCount,
    required this.popularityScore,
    required this.isDiscontinued,
    required this.isUnlisted,
    this.dependents = const {},
  });

  factory PackageData.fromJson(Map<String, dynamic> json) =>
      _$PackageDataFromJson(json);

  Map<String, dynamic> toJson() => _$PackageDataToJson(this);
}

enum PackageDataField {
  likeCount,
  popularityScore,
  pubPoints;
}
