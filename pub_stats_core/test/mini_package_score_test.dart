import 'package:pub_stats_core/pub_stats_core.dart';
import 'package:test/test.dart';

void main() {
  group('MiniPackageScore', () {
    test('encodes absent optionals as -1', () {
      const score = MiniPackageScore(
        likeCount: 10,
        legacyPopularityScore: null,
        popularityScore: 50,
        downloadCount: null,
      );

      expect(score.toJson(), [10, -1, 50, -1]);
    });

    test('decodes -1 as null', () {
      final score = MiniPackageScore.fromJson([10, -1, 50, -1]);

      expect(score.likeCount, 10);
      expect(score.legacyPopularityScore, isNull);
      expect(score.popularityScore, 50);
      expect(score.downloadCount, isNull);
    });

    test('round-trips all fields', () {
      const score = MiniPackageScore(
        likeCount: 100,
        legacyPopularityScore: 80,
        popularityScore: 90,
        downloadCount: 12345,
      );

      expect(MiniPackageScore.fromJson(score.toJson()), score);
    });
  });

  group('DateTimeExtension hoursSinceEpoch', () {
    test('round-trips', () {
      final original = DateTime.utc(2024, 6, 15, 12);
      final hours = original.hoursSinceEpoch;
      final restored = DateTimeExtension.fromHoursSinceEpoch(hours);

      expect(restored.millisecondsSinceEpoch, original.millisecondsSinceEpoch);
    });
  });
}
