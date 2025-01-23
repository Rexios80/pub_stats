import 'dart:js_interop';

import 'package:firebase_js_interop/node.dart';

final undici = require('undici') as Undici;

extension type Undici._(JSObject _) implements JSObject {
  external JSPromise<ResponseData> request(
    String url, [
    RequestOptions options,
  ]);

  external JSPromise<ResponseData> fetch(
    String url, [
    RequestOptions options,
  ]);
}

extension type RequestOptions._(JSObject _) implements JSObject {
  external factory RequestOptions({
    String method,
    JSAny? body,
    JSObject headers,
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
