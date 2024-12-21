import 'dart:convert';
import 'dart:io';

import 'package:pub_stats_collector/credential/credentials.dart';
import 'package:pub_stats_collector/service/firebase_service.dart';

void main() async {
  final backupContent = File('backup.json').readAsStringSync();
  final backupData = jsonDecode(backupContent);

  final firebase = await FirebaseService.create(Credentials.tool);
  final database = firebase.database;

  print('Restoring backup...');

  // TODO: Restore alert configs?

  await database.ref('data').set(null);
  final data = backupData['data'] as Map<String, dynamic>;
  for (final package in data.keys) {
    await database.ref('data/$package').set(data[package]);
    print('Restored data for $package');
  }
  print('Restored data');

  await database.ref('diffs').set(null);
  final diffs = backupData['diffs'] as Map<String, dynamic>;
  for (final package in diffs.keys) {
    await database.ref('diffs/$package').set(diffs[package]);
    print('Restored diffs for $package');
  }
  print('Restored diffs');

  await database.ref('global_stats').set(backupData['global_stats']);
  print('Restored global_stats');
  await database.ref('package_counts').set(backupData['package_counts']);
  print('Restored package_counts');

  await database.ref('stats').set(null);
  final stats = backupData['stats'] as Map<String, dynamic>;
  for (final package in stats.keys) {
    await database.ref('stats/$package').set(stats[package]);
    print('Restored stats for $package');
  }

  print('Restoration complete!');
  exit(0);
}
