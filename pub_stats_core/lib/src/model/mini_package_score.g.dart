// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: require_trailing_commas

part of 'mini_package_score.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MiniPackageScore _$MiniPackageScoreFromJson(Map<String, dynamic> json) =>
    MiniPackageScore(
      json['l'] as int,
      json['p'] as int,
    );

Map<String, dynamic> _$MiniPackageScoreToJson(MiniPackageScore instance) =>
    <String, dynamic>{
      'l': instance.likeCount,
      'p': instance.popularityScore,
    };
