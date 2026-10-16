import 'dart:js_interop';

import 'package:collection/collection.dart';
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

  Map<String, dynamic> packageUpdates(
    String package, {
    required PackageData data,
    MiniPackageScore? score,
    PackageDataDiff? diff,
  }) => {
    'data/$package': data.toJson(),
    // Store as hours since epoch to save space
    if (score != null)
      'stats/$package/${DateTime.timestamp().hoursSinceEpoch}': score.toJson(),
    if (diff != null)
      'diffs/$package/${DateTime.timestamp().secondsSinceEpoch}': diff.toJson(),
  };

  Future<void> update(Map<String, dynamic> updates) => Future.wait(
    updates.entries
        .slices(3000)
        .map(
          (batch) => _database.ref().update(Map.fromEntries(batch).toJS).toDart,
        ),
  );

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
