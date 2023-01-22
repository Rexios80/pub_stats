import 'package:flutter_test/flutter_test.dart';
import 'package:pub_stats/repo/pub_repo.dart';

void main() {
  final pub = PubRepo();

  test('Get developer packages', () async {
    final packages = await pub.getDeveloperPackages();
    expect(packages, isNotEmpty);
  });
}
