// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: document_ignores, require_trailing_commas

part of 'mini_package_score.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MiniPackageScore _$MiniPackageScoreFromJson(Map<String, dynamic> json) =>
    MiniPackageScore(
      likeCount: (json['l'] as num).toInt(),
      legacyPopularityScore: (json['p'] as num?)?.toInt(),
      popularityScore: (json['p2'] as num?)?.toInt(),
      downloadCount: (json['d'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MiniPackageScoreToJson(MiniPackageScore instance) =>
    <String, dynamic>{
      'l': instance.likeCount,
      if (instance.legacyPopularityScore case final value?) 'p': value,
      if (instance.popularityScore case final value?) 'p2': value,
      if (instance.downloadCount case final value?) 'd': value,
    };
