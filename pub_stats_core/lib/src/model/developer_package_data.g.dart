// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: require_trailing_commas

part of 'developer_package_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeveloperPackageData _$DeveloperPackageDataFromJson(
        Map<String, dynamic> json) =>
    DeveloperPackageData._(
      version: json['version'] as String,
      likeCount: json['likeCount'] as int,
      popularityScore: (json['popularityScore'] as num).toDouble(),
      grantedPoints: json['grantedPoints'] as int,
      maxPoints: json['maxPoints'] as int,
      isDiscontinued: json['isDiscontinued'] as bool? ?? false,
      isUnlisted: json['isUnlisted'] as bool? ?? false,
    );

Map<String, dynamic> _$DeveloperPackageDataToJson(
        DeveloperPackageData instance) =>
    <String, dynamic>{
      'version': instance.version,
      'likeCount': instance.likeCount,
      'popularityScore': instance.popularityScore,
      'grantedPoints': instance.grantedPoints,
      'maxPoints': instance.maxPoints,
      'isDiscontinued': instance.isDiscontinued,
      'isUnlisted': instance.isUnlisted,
    };
