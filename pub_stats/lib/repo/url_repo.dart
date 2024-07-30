import 'package:pub_stats/service/url_service/url_service.dart';

class UrlRepo {
  final _url = UrlService.forPlatform();

  void setPackages(List<String> packages) {
    _url.setPath('/packages/${packages.join(',')}');
  }

  Uri get uri => _url.uri;

  Stream<Uri> get uriStream => _url.uriStream;

  void reset() {
    _url.setPath('');
  }
}
