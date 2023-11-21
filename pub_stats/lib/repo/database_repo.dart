import 'package:firebase_database/firebase_database.dart';
import 'package:pub_stats/model/package_count_snapshot.dart';
import 'package:pub_stats/model/package_score_snapshot.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

class DatabaseRepo {
  final _database = FirebaseDatabase.instance.ref();

  Future<List<PackageScoreSnapshot>> getScoreSnapshots(String package) async {
    final event = await _database.child('stats').child(package).once();
    final snap = event.snapshot;
    if (!snap.exists) {
      return [];
    }
    final data = snap.value as Map<String, dynamic>;

    return data.entries.map((e) {
      final timestamp = int.parse(e.key);
      final score = MiniPackageScore.fromJson(e.value);
      return PackageScoreSnapshot.fromMiniPackageScore(
        timestamp: timestamp,
        score: score,
      );
    }).toList();
  }

  Future<GlobalStats> getGlobalStats() async {
    final event = await _database.child('global_stats').once();
    final snap = event.snapshot;
    return GlobalStats.fromJson(snap.value as Map<String, dynamic>);
  }

  Future<List<PackageCountSnapshot>> getPackageCounts() async {
    final event = await _database.child('package_counts').once();
    final snap = event.snapshot;
    final data = snap.value as Map<String, dynamic>;

    return data.entries.map((e) {
      final timestamp = int.parse(e.key);
      final count = e.value as int;
      return PackageCountSnapshot(
        timestamp: DateTime.fromMillisecondsSinceEpoch(timestamp * 1000),
        count: count,
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
}
