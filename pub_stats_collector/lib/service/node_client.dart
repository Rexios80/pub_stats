import 'dart:convert';
import 'dart:js_interop';

import 'package:firebase_js_interop/extensions.dart';
import 'package:firebase_js_interop/node.dart';
import 'package:http/http.dart' as http;
import 'package:pub_stats_collector/credential/credentials.dart';

class NodeClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw UnimplementedError();
  }

  JSArray<JSString> _mapRequestHeaders(Map<String, String>? headers) {
    if (headers == null) return <JSString>[].toJS;
    if (!headers.containsKey('user-agent')) {
      headers['user-agent'] = Credentials.userAgent;
    }
    headers.update(
      'accept',
      (value) => '$value, gzip, deflate',
      ifAbsent: () => 'gzip, deflate',
    );
    return headers.entries
        .expand((e) => [e.key.toJS, e.value.toJS])
        .toList()
        .toJS;
  }

  Map<String, String> _mapResponseHeaders(JSObject headers) => {
        for (final MapEntry(:key, :value) in headers.toJson().entries)
          key: value,
      };

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    final asdf = _mapRequestHeaders(headers);
    print(asdf);
    final response = await undici
        .request(
          url.toString(),
          RequestOptions(headers: asdf),
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
            headers: _mapRequestHeaders(headers),
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

final undici = require('undici') as Undici;

extension type Undici._(JSObject _) implements JSObject {
  external JSPromise<ResponseData> request(
    String url, [
    RequestOptions options,
  ]);
}

extension type RequestOptions._(JSObject _) implements JSObject {
  external factory RequestOptions({
    String method,
    JSAny? body,
    JSArray<JSString> headers,
  });
}

extension type ResponseData._(JSObject _) implements JSObject {
  external int get statusCode;
  external ResponseBody get body;
  external JSObject get headers;
}

extension type ResponseBody._(JSObject _) implements JSObject {
  external JSPromise<JSString> text();
}
