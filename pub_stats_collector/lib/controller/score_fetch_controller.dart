import 'dart:async';

import 'package:pub_api_client/pub_api_client.dart' hide Credentials;
import 'package:pub_stats_collector/repo/database_repo.dart';
import 'package:pub_stats_collector/repo/discord_repo.dart';
import 'package:pub_stats_collector/repo/pub_repo.dart';
import 'package:pub_stats_core/pub_stats_core.dart';
import 'package:meta/meta.dart';

@immutable
class ScoreFetchController {
  final _pub = PubRepo();
  final DatabaseRepo _database;
  final DiscordRepo _discord;
  final Map<String, List<AlertConfig>> _alertConfigs;
  final Map<String, PackageData> _data;

  ScoreFetchController(
    this._database,
    this._discord,
    this._alertConfigs,
    this._data,
  );

  Future<void> fetchScores() async {
    final startTime = DateTime.timestamp();
    final globalStats = await _pub.fetchAllData(_handleData);

    await _database.writeGlobalStats(globalStats);
    print('Global stats:');
    print(globalStats.toJson());

    final duration = DateTime.timestamp().difference(startTime);
    print('Package processing completed in ${duration.inSeconds} seconds');

    for (final config in _alertConfigs['.system'] ?? <AlertConfig>[]) {
      await switch (config.type) {
        AlertConfigType.discord => _discord.sendGlobalStatsAlert(
          config: config as DiscordAlertConfig,
          stats: globalStats,
          duration: duration,
        ),
      };
    }
    print('System alerts sent');
  }

  Future<void> _handleData(
    String package,
    PackageScore score,
    PackageData data,
    Set<String> failedPackages,
  ) async {
    final miniScore = MiniPackageScore(
      likeCount: data.likeCount,
      legacyPopularityScore: data.legacyPopularityScore,
      popularityScore: data.popularityScore,
      downloadCount: data.downloadCount,
    );

    // Send alerts
    final publisher = data.publisher;
    final configs = <AlertConfig>[
      ..._alertConfigs[package] ?? [],
      if (publisher != null) ..._alertConfigs['publisher:$publisher'] ?? [],
    ];

    final previousData = _data[package];
    final diff = data.diffFrom(previousData, failedPackages: failedPackages);

    // Don't alert for discontinued packages
    if (!data.isDiscontinued) {
      await Future.wait(
        configs.map(
          (e) => processAlert(
            package: package,
            configs: configs,
            score: score,
            diff: diff,
          ),
        ),
      );
    }

    // Don't track diffs for items that have historical data
    final filteredDiff = Map.fromEntries(
      diff.entries.where((e) => e.key.trackDiff),
    );

    await Future.wait([
      _database.writePackageScore(
        package: package,
        lastUpdated: score.lastUpdated,
        score: miniScore,
      ),
      _database.writePackageData(package, data),
      if (filteredDiff.isNotEmpty)
        _database.writePackageDiff(package, filteredDiff),
    ]);
  }

  Future<void> processAlert({
    required String package,
    required List<AlertConfig> configs,
    required PackageScore score,
    required PackageDataDiff diff,
  }) async {
    final warnings = <PackageDataField, String>{};
    final grantedPoints = score.grantedPoints;
    final maxPoints = score.maxPoints;
    if (grantedPoints != null &&
        maxPoints != null &&
        grantedPoints < maxPoints) {
      warnings[PackageDataField.pubPoints] =
          'Only $grantedPoints/$maxPoints pub points';
    }

    if (diff.isEmpty && warnings.isEmpty) return;

    for (final config in configs) {
      final filteredChanges = Map.fromEntries(
        diff.entries.where((e) => !config.ignore.contains(e.key)),
      );
      final filteredWarnings = Map.fromEntries(
        warnings.entries.where((e) => !config.ignore.contains(e.key)),
      );

      if (filteredChanges.isEmpty && filteredWarnings.isEmpty) continue;

      await switch (config.type) {
        AlertConfigType.discord => _discord.sendPackageAlert(
          package: package,
          config: config as DiscordAlertConfig,
          changes: filteredChanges,
          warnings: filteredWarnings.values.toList(),
        ),
      };
    }
  }
}
