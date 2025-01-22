import 'dart:async';
import 'dart:io';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_js_interop/express.dart' as express;
import 'package:firebase_js_interop/node.dart';
import 'package:pub_api_client/pub_api_client.dart' hide Credentials;
import 'package:pub_stats_collector/controller/score_fetch_controller.dart';
import 'package:pub_stats_collector/credential/credentials.dart';
import 'package:pub_stats_collector/repo/database_repo.dart';
import 'package:pub_stats_collector/repo/discord_repo.dart';
import 'package:pub_stats_collector/service/user_agent_client.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

var running = false;

Future<express.Response> fetchPackageData(express.Response response) async {
  // Do not allow more than one instance to run at the same time
  if (running) return response.send(null);
  running = true;

  final debug = process.env['FUNCTIONS_EMULATOR'] == true.toJS;
  final credentials = debug ? Credentials.debug : Credentials.prod;

  final database = DatabaseRepo();
  final discord = DiscordRepo(credentials);

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
    final controller = ScoreFetchController(
      credentials,
      database,
      discord,
      alertConfigs,
      data,
    );

    final scoresFuture = controller.fetchScores();
    if (debug) {
      await scoresFuture;
    } else {
      await scoresFuture.timeout(
        Duration(minutes: 10),
        onTimeout: () => throw TimeoutException('Global timeout reached'),
      );
    }
  } catch (e, stacktrace) {
    print(e);
    print(stacktrace);

    for (final config in alertConfigs['.system'] ?? <AlertConfig>[]) {
      await switch (config.type) {
        AlertConfigType.discord => discord.sendSystemErrorAlert(
            config: config as DiscordAlertConfig,
            error: e,
          )
      };
    }
    exit(1);
  }

  running = false;
  return response.send(null);
}
