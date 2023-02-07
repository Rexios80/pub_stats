import 'package:firebase_database/firebase_database.dart';
import 'package:pub_stats/model/package_count_snapshot.dart';
import 'package:pub_stats/model/package_score_snapshot.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

class DatabaseRepo {
  final _database = FirebaseDatabase.instance.ref();

  Future<List<PackageScoreSnapshot>> getScoreSnapshots(String package) async {
    final event =
        await _database.child(DatabaseConstants.stats).child(package).once();
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
    final event = await _database.child(DatabaseConstants.globalStats).once();
    final snap = event.snapshot;
    return GlobalStats.fromJson(snap.value as Map<String, dynamic>);
  }

  Future<List<PackageCountSnapshot>> getPackageCounts() async {
    final event = await _database.child(DatabaseConstants.packageCounts).once();
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

  Future<Set<String>> getDeveloperPackages() async {
    final event = await _database.child('developer').once();
    final snap = event.snapshot as Map<String, dynamic>;
    final data =
        snap.map((k, v) => MapEntry(k, DeveloperPackageData.fromJson(v)));
    data.removeWhere((k, v) => v.isUnlisted || v.isDiscontinued);
    return data.keys.toSet();
  }
}
