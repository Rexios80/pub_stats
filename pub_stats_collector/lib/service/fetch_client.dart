import 'dart:convert';
import 'dart:js_interop';

import 'package:fetch_api/fetch_api.dart';
import 'package:http/http.dart' as http;

class FetchClient extends http.BaseClient {
  final String? userAgent;

  FetchClient({this.userAgent});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw UnimplementedError();
  }

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final response = await fetch(
      url.toString(),
      FetchOptions(headers: Headers.fromMap(headers ?? {})) as RequestInit,
    );
    final text = await response.text();
    return http.Response(
      text,
      response.status,
      headers: {for (final e in response.headers.entries()) e.$1: e.$2},
    );
  }

  @override
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final response = await fetch(
      url.toString(),
      FetchOptions(
        method: 'POST',
        headers: Headers.fromMap(headers ?? {}),
        body: body as JSAny,
      ) as RequestInit,
    );
    final text = await response.text();
    return http.Response(
      text,
      response.status,
      headers: {for (final e in response.headers.entries()) e.$1: e.$2},
    );
  }
}

@anonymous
extension type FetchOptions._(JSObject _) implements JSObject {
  external factory FetchOptions({
    String? method,
    Headers? headers,
    JSAny? body,
  });
}
