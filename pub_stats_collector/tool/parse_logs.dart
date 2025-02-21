import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

final home = Platform.environment['HOME']!;

void main() {
  final logContent = Directory(path.join(home, 'Downloads'))
      .listSync()
      .whereType<File>()
      .firstWhere(
        (file) => RegExp(r'downloaded-logs-.*\.json$').hasMatch(file.path),
      )
      .readAsStringSync();

  final requestPaths = (jsonDecode(logContent) as List)
      .map((e) => e as Map)
      .map((e) => e.cast<String, dynamic>())
      .map((e) => e['httpRequest']?['requestUrl'] as String?)
      .whereType<String>()
      .map(Uri.parse)
      .map((e) => e.path);

  final requestCounts = requestPaths.fold<Map<String, int>>(
    {},
    (p, e) => p..update(e, (value) => value + 1, ifAbsent: () => 1),
  );

  final sortedRequestCounts = requestCounts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));

  for (final MapEntry(key: path, value: count) in sortedRequestCounts) {
    print('$path: $count');
  }
}
