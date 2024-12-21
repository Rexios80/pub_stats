// Too annoying
// ignore_for_file: unawaited_futures

import 'dart:convert';
import 'dart:io';

import 'package:flutter_tools_task_queue/flutter_tools_task_queue.dart';
import 'package:pub_stats_collector/credential/credentials.dart';
import 'package:pub_stats_collector/service/firebase_service.dart';

void main() async {
  final backupContent = File('backup.json').readAsStringSync();
  final backupData = jsonDecode(backupContent);

  final firebase = await FirebaseService.create(Credentials.tool);
  final database = firebase.database;

  print('Restoring backup...');

  Future<void> restoreForPackages(String path) async {
    final queue = TaskQueue();
    final data = backupData[path] as Map<String, dynamic>;
    var i = 0;
    for (final package in data.keys) {
      queue.add(() async {
        await database.ref('$path/$package').set(data[package]);
        i++;
        if (i % 100 == 0) {
          print('Restored $path for $i/${data.length} packages');
        }
      });
    }
    await queue.tasksComplete;
    print('Restored $path');
  }

  // TODO: Restore alert configs?

  await restoreForPackages('data');
  await restoreForPackages('diffs');

  await database.ref('global_stats').set(backupData['global_stats']);
  print('Restored global_stats');
  await database.ref('package_counts').set(backupData['package_counts']);
  print('Restored package_counts');

  await restoreForPackages('stats');

  print('Restoration complete!');
  exit(0);
}
