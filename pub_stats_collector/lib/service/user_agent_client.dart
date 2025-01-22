import 'package:fetch_api/fetch_api.dart';
import 'package:http/http.dart' as http;

class UserAgentClient extends http.BaseClient {
  final String userAgent;

  UserAgentClient(this.userAgent);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final response = await fetch(url.toString());
    final text = await response.text();
    return http.Response(
      text,
      response.status,
      headers: {for (final e in response.headers.entries()) e.$1: e.$2},
    );
  }
}
