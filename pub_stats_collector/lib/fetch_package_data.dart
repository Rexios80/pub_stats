import 'dart:async';
import 'dart:io';

import 'package:pub_stats_collector/controller/score_fetch_controller.dart';
import 'package:pub_stats_collector/credential/credentials.dart';
import 'package:pub_stats_collector/repo/database_repo.dart';
import 'package:pub_stats_collector/repo/discord_repo.dart';
import 'package:pub_stats_collector/service/firebase_service.dart';
import 'package:pub_stats_core/pub_stats_core.dart';
import 'package:shelf/shelf.dart';

var running = false;

Future<Response> fetchPackageData(Request request, {bool debug = false}) async {
  // Do not allow more than one instance to run at the same time
  if (running) return Response.ok(null);
  running = true;

  final credentials = debug ? Credentials.debug : Credentials.prod;

  final firebase = await FirebaseService.create(credentials);
  final database = DatabaseRepo(firebase.database);
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
  return Response.ok(null);
}
