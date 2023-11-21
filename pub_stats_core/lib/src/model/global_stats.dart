import 'package:json_annotation/json_annotation.dart';

part 'global_stats.g.dart';

@JsonSerializable()
class GlobalStats {
  final int packageCount;
  final String mostLikedPackage;
  final String mostPopularPackage;
  final String mostDependedPackage;
  final DateTime lastUpdated;

  GlobalStats({
    required this.packageCount,
    required this.mostLikedPackage,
    required this.mostPopularPackage,
    required this.mostDependedPackage,
    required this.lastUpdated,
  });

  factory GlobalStats.fromJson(Map<String, dynamic> json) =>
      _$GlobalStatsFromJson(json);

  Map<String, dynamic> toJson() => _$GlobalStatsToJson(this);
}
