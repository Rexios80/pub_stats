import 'dart:async';
import 'dart:js_interop';

import 'package:firebase_js_interop/express.dart' as express;
import 'package:firebase_js_interop/node.dart';
import 'package:pub_stats_collector/controller/score_fetch_controller.dart';
import 'package:pub_stats_collector/repo/alert_handler.dart';
import 'package:pub_stats_collector/repo/database_repo.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

var running = false;

Future<express.Response> fetchPackageData(express.Response response) async {
  // Do not allow more than one instance to run at the same time
  if (running) return response.send(null);
  running = true;

  final database = DatabaseRepo();

  var alertConfigs = <String, List<AlertConfig>>{};

  try {
    final rawConfigs = await database.readAlertConfigs();
    alertConfigs = <String, List<AlertConfig>>{};
    for (final config in rawConfigs.values.expand((e) => e)) {
      alertConfigs.update(
        config.slug,
        (value) => value..add(config),
        ifAbsent: () => [config],
      );
    }

    final data = await database.readPackageData();
    final controller = ScoreFetchController(database, alertConfigs, data);

    await controller.fetchScores().timeout(
      Duration(minutes: 10),
      onTimeout: () => throw TimeoutException('Global timeout reached'),
    );
  } catch (e, stacktrace) {
    print(e);
    print(stacktrace);

    for (final config in alertConfigs['.system'] ?? <AlertConfig>[]) {
      await AlertHandler.instance.sendSystemErrorAlert(
        config: config,
        error: e,
      );
    }

    process.exit(1.toJS);
  }

  running = false;
  return response.send(null);
}
