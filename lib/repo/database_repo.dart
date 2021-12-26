import 'package:firebase_database/firebase_database.dart';
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
      final captureTimestamp = int.parse(e.key);
      final score = MiniPackageScore.fromJson(e.value);
      return PackageScoreSnapshot.fromMiniPackageScore(
        captureTimestamp: captureTimestamp,
        score: score,
      );
    }).toList();
  }

  Future<GlobalStats> getGlobalStats() async {
    final event = await _database.child(DatabaseConstants.globalStats).once();
    final snap = event.snapshot;
    return GlobalStats.fromJson(snap.value as Map<String, dynamic>);
  }
}
