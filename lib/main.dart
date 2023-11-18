import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:pub_stats/controller/data_controller.dart';
import 'package:pub_stats/repo/url_repo.dart';
import 'package:pub_stats/service/firebase_service.dart';
import 'package:pub_stats/view/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setUrlStrategy(null);

  // Register logger
  GetIt.I.registerSingleton(Logger());

  // Register services
  GetIt.I.registerSingleton(UrlRepo());
  await FirebaseService.create();

  // Register repos

  // Register controllers
  GetIt.I.registerSingleton(await DataController.create());

  runApp(const PubStatsApp());
}
