// These are valid
// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pub_stats_core/src/model/diff.dart';

part 'package_data.freezed.dart';
part 'package_data.g.dart';

@freezed
class PackageData with _$PackageData {
  const PackageData._();

  const factory PackageData({
    @JsonKey(name: 'p') String? publisher,
    @JsonKey(name: 'v') required String version,
    @JsonKey(name: 'lc') required int likeCount,
    @JsonKey(name: 'ps') required int? legacyPopularityScore,
    @JsonKey(name: 'ps2') int? popularityScore,
    @JsonKey(name: 'dc') required int? downloadCount,
    @JsonKey(name: 'id') required bool isDiscontinued,
    @JsonKey(name: 'iu') required bool isUnlisted,
    @JsonKey(name: 'iff') required bool isFlutterFavorite,
    @JsonKey(name: 'd') @Default({}) Set<String> dependents,
    @JsonKey(name: 'n') int? overallRank,
  }) = _PackageData;

  factory PackageData.fromJson(Map<String, dynamic> json) =>
      _$PackageDataFromJson(json);

  PackageDataDiff diffFrom(PackageData? before) {
    if (before == null) return {};
    return {
      PackageDataField.publisher: StringDiff(before.publisher, publisher),
      PackageDataField.version: StringDiff(before.version, version),
      PackageDataField.likeCount: StringDiff(before.likeCount, likeCount),
      PackageDataField.popularityScore:
          StringDiff(before.popularityScore, popularityScore),
      PackageDataField.downloadCount:
          StringDiff(before.downloadCount, downloadCount),
      PackageDataField.isDiscontinued:
          StringDiff(before.isDiscontinued, isDiscontinued),
      PackageDataField.isUnlisted: StringDiff(before.isUnlisted, isUnlisted),
      PackageDataField.isFlutterFavorite:
          StringDiff(before.isFlutterFavorite, isFlutterFavorite),
      PackageDataField.dependents: SetDiff(before.dependents, dependents),
    }..removeWhere((key, value) => !value.different);
  }
}

enum PackageDataField {
  publisher,
  version,
  likeCount,
  popularityScore,
  downloadCount,
  isDiscontinued,
  isUnlisted,
  isFlutterFavorite,
  dependents,

  // Extra fields not actually on the PackageData model
  pubPoints;

  Diff diffFromJson(Map<String, dynamic> json) => switch (this) {
        publisher ||
        version ||
        likeCount ||
        popularityScore ||
        downloadCount ||
        isDiscontinued ||
        isUnlisted ||
        isFlutterFavorite =>
          StringDiff.fromJson(json),
        dependents => SetDiff.fromJson(json),
        pubPoints => throw UnimplementedError(),
      };
}

typedef PackageDataDiff = Map<PackageDataField, Diff>;

extension PackageDataDiffExtension on PackageDataDiff {
  static Map<PackageDataField, Diff> fromJson(Map<String, dynamic> json) =>
      json.map(
        (k, v) {
          final field = PackageDataField.values.byName(k);
          return MapEntry(
            field,
            field.diffFromJson((v as Map).cast<String, dynamic>()),
          );
        },
      );

  Map<String, dynamic> toJson() => map((k, v) => MapEntry(k.name, v.toJson()));
}
