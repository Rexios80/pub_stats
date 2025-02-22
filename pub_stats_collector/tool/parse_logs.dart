import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

final home = Platform.environment['HOME']!;

// Download logs here:
// https://console.cloud.google.com/logs/query;query=resource.type%3D%22cloud_run_revision%22%20resource.labels.service_name%3D%22badges%22%20resource.labels.location%3D%22us-central1%22?project=pub-stats-collector
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
