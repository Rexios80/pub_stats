import 'package:pub_api_client/pub_api_client.dart';

class PubRepo {
  final _pub = PubClient(pubUrl: 'https://proxy.pubstats.dev/pub');

  Future<List<String>> getNameCompletion() {
    return _pub.packageNameCompletion();
  }

  Future<bool> packageExists(String name) async {
    try {
      await _pub.packageInfo(name);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> publisherExists(String name) async {
    final results = await _pub.search(PackageTag.publisher(name));
    return results.packages.isNotEmpty;
  }
}
