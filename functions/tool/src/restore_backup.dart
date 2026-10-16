import 'dart:js_interop';

import 'package:firebase_js_interop/admin.dart';
import 'package:firebase_js_interop/admin/app.dart';
import 'package:firebase_js_interop/js.dart';
import 'package:firebase_js_interop/node.dart';

import '../../src/interop/source_map_support.dart';

/// Streams entries from a large Firebase RTDB backup without loading it as one
/// string (Node's max string length is ~512MB; backup.json is larger).
extension type _StreamBackup._(JSObject _) implements JSObject {
  external JSPromise forEachObjectEntry(
    JSString file,
    JSString path,
    JSFunction fn, [
    JSNumber? concurrency,
  ]);

  external JSPromise<JSAny?> readPath(JSString file, JSString path);
}

final _streamBackup = require('../src/stream_backup.js') as _StreamBackup;

/// Run with:
/// node --max-old-space-size=8192 tool/lib/restore_backup.js
void main() async {
  sourceMapSupport.install();

  final app = FirebaseAdmin.app;
  app.initializeApp(
    AppOptions(
      credential: app.cert('secret/service_account.json'.toJS),
      databaseURL: 'https://pub-stats-collector-default-rtdb.firebaseio.com',
    ),
  );

  final database = FirebaseAdmin.database.getDatabase();
  const backupFile = 'backup.json';

  print('Restoring backup...');

  Future<void> restoreForPackages(String path) async {
    var i = 0;

    await _streamBackup
        .forEachObjectEntry(
          backupFile.toJS,
          path.toJS,
          ((JSString package, JSAny packageData) {
            return promise(() async {
              await database
                  .ref('$path/${package.toDart}'.toJS)
                  .set(packageData)
                  .toDart;
              i++;
              if (i % 100 == 0) {
                print('Restored $path for $i packages');
              }
            });
          }).toJS,
          10.toJS,
        )
        .toDart;

    print('Restored $path ($i packages)');
  }

  // TODO: Restore alert configs?

  await restoreForPackages('data');
  await restoreForPackages('diffs');

  final globalStatsData = await _streamBackup
      .readPath(backupFile.toJS, 'global_stats'.toJS)
      .toDart;
  await database.ref('global_stats'.toJS).set(globalStatsData).toDart;
  print('Restored global_stats');

  final packageCountsData = await _streamBackup
      .readPath(backupFile.toJS, 'package_counts'.toJS)
      .toDart;
  await database.ref('package_counts'.toJS).set(packageCountsData).toDart;
  print('Restored package_counts');

  await restoreForPackages('stats');

  print('Restoration complete!');
  process.exit(0.toJS);
}
