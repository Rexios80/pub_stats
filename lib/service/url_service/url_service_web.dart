import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:pub_stats/service/url_service/url_service.dart';

class UrlServiceImpl extends UrlService {
  final _uriController = StreamController<Uri>.broadcast();

  UrlServiceImpl() {
    html.window.addEventListener('hashchange', (event) {
      _uriController.add(_getUri());
    });
  }

  @override
  void setPath(String path) {
    html.window.history.pushState(null, 'pubstats.dev', '#$path');
  }

  Uri _getUri() {
    final uri = Uri.parse(html.window.location.toString());
    // Convert fragmented url to a normal one so parsing is easier
    return Uri.parse('${uri.scheme}://${uri.host}${uri.fragment}');
  }

  @override
  Stream<Uri> get uri => _uriController.stream;
}
