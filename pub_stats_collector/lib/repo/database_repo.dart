import 'package:firebase_admin/firebase_admin.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

class DatabaseRepo {
  final Database _database;

  DatabaseRepo(this._database);

  Future<Map<String, PackageData>> readPackageData() async {
    final data = await _database.ref().child('data').once();
    final value = data.value as Map<String, dynamic>?;
    if (value == null) return {};
    return value
        .map((key, value) => MapEntry(key, PackageData.fromJson(value)));
  }

  Future<void> writePackageData(String package, PackageData data) {
    return _database.ref().child('data').child(package).set(data.toJson());
  }

  Future<void> writePackageScore({
    required String package,
    required DateTime lastUpdated,
    required MiniPackageScore score,
  }) {
    return _database
        .ref()
        .child('stats')
        .child(package)
        // Store as seconds since epoch to save space
        .child(lastUpdated.secondsSinceEpoch.toString())
        .set(score.toJson());
  }

  Future<void> writePackageDiff(String package, PackageDataDiff diff) {
    return _database
        .ref()
        .child('diffs')
        .child(package)
        .child(DateTime.timestamp().secondsSinceEpoch.toString())
        .set(diff.toJson());
  }

  Future<void> writeGlobalStats(GlobalStats stats) async {
    await _database.ref().child('global_stats').set(stats.toJson());

    await _database
        .ref()
        .child('package_counts')
        .child(DateTime.timestamp().secondsSinceEpoch.toString())
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
