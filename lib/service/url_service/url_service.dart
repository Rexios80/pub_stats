import 'package:pub_stats/service/url_service/url_service_stub.dart'
    if (dart.library.js) 'package:pub_stats/service/url_service/url_service_web.dart';

abstract class UrlService {
  void setPath(String path);
  Stream<Uri> get uri;

  const UrlService();

  factory UrlService.forPlatform() {
    return UrlServiceImpl();
  }
}
