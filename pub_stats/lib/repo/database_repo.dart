import 'package:firebase_database/firebase_database.dart';
import 'package:pub_stats/model/package_count_snapshot.dart';
import 'package:pub_stats/model/package_score_snapshot.dart';
import 'package:pub_stats/model/time_span.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

class DatabaseRepo {
  final _database = FirebaseDatabase.instance.ref();

  Future<List<PackageScoreSnapshot>> getScoreSnapshots(
    String package,
    TimeSpan span,
  ) async {
    final event = await _database
        .child('stats')
        .child(package)
        .orderByKey()
        .startAt(span.start.secondsSinceEpoch.toString())
        .once();
    final snap = event.snapshot;
    if (!snap.exists) {
      return [];
    }
    final data = (snap.value as Map).cast<String, dynamic>();

    return data.entries.map((e) {
      final timestamp = int.parse(e.key);
      final score =
          MiniPackageScore.fromJson((e.value as Map).cast<String, dynamic>());
      return PackageScoreSnapshot.fromMiniPackageScore(
        timestamp: timestamp,
        score: score,
      );
    }).toList();
  }

  Future<DateTime> getFirstScan(String package) async {
    final event = await _database
        .child('stats')
        .child(package)
        .orderByKey()
        .limitToFirst(1)
        .once();

    final snap = event.snapshot;
    if (!snap.exists) {
      throw Exception('No first scan found for $package');
    }

    final data = (snap.value as Map).cast<String, dynamic>();
    final timestamp = int.parse(data.keys.first);
    return DateTimeExtension.fromSecondsSinceEpoch(timestamp);
  }

  Future<GlobalStats> getGlobalStats() async {
    final event = await _database.child('global_stats').once();
    final snap = event.snapshot;
    return GlobalStats.fromJson((snap.value as Map).cast<String, dynamic>());
  }

  Future<List<PackageCountSnapshot>> getPackageCounts(TimeSpan span) async {
    final event = await _database
        .child('package_counts')
        .orderByKey()
        .startAt(span.start.secondsSinceEpoch.toString())
        .once();
    final snap = event.snapshot;
    if (!snap.exists) {
      return [];
    }
    final data = (snap.value as Map).cast<String, dynamic>();

    return data.entries.map((e) {
      final timestamp = int.parse(e.key);
      final count = e.value as num;
      return PackageCountSnapshot(
        timestamp: DateTimeExtension.fromSecondsSinceEpoch(timestamp),
        count: count.toInt(),
      );
    }).toList();
  }

  Future<List<AlertConfig>> getAlertConfigs(String uid) async {
    final event = await _database.child('alerts').child(uid).once();
    final value = event.snapshot.value as List?;
    if (value == null) return [];

    return value
        .cast<Map<String, dynamic>>()
        .map(AlertConfig.fromJson)
        .toList();
  }

  Future<void> writeAlertConfigs(String uid, List<AlertConfig> configs) async {
    await _database
        .child('alerts')
        .child(uid)
        .set(configs.map((e) => e.toJson()).toList());
  }

  Query diffQuery(String package) {
    return _database.child('diffs').child(package).orderByKey();
  }

  Future<PackageData> getPackageData(String package) async {
    final event = await _database.child('data').child(package).once();
    final snap = event.snapshot;
    if (!snap.exists) {
      throw Exception('No data found for $package');
    }

    final data = (snap.value as Map).cast<String, dynamic>();
    return PackageData.fromJson(data);
  }
}
