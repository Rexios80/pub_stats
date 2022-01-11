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

class DataController {
  static final _database = DatabaseRepo();
  static final _url = UrlRepo();
  static final _pub = PubRepo();

  final _analytics = AnalyticsRepo();
  final _logger = GetIt.I<Logger>();

  final GlobalStats globalStats;
  final List<PackageCountSnapshot> packageCounts;
  final loading = false.rx;
  final loadedStats = LoadedStats(package: '', stats: []).rx;

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

    return instance;
  }

  Future<void> fetchStats(String package) async {
    if (package.isEmpty) {
      return;
    }

    _analytics.logSearch(package);
    _url.setPackage(package);

    loading.value = true;
    final List<PackageScoreSnapshot> stats;
    try {
      stats = await _database.getScoreSnapshots(package);
    } catch (e) {
      _logger.e(e);
      FastOverlays.showSnackBar(
        SnackBar(content: Text('Unable to get stats for $package')),
      );
      loading.value = false;
      return;
    }

    loading.value = false;

    if (stats.isEmpty) {
      // If there are no stats for the submitted package, don't update the view
      FastOverlays.showSnackBar(
        SnackBar(content: Text('No stats for $package')),
      );
      return;
    }

    loadedStats.value = LoadedStats(package: package, stats: stats);
  }

  /// Reset to show global stats
  void reset() {
    loading.value = false;
    loadedStats.value = LoadedStats(package: '', stats: []);
    _url.reset();
  }
}
