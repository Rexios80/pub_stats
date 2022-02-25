import 'package:pub_api_client/pub_api_client.dart';

class PubRepo {
  final _pub = PubClient(pubUrl: 'https://proxy.pubstats.dev/pub');

  Future<List<String>> getDeveloperPackages() async {
    final rexiosPublisherResponse =
        await _pub.fetchPublisherPackages('rexios.dev');
    final vrchatPublisherResponse =
        await _pub.fetchPublisherPackages('vrchat.community');

    return (rexiosPublisherResponse + vrchatPublisherResponse)
        .map((e) => e.package)
        .toList();
  }
}
