import 'package:equatable/equatable.dart';

/// Optimize the storage used by package scores.
///
/// Wire format is a positional array:
/// `[likeCount, legacyPopularity, popularity, downloads]`.
/// Absent optionals use sentinel [-1] so Firebase RTDB keeps dense list slots.
class MiniPackageScore extends Equatable {
  static const _absent = -1;

  /// Like count
  final int likeCount;

  /// Old popularity score calculated by pub
  final int? legacyPopularityScore;

  /// New popularity score calculated by pub_stats
  final int? popularityScore;

  /// Download count
  final int? downloadCount;

  const MiniPackageScore({
    required this.likeCount,
    required this.legacyPopularityScore,
    required this.popularityScore,
    required this.downloadCount,
  });

  factory MiniPackageScore.fromJson(List<dynamic> json) {
    int? decode(Object? value) {
      final decoded = (value as num).toInt();
      if (decoded == _absent) return null;
      return decoded;
    }

    return MiniPackageScore(
      likeCount: (json[0] as num).toInt(),
      legacyPopularityScore: decode(json[1]),
      popularityScore: decode(json[2]),
      downloadCount: decode(json[3]),
    );
  }

  List<Object> toJson() => [
    likeCount,
    legacyPopularityScore ?? _absent,
    popularityScore ?? _absent,
    downloadCount ?? _absent,
  ];

  @override
  List<Object?> get props => [
    likeCount,
    legacyPopularityScore,
    popularityScore,
    downloadCount,
  ];
}
