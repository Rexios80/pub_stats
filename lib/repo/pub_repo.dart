import 'package:pub_api_client/pub_api_client.dart';
import 'package:pub_stats/constant/constants.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

class PubService {
  final _client = PubClient(client: UserAgentClient(Constants.userAgent));

  Future<List<String>> searchPackages(String query) async {
    final response = await _client.search(query);
    return response.packages.map((result) => result.package).toList();
  }
}
