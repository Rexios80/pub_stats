// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: require_trailing_commas

part of 'global_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GlobalStats _$GlobalStatsFromJson(Map<String, dynamic> json) => GlobalStats(
      packageCount: json['packageCount'] as int,
      mostLikedPackage: json['mostLikedPackage'] as String,
      mostPopularPackage: json['mostPopularPackage'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$GlobalStatsToJson(GlobalStats instance) =>
    <String, dynamic>{
      'packageCount': instance.packageCount,
      'mostLikedPackage': instance.mostLikedPackage,
      'mostPopularPackage': instance.mostPopularPackage,
      'lastUpdated': instance.lastUpdated.toIso8601String(),
    };
