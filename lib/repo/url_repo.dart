import 'package:pub_stats/service/url_service/url_service.dart';

class UrlRepo {
  final _url = UrlService.forPlatform();

  void set(String path) {
    _url.setPath(path);
  }

  void setPackages(List<String> packages) {
    _url.setPath('/packages/${packages.join(',')}');
  }

  void setDeveloperPackages() {
    _url.setPath('/developer');
  }

  void reset() {
    _url.setPath('');
  }
}
