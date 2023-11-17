import 'package:pub_stats/service/url_service/url_service.dart';
import 'package:collection/collection.dart';

class UrlRepo {
  final _url = UrlService.forPlatform();

  void setPackage(String package, {List<String> comparisons = const []}) {
    var path = 'packages/$package';
    if (comparisons.isNotEmpty) {
      path += '?compare=${comparisons.join(',')}';
    }
    _url.setPath(package, path);
  }

  String getPackage() {
    final split = _url.getUri().path.split('/').skip(1);
    if (split.firstOrNull == 'packages') {
      return split.lastOrNull ?? '';
    } else {
      return '';
    }
  }

  Map<String, String> getData() {
    return _url.getUri().queryParameters;
  }

  void setDeveloperPackages() {
    _url.setPath('Rexios\'s Packages', 'developer');
  }

  bool isDeveloperPackages() {
    return _url.getUri().path == '/developer';
  }

  void reset() {
    _url.setPath('pubstats.dev', '');
  }
}
