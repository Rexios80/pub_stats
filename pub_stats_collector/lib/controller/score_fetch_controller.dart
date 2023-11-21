import 'dart:async';

import 'package:pub_api_client/pub_api_client.dart' hide Credentials;
import 'package:pub_stats_collector/credential/credentials.dart';
import 'package:pub_stats_collector/model/diff.dart';
import 'package:pub_stats_collector/repo/database_repo.dart';
import 'package:pub_stats_collector/repo/discord_repo.dart';
import 'package:pub_stats_collector/repo/pub_repo.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

class ScoreFetchController {
  final PubRepo _pub;
  final DatabaseRepo _database;
  final DiscordRepo _discord;
  final Map<String, List<AlertConfig>> _alertConfigs;
  final Map<String, PackageData> _data;

  ScoreFetchController(
    Credentials credentials,
    this._database,
    this._discord,
    this._alertConfigs,
    this._data,
  ) : _pub = PubRepo(credentials);

  Future<void> fetchScores() async {
    final startTime = DateTime.now();
    final globalStats = await _pub.fetchAllData(_handleData);

    await _database.writeGlobalStats(globalStats);
    print('Global stats:');
    print(globalStats.toJson());

    final duration = DateTime.now().difference(startTime);
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
    print('Discord handling completed');
  }

  Future<void> _handleData(PackageMetrics metrics, PackageData data) async {
    final package = metrics.scorecard.packageName;
    final miniScore = MiniPackageScore(
      likeCount: data.likeCount,
      popularityScore: data.popularityScore,
    );

    // Send alerts
    final publisher = data.publisher;
    final configs = <AlertConfig>[
      ..._alertConfigs[package] ?? [],
      if (publisher != null) ..._alertConfigs['publisher:$publisher'] ?? [],
    ];

    // Don't alert for discontinued packages
    if (!data.isDiscontinued) {
      await Future.wait(
        configs.map(
          (e) => processAlert(
            package: package,
            configs: configs,
            score: metrics.score,
            data: data,
            previousData: _data[package],
          ),
        ),
      );
    }

    await _database.writePackageScore(
      package: package,
      lastUpdated: metrics.score.lastUpdated,
      score: miniScore,
    );

    await _database.writePackageData(package, data);
  }

  Future<void> processAlert({
    required String package,
    required List<AlertConfig> configs,
    required PackageScore score,
    required PackageData data,
    required PackageData? previousData,
  }) async {
    final Map<PackageDataField, Diff> changes;
    if (previousData != null) {
      changes = {
        PackageDataField.publisher:
            StringDiff(previousData.publisher ?? '', data.publisher ?? ''),
        PackageDataField.version:
            StringDiff(previousData.version, data.version),
        PackageDataField.likeCount:
            StringDiff(previousData.likeCount, data.likeCount),
        PackageDataField.popularityScore:
            StringDiff(previousData.popularityScore, data.popularityScore),
        PackageDataField.isDiscontinued:
            StringDiff(previousData.isDiscontinued, data.isDiscontinued),
        PackageDataField.isUnlisted:
            StringDiff(previousData.isUnlisted, data.isUnlisted),
        PackageDataField.isFlutterFavorite:
            StringDiff(previousData.isFlutterFavorite, data.isFlutterFavorite),
        PackageDataField.dependents:
            SetDiff(previousData.dependents, data.dependents),
      }..removeWhere((key, value) => !value.different);
    } else {
      changes = {};
    }

    final warnings = <PackageDataField, String>{};
    final grantedPoints = score.grantedPoints;
    final maxPoints = score.maxPoints;
    if (grantedPoints != null &&
        maxPoints != null &&
        grantedPoints < maxPoints) {
      warnings[PackageDataField.pubPoints] =
          'Only $grantedPoints/$maxPoints pub points';
    }

    if (changes.isEmpty && warnings.isEmpty) return;

    for (final config in configs) {
      final filteredChanges = Map.fromEntries(
        changes.entries.where((e) => !config.ignore.contains(e.key)),
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
