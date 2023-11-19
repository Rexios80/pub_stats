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

  Future<Set<String>> getDeveloperPackages() async {
    return {
      ...await _pub.fetchAllPackages(PackageTag.publisher('rexios.dev')),
      ...await _pub.fetchAllPackages(PackageTag.publisher('iodesignteam.com')),
      ...await _pub.fetchAllPackages(PackageTag.publisher('vrchat.community')),
    }.map((e) => e.package).toSet();
  }
}
