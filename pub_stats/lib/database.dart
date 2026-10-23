import 'dart:js_interop';

import 'firebase.dart';
import 'models.dart';

/// Hour keys stay below 1e9. This end bound keeps legacy unix-second keys out of
/// the hour-key query so a miss can fall back to the seconds format.
const _maxHourKey = '999999999';

class StatsDatabase {
  DatabaseReference _ref(String path) => firebase.database().ref(path);

  Future<GlobalStats> globalStats() async {
    final value = await readValue(_ref('global_stats').once('value'));
    if (value is! Map) throw Exception('Global stats are unavailable');
    return GlobalStats.fromJson(value.cast<String, dynamic>());
  }

  Future<List<PackageCount>> packageCounts(TimeSpan span) async {
    final value = await readValue(_ref('package_counts').orderByKey().startAt(span.secondsStart).once('value'));
    if (value is! Map) return [];
    final counts = value.entries.map((entry) {
      return PackageCount(
        timestamp: DateTime.fromMillisecondsSinceEpoch(int.parse(entry.key.toString()) * 1000),
        count: (entry.value as num).toInt(),
      );
    }).toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return counts;
  }

  Future<List<ScoreSnapshot>> scores(String package, TimeSpan span) async {
    final ranged = await _snapshots(package, span.hoursStart, end: _maxHourKey);
    if (ranged.isNotEmpty) return ranged;

    final first = await readValue(_ref('stats/$package').orderByKey().limitToFirst(1).once('value'));
    if (first is! Map || first.isEmpty) return [];
    if (!statKeyIsSeconds(first.keys.first.toString())) return [];
    return _snapshots(package, span.secondsStart);
  }

  Future<List<ScoreSnapshot>> _snapshots(String package, String start, {String? end}) async {
    var query = _ref('stats/$package').orderByKey().startAt(start);
    if (end != null) query = query.endAt(end);
    final value = await readValue(query.once('value'));
    if (value is! Map) return [];
    return value.entries.map((entry) => ScoreSnapshot.fromEntry(entry.key.toString(), entry.value)).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<DateTime> firstScan(String package) async {
    final value = await readValue(_ref('stats/$package').orderByKey().limitToFirst(1).once('value'));
    if (value is! Map || value.isEmpty) {
      throw Exception('No first scan found for $package');
    }
    return timeFromStatKey(value.keys.first.toString());
  }

  Future<PackageData> packageData(String package) async {
    final value = await readValue(_ref('data/$package').once('value'));
    if (value is! Map) throw Exception('No data found for $package');
    return PackageData.fromJson(value.cast<String, dynamic>());
  }

  Future<List<HistoryEntry>> history(String package, {String? endBefore, int limit = 20}) async {
    var query = _ref('diffs/$package').orderByKey();
    if (endBefore != null) query = query.endAt(endBefore);
    final value = await readValue(query.limitToLast(limit).once('value'));
    if (value is! Map) return [];
    final entries = value.entries.map((entry) {
      final changes = asStringMap(entry.value).entries
          .map((change) => FieldChange.fromJson(change.key, asStringMap(change.value)))
          .where((change) => change.text.isNotEmpty || change.added.isNotEmpty || change.removed.isNotEmpty)
          .toList();
      return HistoryEntry(
        timestamp: DateTime.fromMillisecondsSinceEpoch(int.parse(entry.key.toString()) * 1000),
        changes: changes,
      );
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries;
  }

  Future<List<AlertConfig>> alerts(String uid) async {
    final value = await readValue(_ref('alerts/$uid').once('value'));
    final items = switch (value) {
      List() => value,
      Map() =>
        (value.entries.toList()..sort((a, b) => a.key.toString().compareTo(b.key.toString())))
            .map((entry) => entry.value)
            .toList(),
      _ => const [],
    };
    return [
      for (final item in items)
        if (item is Map) AlertConfig.fromJson(item.cast<String, dynamic>()),
    ];
  }

  Future<void> writeAlerts(String uid, List<AlertConfig> configs) {
    final payload = configs.map((config) => config.toJson()).toList().jsify();
    return _ref('alerts/$uid').set(payload).toDart;
  }
}
