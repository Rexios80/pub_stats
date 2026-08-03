import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:pub_stats_core/pub_stats_core.dart';

/// Compact stats values to arrays and re-key timestamps to hours since epoch.
void main() {
  final string = File(path.join('tool', 'export.json')).readAsStringSync();
  final json = jsonDecode(string) as Map<String, dynamic>;
  final packages = json['stats'] as Map<String, dynamic>;

  var beforeTotal = 0;
  var afterTotal = 0;
  var collisions = 0;

  for (final package in packages.keys) {
    final scoresJson = packages[package] as Map<String, dynamic>;
    beforeTotal += scoresJson.length;

    final byHour = <String, MiniPackageScore>{};
    final keys = scoresJson.keys.toList()
      ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

    for (final key in keys) {
      final score = scoreFromLegacyJson(
        (scoresJson[key] as Map).cast<String, dynamic>(),
      );
      final hourKey = (int.parse(key) ~/ 3600).toString();
      if (byHour.containsKey(hourKey)) collisions++;
      // Later sample wins on same-hour collision
      byHour[hourKey] = score;
    }

    afterTotal += byHour.length;
    packages[package] = {
      for (final e in byHour.entries) e.key: e.value.toJson(),
    };
  }

  final newString = jsonEncode(json);

  final beforeMegabytes = stringToMegabytes(string);
  final afterMegabytes = stringToMegabytes(newString);

  print('Before: $beforeTotal ($beforeMegabytes MB)');
  print('After:  $afterTotal ($afterMegabytes MB)');
  print('Removed: ${beforeTotal - afterTotal} (hour collisions: $collisions)');
  print('Saved: ${beforeMegabytes - afterMegabytes} MB');

  File('compacted.json').writeAsStringSync(newString);
}

/// Parse the pre-compaction `{l, p, p2, d}` map format.
MiniPackageScore scoreFromLegacyJson(Map<String, dynamic> json) {
  return MiniPackageScore(
    likeCount: (json['l'] as num).toInt(),
    legacyPopularityScore: (json['p'] as num?)?.toInt(),
    popularityScore: (json['p2'] as num?)?.toInt(),
    downloadCount: (json['d'] as num?)?.toInt(),
  );
}

int stringToMegabytes(String string) {
  return string.codeUnits.length / 1024 ~/ 1024;
}
