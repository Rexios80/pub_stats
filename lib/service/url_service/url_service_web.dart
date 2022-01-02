// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:pub_stats/service/url_service/url_service.dart';

class UrlServiceImpl extends UrlService {
  @override
  void setPath(String title, String path) {
    html.window.history.pushState(null, title, '#/$path');
  }

  @override
  String getPath() {
    final path = html.window.location.hash;
    return path.replaceFirst('#/', '');
  }
}
