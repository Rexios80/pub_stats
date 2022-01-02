import 'package:pub_stats/service/url_service/url_service.dart';
import 'package:collection/collection.dart';

class UrlRepo {
  final _url = UrlService.forPlatform();

  void setPackage(String package) {
    _url.setPath(package, 'packages/$package');
  }

  String getPackage() {
    final split = _url.getPath().split('/');
    if (split.firstOrNull == 'packages') {
      return split.lastOrNull ?? '';
    } else {
      return '';
    }
  }

  void reset() {
    _url.setPath('pubstats.dev', '');
  }
}
