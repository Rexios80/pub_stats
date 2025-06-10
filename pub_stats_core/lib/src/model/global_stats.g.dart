// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: document_ignores, require_trailing_commas, use_null_aware_elements

part of 'global_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GlobalStats _$GlobalStatsFromJson(Map<String, dynamic> json) => GlobalStats(
  packageCount: (json['packageCount'] as num?)?.toInt() ?? 0,
  topPackage: json['topPackage'] as String? ?? 'N/A',
  mostLikedPackage: json['mostLikedPackage'] as String? ?? 'N/A',
  mostDownloadedPackage: json['mostDownloadedPackage'] as String? ?? 'N/A',
  mostDependedPackage: json['mostDependedPackage'] as String? ?? 'N/A',
  lastUpdated: json['lastUpdated'] == null
      ? null
      : DateTime.parse(json['lastUpdated'] as String),
);

Map<String, dynamic> _$GlobalStatsToJson(GlobalStats instance) =>
    <String, dynamic>{
      'packageCount': instance.packageCount,
      'topPackage': instance.topPackage,
      'mostLikedPackage': instance.mostLikedPackage,
      'mostDownloadedPackage': instance.mostDownloadedPackage,
      'mostDependedPackage': instance.mostDependedPackage,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };
