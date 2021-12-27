import 'package:fast_ui/fast_ui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:pub_stats/model/package_score_snapshot.dart';
import 'package:pub_stats/repo/database_repo.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

class DataController {
  static final _database = GetIt.I<DatabaseRepo>();
  final _logger = GetIt.I<Logger>();

  final GlobalStats globalStats;
  final loading = false.rx;
  final submittedPackageName = ''.rx;
  final loadedStats = <PackageScoreSnapshot>[].rx;

  DataController._(this.globalStats);

  static Future<DataController> create() async {
    final globalStats = await _database.getGlobalStats();
    return DataController._(globalStats);
  }

  void fetchStats(String package) async {
    loading.value = true;
    submittedPackageName.value = package;
    final List<PackageScoreSnapshot> stats;
    try {
      stats = await _database.getScoreSnapshots(package);
    } catch (e) {
      _logger.e(e);
      FastOverlays.showSnackBar(
        SnackBar(content: Text('Unable to get stats for $package')),
      );
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

    loadedStats.clear();
    loadedStats.addAll(stats);
  }
}
