import 'package:pub_stats_core/src/model/diff.dart';
import 'package:test/test.dart';

void main() {
  test('LargeNumDiff.format', () {
    expect(LargeNumDiff.format(175), '175');
    expect(LargeNumDiff.format(1_750), '1.75K');
    expect(LargeNumDiff.format(1_750_000), '1.75M');
    expect(LargeNumDiff.format(1_750_000_000), '1.75B');
    expect(LargeNumDiff.format(1_750_000_000_000), '1.75T');
    expect(LargeNumDiff.format(1_700_000_000), '1.7B');
  });
}
