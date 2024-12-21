// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: document_ignores, require_trailing_commas

part of 'mini_package_score.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MiniPackageScore _$MiniPackageScoreFromJson(Map<String, dynamic> json) =>
    MiniPackageScore(
      likeCount: (json['l'] as num).toInt(),
      popularityScore: (json['p'] as num?)?.toInt(),
      popularityScore2: (json['p2'] as num?)?.toInt(),
      downloadCount: (json['d'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MiniPackageScoreToJson(MiniPackageScore instance) {
  final val = <String, dynamic>{
    'l': instance.likeCount,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('p', instance.popularityScore);
  writeNotNull('p2', instance.popularityScore2);
  writeNotNull('d', instance.downloadCount);
  return val;
}
