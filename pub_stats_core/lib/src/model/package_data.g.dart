// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: document_ignores, require_trailing_commas

part of 'package_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PackageData _$PackageDataFromJson(Map<String, dynamic> json) => _PackageData(
  publisher: json['p'] as String?,
  version: json['v'] as String,
  likeCount: (json['lc'] as num).toInt(),
  legacyPopularityScore: (json['ps'] as num?)?.toInt(),
  popularityScore: (json['ps2'] as num?)?.toInt(),
  downloadCount: (json['dc'] as num?)?.toInt(),
  isDiscontinued: json['id'] as bool,
  isUnlisted: json['iu'] as bool,
  isFlutterFavorite: json['iff'] as bool,
  dependents:
      (json['d'] as List<dynamic>?)?.map((e) => e as String).toSet() ??
      const {},
  overallRank: (json['n'] as num?)?.toInt(),
  numDependents: (json['nd'] as num?)?.toInt(),
);

Map<String, dynamic> _$PackageDataToJson(_PackageData instance) =>
    <String, dynamic>{
      'p': instance.publisher,
      'v': instance.version,
      'lc': instance.likeCount,
      'ps': instance.legacyPopularityScore,
      'ps2': instance.popularityScore,
      'dc': instance.downloadCount,
      'id': instance.isDiscontinued,
      'iu': instance.isUnlisted,
      'iff': instance.isFlutterFavorite,
      'd': instance.dependents.toList(),
      'n': instance.overallRank,
      'nd': instance.numDependents,
    };
