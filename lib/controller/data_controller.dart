import 'package:fast_ui/fast_ui.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/format/formatting.dart';
import 'package:pub_stats/model/package_score_snapshot.dart';
import 'package:pub_stats/repo/database_repo.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

class DataController {
  static final _database = GetIt.I<DatabaseRepo>();

  final GlobalStats _globalStats;
  final selectedStats = RxValue<PackageScoreSnapshot?>(null);

  DataController._(this._globalStats);

  static Future<DataController> create() async {
    final globalStats = await _database.getGlobalStats();
    return DataController._(globalStats);
  }

  String get lastUpdatedDate => Formatting.timeAgo(_globalStats.lastUpdated);
  String get packageCount => Formatting.number(_globalStats.packageCount);
}
