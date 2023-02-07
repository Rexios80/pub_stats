import 'package:pub_api_client/pub_api_client.dart';

class PubRepo {
  final _pub = PubClient(pubUrl: 'https://proxy.pubstats.dev/pub');

  Future<List<String>> getNameCompletion() {
    return _pub.packageNameCompletion();
  }
}
