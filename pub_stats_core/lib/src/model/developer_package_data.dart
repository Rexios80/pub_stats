import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:pub_api_client/pub_api_client.dart';

part 'developer_package_data.g.dart';

@JsonSerializable(constructor: '_')
class DeveloperPackageData extends Equatable {
  final String version;
  final int likeCount;
  final double popularityScore;
  final int grantedPoints;
  final int maxPoints;
  final bool isDiscontinued;
  final bool isUnlisted;

  DeveloperPackageData._({
    required this.version,
    required this.likeCount,
    required this.popularityScore,
    required this.grantedPoints,
    required this.maxPoints,
    this.isDiscontinued = false,
    this.isUnlisted = false,
  });

  static DeveloperPackageData? fromPub(
    PubPackage info,
    PackageOptions options,
    PackageScore score,
  ) {
    final popularityScore = score.popularityScore;
    final grantedPoints = score.grantedPoints;
    final maxPoints = score.maxPoints;

    if (popularityScore == null || grantedPoints == null || maxPoints == null) {
      return null;
    }

    return DeveloperPackageData._(
      version: info.latest.version,
      likeCount: score.likeCount,
      popularityScore: popularityScore,
      grantedPoints: grantedPoints,
      maxPoints: maxPoints,
      isDiscontinued: options.isDiscontinued,
      isUnlisted: options.isUnlisted,
    );
  }

  factory DeveloperPackageData.fromJson(Map<String, dynamic> json) =>
      _$DeveloperPackageDataFromJson(json);

  Map<String, dynamic> toJson() => _$DeveloperPackageDataToJson(this);

  @override
  List<Object?> get props => [
        version,
        likeCount,
        popularityScore,
        grantedPoints,
        maxPoints,
        isDiscontinued,
        isUnlisted,
      ];

  DeveloperPackageDiff diff(DeveloperPackageData update) {
    return DeveloperPackageDiff(
      versionChange: stringDiff(version, update.version),
      likeCountChange: stringDiff(likeCount, update.likeCount),
      popularityScoreChange: popularityScoreDiff(update.popularityScore),
      grantedPointsChange: stringDiff(grantedPoints, update.grantedPoints),
      maxPointsChange: stringDiff(maxPoints, update.maxPoints),
      isDiscontinuedChange: stringDiff(isDiscontinued, update.isDiscontinued),
      isUnlistedChange: stringDiff(isUnlisted, update.isUnlisted),
      warnings: update.generateWarnings(),
    );
  }

  String? stringDiff(Object current, Object update) {
    if (current.toString() != update.toString()) {
      return '$current -> $update';
    }
    return null;
  }

  String? popularityScoreDiff(double update) {
    if (popularityScore == update) {
      return null;
    }

    var diffString = '';

    final rounded = (popularityScore * 100).round();
    final roundedUpdate = (update * 100).round();
    if (rounded != roundedUpdate) {
      diffString += '$rounded -> $roundedUpdate';
    } else {
      diffString += '$rounded';
    }

    final diff = (update - popularityScore) * 100;
    if (diff > 0) {
      diffString += ' (+$diff)';
    } else if (diff < 0) {
      diffString += ' ($diff)';
    }

    return diffString;
  }

  List<String> generateWarnings() {
    if (isDiscontinued) return [];

    final warnings = <String>[];
    if (grantedPoints != maxPoints) {
      warnings.add('Missing pub points');
    }
    return warnings;
  }
}

class DeveloperPackageDiff {
  final String? versionChange;
  final String? likeCountChange;
  final String? popularityScoreChange;
  final String? grantedPointsChange;
  final String? maxPointsChange;
  final String? isDiscontinuedChange;
  final String? isUnlistedChange;
  final List<String> warnings;

  DeveloperPackageDiff({
    this.versionChange,
    this.likeCountChange,
    this.popularityScoreChange,
    this.grantedPointsChange,
    this.maxPointsChange,
    this.isDiscontinuedChange,
    this.isUnlistedChange,
    required this.warnings,
  });

  DeveloperPackageDiff.fromDeveloperPackageData(DeveloperPackageData data)
      : versionChange = data.version,
        likeCountChange = data.likeCount.toString(),
        popularityScoreChange = data.popularityScore.toString(),
        grantedPointsChange = data.grantedPoints.toString(),
        maxPointsChange = data.maxPoints.toString(),
        isDiscontinuedChange = data.isDiscontinued.toString(),
        isUnlistedChange = data.isUnlisted.toString(),
        warnings = data.generateWarnings();

  bool get significant =>
      versionChange != null ||
      likeCountChange != null ||
      (popularityScoreChange != null &&
          popularityScoreChange!.contains('->')) ||
      grantedPointsChange != null ||
      maxPointsChange != null ||
      isDiscontinuedChange != null ||
      isUnlistedChange != null ||
      warnings.isNotEmpty;
}
