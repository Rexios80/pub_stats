import 'package:pub_api_client/pub_api_client.dart';

class PubRepo {
  final _pub = PubClient(pubUrl: 'https://proxy.pub-stats.dev/pub/');

  Future<List<String>> searchPackages(String query) async {
    final response = await _pub.search(query);
    return response.packages.map((e) => e.package).toList();
  }

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
