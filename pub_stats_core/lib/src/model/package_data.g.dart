// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: require_trailing_commas

part of 'package_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageData _$PackageDataFromJson(Map<String, dynamic> json) => PackageData(
      likeCount: json['l'] as int,
      popularityScore: json['p'] as int,
      publisher: json['pu'] as String?,
    );

Map<String, dynamic> _$PackageDataToJson(PackageData instance) =>
    <String, dynamic>{
      'l': instance.likeCount,
      'p': instance.popularityScore,
      'pu': instance.publisher,
    };
