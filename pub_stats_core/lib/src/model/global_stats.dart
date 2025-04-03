import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'global_stats.g.dart';

@immutable
@JsonSerializable()
class GlobalStats {
  final int packageCount;
  final String mostLikedPackage;
  final String mostDownloadedPackage;
  final String mostDependedPackage;
  final DateTime lastUpdated;

  const GlobalStats({
    required this.packageCount,
    required this.mostLikedPackage,
    required this.mostDownloadedPackage,
    required this.mostDependedPackage,
    required this.lastUpdated,
  });

  factory GlobalStats.fromJson(Map<String, dynamic> json) =>
      _$GlobalStatsFromJson(json);

  Map<String, dynamic> toJson() => _$GlobalStatsToJson(this);
}
