import 'dart:convert';
import 'dart:io';

import 'package:pub_stats_collector/credential/credentials.dart';
import 'package:pub_stats_collector/service/firebase_service.dart';

void main() async {
  final backupContent = File('backup.json').readAsStringSync();
  final data = jsonDecode(backupContent);

  final firebase = await FirebaseService.create(Credentials.debug);
  final database = firebase.database;

  // TODO: Restore alert configs?
  await database.ref('data').set(data['data']);
  print('Restored data');
  await database.ref('diffs').set(data['diffs']);
  print('Restored diffs');
  await database.ref('global_stats').set(data['global_stats']);
  print('Restored global_stats');
  await database.ref('package_counts').set(data['package_counts']);
  print('Restored package_counts');

  final stats = data['stats'] as Map<String, dynamic>;
  for (final package in stats.keys) {
    await database.ref('stats/$package').set(stats[package]);
    print('Restored stats for $package');
  }
}
