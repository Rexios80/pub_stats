import 'dart:js_interop';

import 'package:firebase_js_interop/admin.dart';
import 'package:firebase_js_interop/admin/database.dart';
import 'package:firebase_js_interop/extensions.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

class DatabaseRepo {
  final _database = FirebaseAdmin.database.getDatabase();

  DatabaseRepo();

  Future<Map<String, PackageData>> readPackageData() async {
    final data = await _database
        .ref()
        .child('data')
        .once(EventType.value)
        .toDart;
    final value = data.val()?.toJson();
    if (value == null) return {};
    return value.map(
      (key, value) =>
          MapEntry(key, PackageData.fromJson((value as JSAny).toJson())),
    );
  }

  Future<void> writePackageData(String package, PackageData data) {
    return _database
        .ref()
        .child('data')
        .child(package)
        .set(data.toJson().toJS)
        .toDart;
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
        .set(score.toJson().toJS)
        .toDart;
  }

  Future<void> writePackageDiff(String package, PackageDataDiff diff) {
    return _database
        .ref()
        .child('diffs')
        .child(package)
        .child(DateTime.timestamp().secondsSinceEpoch.toString())
        .set(diff.toJson().toJS)
        .toDart;
  }

  Future<void> writeGlobalStats(GlobalStats stats) async {
    await _database.ref().child('global_stats').set(stats.toJson().toJS).toDart;

    await _database
        .ref()
        .child('package_counts')
        .child(DateTime.timestamp().secondsSinceEpoch.toString())
        .set(stats.packageCount.toJS)
        .toDart;
  }

  /// Map of `uid` to their list of [AlertConfig]s
  Future<Map<String, List<AlertConfig>>> readAlertConfigs() async {
    final data = await _database
        .ref()
        .child('alerts')
        .once(EventType.value)
        .toDart;
    final value = data.val()?.toJson();
    if (value == null) return {};

    return value.map(
      (key, value) => MapEntry(
        key,
        (value as List)
            .cast<Map>()
            .map((e) => e.cast<String, dynamic>())
            .map(AlertConfig.fromJson)
            .toList(),
      ),
    );
  }
}
