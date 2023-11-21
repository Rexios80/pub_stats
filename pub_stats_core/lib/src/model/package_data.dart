// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'package_data.freezed.dart';
part 'package_data.g.dart';

@freezed
class PackageData with _$PackageData {
  const factory PackageData({
    @JsonKey(name: 'p') String? publisher,
    @JsonKey(name: 'v') required String version,
    @JsonKey(name: 'lc') required int likeCount,
    @JsonKey(name: 'ps') required int popularityScore,
    @JsonKey(name: 'id') required bool isDiscontinued,
    @JsonKey(name: 'iu') required bool isUnlisted,
    @JsonKey(name: 'iff') required bool isFlutterFavorite,
    @JsonKey(name: 'd') @Default({}) Set<String> dependents,
  }) = _PackageData;

  factory PackageData.fromJson(Map<String, dynamic> json) =>
      _$PackageDataFromJson(json);
}

enum PackageDataField {
  publisher,
  version,
  likeCount,
  popularityScore,
  isDiscontinued,
  isUnlisted,
  dependents,

  // Extra fields not actually on the PackageData model
  pubPoints,
}
