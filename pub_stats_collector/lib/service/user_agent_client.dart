import 'dart:js_interop';

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
    final response = await fetch(url.toString()).toDart;
    final text = await response.text().toDart;
    return http.Response(text.toDart, response.status);
  }
}

@JS('fetch')
external JSPromise<Response> fetch(String resource);

extension type Response._(JSObject _) implements JSObject {
  external int get status;
  external JSPromise<JSString> text();
}
