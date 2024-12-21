import 'dart:convert';
import 'dart:io';

import 'package:pub_stats_core/pub_stats_core.dart';
import 'package:path/path.dart' as path;

/// Prune duplicate score entries from the database
void main() {
  final string = File(
    path.join(
      '',
      'Users',
      'rexios',
      'Downloads',
      'pub-stats-collector-default-rtdb-export.json',
    ),
  ).readAsStringSync();
  final json = jsonDecode(string) as Map<String, dynamic>;
  final packages = json['stats'] as Map<String, dynamic>;

  var beforeTotal = 0;
  var afterTotal = 0;
  for (final package in packages.keys) {
    final scoresJson = packages[package] as Map<String, dynamic>;
    final scores = scoresJson.map(
      (k, v) => MapEntry(k, MiniPackageScore.fromJson(v)),
    );

    final before = scores.length;
    beforeTotal += before;
    prune(scores);
    final after = scores.length;
    afterTotal += after;
    final diff = before - after;
    print('Pruned $diff entries from $package');
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
  final collisions = <String>{};
  var current = scores.entries.first;
  for (final next in scores.entries.skip(1)) {
    final currentValue = current.value;
    final nextValue = next.value;
    if (currentValue != nextValue) {
      // Do not prune this entry
      current = next;
      continue;
    }
    collisions.add(next.key);
  }

  for (final collision in collisions) {
    scores.remove(collision);
  }
}

int stringToMegabytes(String string) {
  return string.codeUnits.length / 1024 ~/ 1024;
}
