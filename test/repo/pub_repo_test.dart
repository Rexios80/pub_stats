import 'package:flutter_test/flutter_test.dart';
import 'package:pub_stats/repo/pub_repo.dart';

void main() {
  final _pub = PubRepo();

  test('Get developer packages', () async {
    final packages = await _pub.getDeveloperPackages();
    expect(packages, isNotEmpty);
  });
}
