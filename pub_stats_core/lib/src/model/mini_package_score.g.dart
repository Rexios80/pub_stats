// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: document_ignores, require_trailing_commas

part of 'mini_package_score.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MiniPackageScore _$MiniPackageScoreFromJson(Map<String, dynamic> json) =>
    MiniPackageScore(
      likeCount: (json['l'] as num).toInt(),
      popularityScore: (json['p'] as num).toInt(),
    );

Map<String, dynamic> _$MiniPackageScoreToJson(MiniPackageScore instance) =>
    <String, dynamic>{
      'l': instance.likeCount,
      'p': instance.popularityScore,
    };
