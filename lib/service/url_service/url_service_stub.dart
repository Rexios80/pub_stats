import 'package:pub_stats/service/url_service/url_service.dart';

class UrlServiceImpl extends UrlService {
  @override
  void setPath(String path) {}

  @override
  Uri get uri => Uri.parse('https://pubstats.dev');

  @override
  Stream<Uri> get uriStream => const Stream.empty();
}
