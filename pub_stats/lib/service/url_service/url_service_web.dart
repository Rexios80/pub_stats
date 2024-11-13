import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

import 'package:pub_stats/service/url_service/url_service.dart';

class UrlServiceImpl extends UrlService {
  final _uriController = StreamController<Uri>.broadcast();

  UrlServiceImpl() {
    web.window.addEventListener(
      'hashchange',
      (() => _uriController.add(uri)).toJS,
    );
  }

  @override
  void setPath(String path) {
    web.window.history.pushState(null, '', path);
  }

  @override
  Uri get uri => Uri.parse(web.window.location.toString());

  @override
  Stream<Uri> get uriStream => _uriController.stream;
}
