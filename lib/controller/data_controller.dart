import 'dart:math';

import 'package:fast_ui/fast_ui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:pub_stats/model/package_stats.dart';
import 'package:pub_stats/model/package_count_snapshot.dart';
import 'package:pub_stats/model/time_span.dart';
import 'package:pub_stats/repo/analytics_repo.dart';
import 'package:pub_stats/repo/database_repo.dart';
import 'package:pub_stats/repo/pub_repo.dart';
import 'package:pub_stats/repo/url_repo.dart';
import 'package:pub_stats_core/pub_stats_core.dart';
import 'package:collection/collection.dart';

class DataController {
  static final _database = DatabaseRepo();
  static final _url = GetIt.I<UrlRepo>();
  static final _pub = PubRepo();

  final _analytics = AnalyticsRepo();
  final _logger = GetIt.I<Logger>();

  final List<String> _packages;
  final Map<String, Set<String>> _completion;
  final _random = Random();

  final GlobalStats globalStats;
  final List<PackageCountSnapshot> packageCounts;
  final loading = false.rx;
  final loadedStats = <PackageStats>[].rx;
  final timeSpan = TimeSpan.month.rx;

  final loadingDeveloperPackageStats = false.rx;
  final developerPackageStats = <PackageStats>[].rx;

  DataController._({
    required List<String> packages,
    required Map<String, Set<String>> completion,
    required this.globalStats,
    required this.packageCounts,
  })  : _packages = packages,
        _completion = completion {
    _url.uri.listen((uri) => parsePath(uri.path));
  }

  static Future<DataController> create() async {
    final packages = await _pub.getNameCompletion();
    final completion = <String, Set<String>>{};
    for (final package in packages) {
      completion.update(
        package[0],
        (v) => v..add(package),
        ifAbsent: () => {package},
      );
    }

    final globalStats = await _database.getGlobalStats();
    final packageCounts = await _database.getPackageCounts();

    final instance = DataController._(
      packages: packages,
      completion: completion,
      globalStats: globalStats,
      packageCounts: packageCounts,
    );

    return instance;
  }

  Future<void> parsePath(String route) async {
    if (route == '/developer') {
      await fetchDeveloperPackageStats();
      return;
    }

    final match = RegExp(r'\/packages\/(.+)').firstMatch(route);
    if (match == null) return;
    final packages = match[1]!.split(',');

    clearData();

    for (final package in packages) {
      await fetchStats(package, writeUrl: false, clear: false);
    }
  }

  Iterable<String> complete(String pattern) {
    if (pattern.isEmpty) return [];

    // Names are indexed by first character for performance
    return _completion[pattern[0]]
            ?.where((e) => e.startsWith(pattern))
            // Don't return all the results
            .take(5) ??
        [];
  }

  void feelingLucky() {
    final index = _random.nextInt(_packages.length);
    final package = _packages[index];
    fetchStats(package);
  }

  Future<PackageStats> _fetchStats(String package) async {
    final stats = await _database.getScoreSnapshots(package);
    return PackageStats(package: package, stats: stats);
  }

  Future<PackageStats?> _fetchStatsForUi(String package) async {
    loading.value = true;
    final PackageStats stats;
    try {
      stats = await _fetchStats(package);
    } catch (e) {
      _logger.e(e);
      FastOverlays.showSnackBar(
        SnackBar(content: Text('Unable to get stats for $package')),
      );
      return null;
    } finally {
      loading.value = false;
    }

    if (stats.stats.isEmpty) {
      // If there are no stats for the submitted package, don't update the view
      FastOverlays.showSnackBar(
        SnackBar(content: Text('No stats for $package')),
      );
      return null;
    }

    return stats;
  }

  Future<void> fetchStats(
    String package, {
    bool writeUrl = true,
    bool clear = true,
  }) async {
    if (package.isEmpty || loadedStats.any((e) => e.package == package)) {
      // Don't load the same package twice
      _logger.d('Already loaded $package');
      return;
    }

    _analytics.logSearch(package);

    final stats = await _fetchStatsForUi(package);
    if (stats == null) return;

    developerPackageStats.clear();

    if (clear) loadedStats.clear();
    loadedStats.add(stats);

    if (!writeUrl) return;

    _url.setPackages(loadedStats.map((e) => e.package).toList());
  }

  void removeStats(String package) {
    loadedStats.removeWhere((e) => e.package == package);
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
      final packageStatsFutures = packages.map(_fetchStats);
      final packageStats = await Future.wait(packageStatsFutures);

      // Remove duplicates (there shouldn't be any but there are for some reason)
      final distinctPackageStats = {
        for (final stats in packageStats) stats.package: stats,
      }.values.toList();

      distinctPackageStats.sort(_sortStats);

      loadedStats.clear();
      developerPackageStats.replaceAll(distinctPackageStats);
    } catch (e) {
      _logger.e(e);
      FastOverlays.showSnackBar(
        const SnackBar(content: Text('Unable to get developer package stats')),
      );
    } finally {
      loadingDeveloperPackageStats.value = false;
    }
  }

  int _sortStats(PackageStats a, PackageStats b) {
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

  void clearData() {
    loading.value = false;
    loadedStats.clear();
    developerPackageStats.clear();
  }

  /// Reset to show global stats
  void reset() {
    clearData();
    _url.reset();
  }
}
