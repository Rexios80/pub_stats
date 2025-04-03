import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'global_stats.g.dart';

@immutable
@JsonSerializable()
class GlobalStats {
  final int packageCount;
  final String topPackage;
  final String mostLikedPackage;
  final String mostDownloadedPackage;
  final String mostDependedPackage;
  final DateTime lastUpdated;

  GlobalStats({
    this.packageCount = 0,
    this.topPackage = 'N/A',
    this.mostLikedPackage = 'N/A',
    this.mostDownloadedPackage = 'N/A',
    this.mostDependedPackage = 'N/A',
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.timestamp();

  factory GlobalStats.fromJson(Map<String, dynamic> json) =>
      _$GlobalStatsFromJson(json);

  Map<String, dynamic> toJson() => _$GlobalStatsToJson(this);
}
