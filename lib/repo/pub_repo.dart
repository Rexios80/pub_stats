import 'package:pub_api_client/pub_api_client.dart';

class PubRepo {
  static const _myPublishers = [
    'rexios.dev',
    'vrchat.community',
    'iodesignteam.com',
  ];

  final _pub = PubClient(pubUrl: 'https://proxy.pubstats.dev/pub');

  Future<List<String>> getDeveloperPackages() async {
    final packageResults = <PackageResult>[];
    for (final publisher in _myPublishers) {
      final results = await _pub.fetchPublisherPackages(publisher);
      packageResults.addAll(results);
    }

    return packageResults.map((e) => e.package).toList();
  }
}
