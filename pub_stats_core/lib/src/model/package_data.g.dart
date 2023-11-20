// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: require_trailing_commas

part of 'package_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageData _$PackageDataFromJson(Map<String, dynamic> json) => PackageData(
      publisher: json['p'] as String?,
      version: json['v'] as String,
      likeCount: json['lc'] as int,
      popularityScore: json['ps'] as int,
      isDiscontinued: json['id'] as bool,
      isUnlisted: json['iu'] as bool,
      dependents:
          (json['d'] as List<dynamic>?)?.map((e) => e as String).toSet() ??
              const {},
    );

Map<String, dynamic> _$PackageDataToJson(PackageData instance) =>
    <String, dynamic>{
      'p': instance.publisher,
      'v': instance.version,
      'lc': instance.likeCount,
      'ps': instance.popularityScore,
      'id': instance.isDiscontinued,
      'iu': instance.isUnlisted,
      'd': instance.dependents.toList(),
    };
