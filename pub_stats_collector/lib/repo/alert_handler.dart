import 'package:pub_stats_collector/repo/discord_repo.dart';
import 'package:pub_stats_collector/repo/telegram_repo.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

class AlertHandler {
  static final _discord = DiscordRepo();
  static final _telegram = TelegramRepo();

  static const instance = AlertHandler._();

  const AlertHandler._();

  Future<void> sendPackageAlert({
    required String package,
    required covariant AlertConfig config,
    required Map<PackageDataField, Diff> changes,
    required List<String> warnings,
  }) {
    return switch (config) {
      final DiscordAlertConfig config => _discord.sendPackageAlert(
        package: package,
        config: config,
        changes: changes,
        warnings: warnings,
      ),
      final TelegramAlertConfig config => _telegram.sendPackageAlert(
        package: package,
        config: config,
        changes: changes,
        warnings: warnings,
      ),
    };
  }

  Future<void> sendSystemErrorAlert({
    required covariant AlertConfig config,
    required Object error,
  }) {
    return switch (config) {
      final DiscordAlertConfig config => _discord.sendSystemErrorAlert(
        config: config,
        error: error,
      ),
      final TelegramAlertConfig config => _telegram.sendSystemErrorAlert(
        config: config,
        error: error,
      ),
    };
  }

  Future<void> sendGlobalStatsAlert({
    required covariant AlertConfig config,
    required GlobalStats stats,
    required Duration duration,
  }) {
    return switch (config) {
      final DiscordAlertConfig config => _discord.sendGlobalStatsAlert(
        config: config,
        stats: stats,
        duration: duration,
      ),
      final TelegramAlertConfig config => _telegram.sendGlobalStatsAlert(
        config: config,
        stats: stats,
        duration: duration,
      ),
    };
  }
}
