import 'dart:convert';
import 'dart:io';

import 'package:pub_stats_core/pub_stats_core.dart';
import 'package:path/path.dart' as path;

/// Prune duplicate score entries from the database
void main() {
  final string = File(path.join('tool', 'export.json')).readAsStringSync();
  final json = jsonDecode(string) as Map<String, dynamic>;
  final packages = json['stats'] as Map<String, dynamic>;

  var beforeTotal = 0;
  var afterTotal = 0;
  for (final package in packages.keys) {
    final scoresJson = packages[package] as Map<String, dynamic>;
    final scores = scoresJson.map(
      (k, v) => MapEntry(k, MiniPackageScore.fromJson(v as List)),
    );

    final before = scores.length;
    beforeTotal += before;
    prune(scores);
    final after = scores.length;
    afterTotal += after;
    final diff = before - after;
    print('Pruned $diff entries from $package');

    packages[package] = {
      for (final e in scores.entries) e.key: e.value.toJson(),
    };
  }

  final newString = jsonEncode(json);

  final beforeMegabytes = stringToMegabytes(string);
  final afterMegabytes = stringToMegabytes(newString);

  final diff = beforeTotal - afterTotal;
  final diffMegabytes = beforeMegabytes - afterMegabytes;

  print('Before: $beforeTotal ($beforeMegabytes MB)');
  print('After:  $afterTotal ($afterMegabytes MB)');
  print('Pruned: $diff ($diffMegabytes MB)');

  File('pruned.json').writeAsStringSync(newString);
}

void prune(Map<String, MiniPackageScore> scores) {
  if (scores.length < 2) return;

  final keys = scores.keys.toList()
    ..sort((a, b) => int.parse(a).compareTo(int.parse(b)));

  final toRemove = <String>{};
  var runStart = 0;
  for (var i = 1; i <= keys.length; i++) {
    final runEnded =
        i == keys.length || scores[keys[i]] != scores[keys[runStart]];
    if (!runEnded) continue;

    // Keep first and last of each plateau; drop interior duplicates
    for (var j = runStart + 1; j < i - 1; j++) {
      toRemove.add(keys[j]);
    }
    runStart = i;
  }
  toRemove.forEach(scores.remove);
}

int stringToMegabytes(String string) {
  return string.codeUnits.length / 1024 ~/ 1024;
}
