import 'dart:convert';
import 'dart:js_interop';

import 'package:firebase_js_interop/extensions.dart';
import 'package:http/http.dart' as http;
import 'package:pub_stats_collector/service/undici.dart';

class UndiciClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw UnimplementedError();
  }

  Map<String, String> _mapResponseHeaders(JSObject headers) => {
        for (final MapEntry(:key, :value) in headers.toJson().entries)
          key: value is List ? value.join(',') : value.toString(),
      };

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final response = await undici
        .request(
          url.toString(),
          RequestOptions(headers: (headers ?? {}).toJS),
        )
        .toDart;
    final text = await response.body.text().toDart;
    return http.Response(
      text.toDart,
      response.statusCode,
      headers: _mapResponseHeaders(response.headers),
    );
  }

  @override
  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    final response = await undici
        .request(
          url.toString(),
          RequestOptions(
            method: 'POST',
            headers: (headers ?? {}).toJS,
            body: body as JSAny,
          ),
        )
        .toDart;
    final text = await response.body.text().toDart;
    return http.Response(
      text.toDart,
      response.statusCode,
      headers: _mapResponseHeaders(response.headers),
    );
  }
}
