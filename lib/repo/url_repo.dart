import 'package:pub_stats/service/url_service/url_service.dart';

class UrlRepo {
  final _url = UrlService.forPlatform();

  void setPackages(List<String> packages) {
    _url.setPath('/packages/${packages.join(',')}');
  }

  void setDeveloperPackages() {
    _url.setPath('/developer');
  }

  Stream<Uri> get uri => _url.uri;

  void reset() {
    _url.setPath('');
  }
}
