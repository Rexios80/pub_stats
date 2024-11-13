// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: document_ignores, require_trailing_commas

part of 'global_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GlobalStats _$GlobalStatsFromJson(Map<String, dynamic> json) => GlobalStats(
      packageCount: (json['packageCount'] as num).toInt(),
      mostLikedPackage: json['mostLikedPackage'] as String,
      mostPopularPackage: json['mostPopularPackage'] as String,
      mostDependedPackage: json['mostDependedPackage'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$GlobalStatsToJson(GlobalStats instance) =>
    <String, dynamic>{
      'packageCount': instance.packageCount,
      'mostLikedPackage': instance.mostLikedPackage,
      'mostPopularPackage': instance.mostPopularPackage,
      'mostDependedPackage': instance.mostDependedPackage,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };
