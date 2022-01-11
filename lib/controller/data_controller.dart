import 'package:fast_ui/fast_ui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:pub_stats/model/loaded_stats.dart';
import 'package:pub_stats/model/package_count_snapshot.dart';
import 'package:pub_stats/model/package_score_snapshot.dart';
import 'package:pub_stats/repo/analytics_repo.dart';
import 'package:pub_stats/repo/database_repo.dart';
import 'package:pub_stats/repo/pub_repo.dart';
import 'package:pub_stats/repo/url_repo.dart';
import 'package:pub_stats_core/pub_stats_core.dart';
import 'package:collection/collection.dart';

class DataController {
  static final _database = DatabaseRepo();
  static final _url = UrlRepo();
  static final _pub = PubRepo();

  final _analytics = AnalyticsRepo();
  final _logger = GetIt.I<Logger>();

  final GlobalStats globalStats;
  final List<PackageCountSnapshot> packageCounts;
  final loading = false.rx;
  final loadedStats = LoadedStats.empty().rx;
  final developerPackageStats = <LoadedStats>[].rx;

  DataController._({
    required this.globalStats,
    required this.packageCounts,
  });

  static Future<DataController> create() async {
    final globalStats = await _database.getGlobalStats();
    final packageCounts = await _database.getPackageCounts();
    final pathPackage = _url.getPackage();

    final instance = DataController._(
      globalStats: globalStats,
      packageCounts: packageCounts,
    );
    await instance.fetchStats(pathPackage);

    if (_url.isDeveloperPackages()) {
      await instance.fetchDeveloperPackageStats();
    }

    return instance;
  }

  Future<LoadedStats> _loadStats(String package) async {
    final List<PackageScoreSnapshot> stats =
        await _database.getScoreSnapshots(package);
    return LoadedStats(package: package, stats: stats);
  }

  Future<void> fetchStats(String package) async {
    if (package.isEmpty || loadedStats.value.package == package) {
      // Don't load the same package twice
      _logger.d('Already loaded $package');
      return;
    }

    _analytics.logSearch(package);
    _url.setPackage(package);

    loading.value = true;
    final LoadedStats stats;
    try {
      stats = await _loadStats(package);
    } catch (e) {
      _logger.e(e);
      FastOverlays.showSnackBar(
        SnackBar(content: Text('Unable to get stats for $package')),
      );
      loading.value = false;
      return;
    }

    loading.value = false;

    if (stats.stats.isEmpty) {
      // If there are no stats for the submitted package, don't update the view
      FastOverlays.showSnackBar(
        SnackBar(content: Text('No stats for $package')),
      );
      return;
    }

    developerPackageStats.clear();
    loadedStats.value = stats;
  }

  Future<void> fetchDeveloperPackageStats() async {
    if (developerPackageStats.isNotEmpty) {
      // Don't fetch if we already have the stats
      _logger.d('Already loaded developer stats');
      return;
    }

    _url.setDeveloperPackages();

    try {
      final developerPackages = await _pub.getDeveloperPackages();
      final developerPackageStatsFutures = developerPackages.map(_loadStats);
      final developerPackageStats =
          await Future.wait(developerPackageStatsFutures);

      // Sort by popularity score
      developerPackageStats.sort(
        (a, b) => (b.stats.lastOrNull?.popularityScore ?? -1)
            .compareTo(a.stats.lastOrNull?.popularityScore ?? -1),
      );

      loadedStats.value = LoadedStats.empty();
      this.developerPackageStats.clear();
      this.developerPackageStats.addAll(developerPackageStats);
    } catch (e) {
      _logger.e(e);
      FastOverlays.showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to get developer package stats. This doesn\'t like to work in non Chromium based browsers.',
          ),
        ),
      );
    }
  }

  /// Reset to show global stats
  void reset() {
    loading.value = false;
    loadedStats.value = LoadedStats.empty();
    developerPackageStats.clear();
    _url.reset();
  }
}
