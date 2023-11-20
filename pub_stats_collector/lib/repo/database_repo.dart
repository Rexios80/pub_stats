import 'package:firebase_admin/firebase_admin.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

class DatabaseRepo {
  final Database _database;

  DatabaseRepo(this._database);

  Future<MiniPackageScore?> readLatestPackageScore(String name) async {
    final data = await _database
        .ref()
        .child('stats')
        .child(name)
        .orderByKey()
        .limitToLast(1)
        .once();
    final value = data.value as Map<String, dynamic>?;
    if (value == null) return null;
    return MiniPackageScore.fromJson(value.values.first);
  }

  Future<void> writePackageScore({
    required String name,
    required DateTime lastUpdated,
    required MiniPackageScore score,
  }) {
    return _database
        .ref()
        .child('stats')
        .child(name)
        // Store as seconds since epoch to save space
        .child(lastUpdated.secondsSinceEpoch.toString())
        .set(score.toJson());
  }

  Future<void> writeGlobalStats(GlobalStats stats) async {
    await _database.ref().child('global_stats').set(stats.toJson());

    await _database
        .ref()
        .child('package_counts')
        .child(DateTime.now().secondsSinceEpoch.toString())
        .set(stats.packageCount);
  }

  /// Map of `uid` to their list of [AlertConfig]s
  Future<Map<String, List<AlertConfig>>> readAlertConfigs() async {
    final data = await _database.ref().child('alerts').once();
    final value = data.value as Map<String, dynamic>?;
    if (value == null) return {};

    return value.map(
      (key, value) => MapEntry(
        key,
        (value as List)
            .cast<Map<String, dynamic>>()
            .map(AlertConfig.fromJson)
            .toList(),
      ),
    );
  }
}

extension on DateTime {
  int get secondsSinceEpoch => (millisecondsSinceEpoch / 1000).round();
}
