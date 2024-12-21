import 'package:pub_stats_core/src/util/format_utils.dart';
import 'package:test/test.dart';

void main() {
  test('LargeNumDiff.format', () {
    expect(formatLargeNum(175), '175');
    expect(formatLargeNum(1_750), '1.75K');
    expect(formatLargeNum(1_750_000), '1.75M');
    expect(formatLargeNum(1_750_000_000), '1.75B');
    expect(formatLargeNum(1_750_000_000_000), '1.75T');
    expect(formatLargeNum(1_700_000_000), '1.7B');
    expect(formatLargeNum(12_750_000_000), '12.8B');
    expect(formatLargeNum(123_750_000_000), '124B');
    expect(formatLargeNum(1234_000_000_000_000), '1234T');
  });
}
