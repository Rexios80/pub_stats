import 'dart:js_interop';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:pub_stats_collector/service/fetch_client.dart';

class FetchClientAdapter implements HttpClientAdapter {
  final _client = FetchClient();

  @override
  void close({bool force = false}) => _client.close();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bodyBytes = await requestStream?.expand((e) => e).toList();
    final response = await switch (options.method) {
      'POST' => _client.post(
          options.uri,
          body: Uint8List.fromList(bodyBytes ?? []).toJS,
          headers: options.headers.cast<String, String>(),
        ),
      _ => throw UnimplementedError(),
    };

    return ResponseBody.fromString(
      response.body,
      response.statusCode,
      headers: response.headers.map((key, value) => MapEntry(key, [value])),
    );
  }
}
