import 'dart:math';

import 'package:fast_ui/fast_ui.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:pub_stats/constant/app_colors.dart';
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

  static const _defaultTimeSpan = TimeSpan.month;

  final _analytics = AnalyticsRepo();
  final _logger = GetIt.I<Logger>();

  final List<String> _packages;
  final Map<String, Set<String>> _completion;
  final _random = Random();

  final GlobalStats globalStats;
  final RxList<PackageCountSnapshot> packageCounts;
  final loading = false.rx;
  final loadedStats = <PackageStats>[].rx;
  final timeSpan = _defaultTimeSpan.rx;

  final loadingDeveloperPackageStats = false.rx;
  final developerPackageStats = <PackageStats>[].rx;

  DataController._({
    required List<String> packages,
    required Map<String, Set<String>> completion,
    required this.globalStats,
    required List<PackageCountSnapshot> packageCounts,
  })  : _packages = packages,
        _completion = completion,
        packageCounts = packageCounts.rx {
    _url.uriStream.listen((uri) => _parsePath(uri.path));
    timeSpan.stream.listen((_) => _handleTimeSpanChange());
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
    final packageCounts = await _database.getPackageCounts(_defaultTimeSpan);

    final instance = DataController._(
      packages: packages,
      completion: completion,
      globalStats: globalStats,
      packageCounts: packageCounts,
    );

    await instance._parsePath(_url.uri.path);

    return instance;
  }

  Future<void> _parsePath(String path) async {
    if (path == '/developer') {
      await fetchDeveloperPackageStats();
      return;
    }

    developerPackageStats.clear();

    final match = RegExp(r'\/packages\/(.+)').firstMatch(path);
    if (match == null) return;
    final pathPackages = match[1]!.split(',').toSet();

    final currentPackages = loadedStats.map((e) => e.package).toSet();
    final newPackages = pathPackages.difference(currentPackages);
    final removedPackages = currentPackages.difference(pathPackages);

    for (final package in newPackages) {
      await fetchStats(package, writeUrl: false, clear: false);
    }

    for (final package in removedPackages) {
      removeStats(package, writeUrl: false);
    }
  }

  Iterable<String> complete(String pattern) {
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
    final stats = await _database.getScoreSnapshots(package, timeSpan.value);
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

  void _setPathPackages() {
    _url.setPackages(loadedStats.map((e) => e.package).toList());
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

    if (loadedStats.length == AppColors.chartLineColors.length) {
      // Can't compare more packages
      FastOverlays.showSnackBar(
        const SnackBar(content: Text('Cannot add more packages to compare')),
      );
      return;
    }

    _analytics.logSearch(package);

    final stats = await _fetchStatsForUi(package);
    if (stats == null) return;

    developerPackageStats.clear();

    if (clear) loadedStats.clear();
    loadedStats.add(stats);

    if (!writeUrl) return;
    _setPathPackages();
  }

  void removeStats(String package, {bool writeUrl = true}) {
    loadedStats.removeWhere((e) => e.package == package);

    if (!writeUrl) return;
    _setPathPackages();
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
      final packages = await _pub.getDeveloperPackages();
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

  /// Reset to show global stats
  void reset() {
    loading.value = false;
    loadedStats.clear();
    developerPackageStats.clear();

    _url.reset();
  }

  Query diffQuery(String package) {
    return _database.diffQuery(package);
  }

  Future<void> _handleTimeSpanChange() async {
    final packageCounts = await _database.getPackageCounts(timeSpan.value);
    this.packageCounts.replaceAll(packageCounts);

    final newStats = <PackageStats>[];
    for (final stats in loadedStats) {
      final newStatsForPackage = await _fetchStats(stats.package);
      newStats.add(newStatsForPackage);
    }

    loadedStats.replaceAll(newStats);
  }
}
