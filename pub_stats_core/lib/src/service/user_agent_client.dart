import 'package:http/http.dart' as http;

class UserAgentClient extends http.BaseClient {
  final String userAgent;
  final http.Client _inner = http.Client();

  UserAgentClient(this.userAgent);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['user-agent'] = userAgent;
    return _inner.send(request);
  }
}
