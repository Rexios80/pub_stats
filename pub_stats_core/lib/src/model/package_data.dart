import 'package:json_annotation/json_annotation.dart';

part 'package_data.g.dart';

@JsonSerializable()
class PackageData {
  @JsonKey(name: 'l')
  final int likeCount;

  @JsonKey(name: 'p')
  final int popularityScore;

  @JsonKey(name: 'pu')
  final String? publisher;

  PackageData({
    required this.likeCount,
    required this.popularityScore,
    required this.publisher,
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
