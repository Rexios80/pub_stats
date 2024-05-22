// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: require_trailing_commas

part of 'package_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PackageDataImpl _$$PackageDataImplFromJson(Map<String, dynamic> json) =>
    _$PackageDataImpl(
      publisher: json['p'] as String?,
      version: json['v'] as String,
      likeCount: (json['lc'] as num).toInt(),
      popularityScore: (json['ps'] as num).toInt(),
      isDiscontinued: json['id'] as bool,
      isUnlisted: json['iu'] as bool,
      isFlutterFavorite: json['iff'] as bool,
      dependents:
          (json['d'] as List<dynamic>?)?.map((e) => e as String).toSet() ??
              const {},
    );

Map<String, dynamic> _$$PackageDataImplToJson(_$PackageDataImpl instance) =>
    <String, dynamic>{
      'p': instance.publisher,
      'v': instance.version,
      'lc': instance.likeCount,
      'ps': instance.popularityScore,
      'id': instance.isDiscontinued,
      'iu': instance.isUnlisted,
      'iff': instance.isFlutterFavorite,
      'd': instance.dependents.toList(),
    };
