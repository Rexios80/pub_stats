import 'package:pub_api_client/pub_api_client.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

class PackageDataWrapper {
  final PackageMetrics metrics;
  final PackageData data;

  PackageDataWrapper(this.metrics, this.data);
}
