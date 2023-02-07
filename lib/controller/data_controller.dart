import 'package:fast_ui/fast_ui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:pub_stats/model/loaded_stats.dart';
import 'package:pub_stats/model/package_count_snapshot.dart';
import 'package:pub_stats/repo/analytics_repo.dart';
import 'package:pub_stats/repo/database_repo.dart';
import 'package:pub_stats/repo/url_repo.dart';
import 'package:pub_stats_core/pub_stats_core.dart';
import 'package:collection/collection.dart';

class DataController {
  static final _database = DatabaseRepo();
  static final _url = GetIt.I<UrlRepo>();

  final _analytics = AnalyticsRepo();
  final _logger = GetIt.I<Logger>();

  final GlobalStats globalStats;
  final List<PackageCountSnapshot> packageCounts;
  final loading = false.rx;
  final loadedStats = LoadedStats.empty().rx;

  final loadingDeveloperPackageStats = false.rx;
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
    final stats = await _database.getScoreSnapshots(package);
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

    loadingDeveloperPackageStats.value = true;
    try {
      final packages = await _database.getDeveloperPackages();
      final packageStatsFutures = packages.map(_loadStats);
      final packageStats = await Future.wait(packageStatsFutures);

      // Remove duplicates (there shouldn't be any but there are for some reason)
      final distinctPackageStats = {
        for (final stats in packageStats) stats.package: stats
      }.values.toList();

      distinctPackageStats.sort(_sortStats);

      loadedStats.value = LoadedStats.empty();
      developerPackageStats.clear();
      developerPackageStats.addAll(distinctPackageStats);
    } catch (e) {
      _logger.e(e);
      FastOverlays.showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to get developer package stats. This doesn\'t like to work in non Chromium based browsers.',
          ),
        ),
      );
    } finally {
      loadingDeveloperPackageStats.value = false;
    }
  }

  int _sortStats(LoadedStats a, LoadedStats b) {
    // Sort by popularity first
    final popularityComparison = (b.stats.lastOrNull?.popularityScore ?? -1)
        .compareTo(a.stats.lastOrNull?.popularityScore ?? -1);
    if (popularityComparison != 0) {
      return popularityComparison;
    }

    // Then by like count
    final likeComparison = (b.stats.lastOrNull?.likeCount ?? -1)
        .compareTo(a.stats.lastOrNull?.likeCount ?? -1);
    if (likeComparison != 0) {
      return likeComparison;
    }

    // Then by name
    return a.package.compareTo(b.package);
  }

  /// Reset to show global stats
  void reset() {
    loading.value = false;
    loadedStats.value = LoadedStats.empty();
    developerPackageStats.clear();
    _url.reset();
  }
}
