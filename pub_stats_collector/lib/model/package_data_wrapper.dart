import 'package:pub_api_client/pub_api_client.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

class PackageDataWrapper {
  final String package;
  final PackageScore score;
  final PackageData data;

  PackageDataWrapper(this.package, this.score, this.data);

  PackageDataWrapper copyWith({
    String? package,
    PackageScore? score,
    PackageData? data,
  }) {
    return PackageDataWrapper(
      package ?? this.package,
      score ?? this.score,
      data ?? this.data,
    );
  }
}
