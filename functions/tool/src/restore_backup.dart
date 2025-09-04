// Too annoying
// ignore_for_file: unawaited_futures

import 'dart:convert';
import 'dart:js_interop';

import 'package:firebase_js_interop/admin.dart';
import 'package:firebase_js_interop/admin/app.dart';
import 'package:firebase_js_interop/extensions.dart';
import 'package:firebase_js_interop/node.dart';
import 'package:flutter_tools_task_queue/flutter_tools_task_queue.dart';

import '../../secret/service_account.dart';
import '../../src/interop/source_map_support.dart';

void main() async {
  sourceMapSupport.install();

  final app = FirebaseAdmin.app;
  app.initializeApp(
    AppOptions(
      credential: app.cert(serviceAccount.toJS),
      databaseURL: 'https://pub-stats-collector-default-rtdb.firebaseio.com',
    ),
  );

  final fs = Node.fs;

  final backupContent =
      fs.readFileSync('backup.json'.toJS, 'utf8'.toJS) as JSString;
  final backupData = jsonDecode(backupContent.toDart);

  final database = FirebaseAdmin.database.getDatabase();

  print('Restoring backup...');

  Future<void> restoreForPackages(String path) async {
    final queue = TaskQueue(maxJobs: 10);
    final data = backupData[path] as Map<String, dynamic>;
    var i = 0;
    for (final package in data.keys) {
      queue.add(() async {
        final packageData = (data[package] as Map).cast<String, dynamic>();
        await database.ref('$path/$package'.toJS).set(packageData.toJS).toDart;
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

  final globalStatsData = (backupData['global_stats'] as Map)
      .cast<String, dynamic>();
  await database.ref('global_stats'.toJS).set(globalStatsData.toJS).toDart;
  print('Restored global_stats');
  final packageCountsData = (backupData['package_counts'] as Map)
      .cast<String, dynamic>();
  await database.ref('package_counts'.toJS).set(packageCountsData.toJS).toDart;
  print('Restored package_counts');

  await restoreForPackages('stats');

  print('Restoration complete!');
  process.exit(0.toJS);
}
