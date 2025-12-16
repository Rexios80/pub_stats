import 'package:pub_stats_collector/repo/alert_handler.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

class TelegramRepo implements AlertHandler {
  @override
  Future<void> sendGlobalStatsAlert({
    required AlertConfig config,
    required GlobalStats stats,
    required Duration duration,
  }) {
    // TODO: implement sendGlobalStatsAlert
    throw UnimplementedError();
  }

  @override
  Future<void> sendPackageAlert({
    required String package,
    required AlertConfig config,
    required Map<PackageDataField, Diff> changes,
    required List<String> warnings,
  }) {
    // TODO: implement sendPackageAlert
    throw UnimplementedError();
  }

  @override
  Future<void> sendSystemErrorAlert({
    required AlertConfig config,
    required Object error,
  }) {
    // TODO: implement sendSystemErrorAlert
    throw UnimplementedError();
  }
}
