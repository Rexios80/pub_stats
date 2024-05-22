import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

import 'package:pub_stats/service/url_service/url_service.dart';

class UrlServiceImpl extends UrlService {
  final _uriController = StreamController<Uri>.broadcast();

  UrlServiceImpl() {
    web.window.addEventListener(
      'hashchange',
      ((event) => _uriController.add(uri)).toJS,
    );
  }

  @override
  void setPath(String path) {
    web.window.history.pushState(null, 'pubstats.dev', '#$path');
  }

  @override
  Uri get uri {
    final uri = Uri.parse(web.window.location.toString());
    // Convert fragmented url to a normal one so parsing is easier
    return Uri.parse('${uri.scheme}://${uri.host}${uri.fragment}');
  }

  @override
  Stream<Uri> get uriStream => _uriController.stream;
}
