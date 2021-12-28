import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:pub_stats/controller/data_controller.dart';
import 'package:pub_stats/repo/database_repo.dart';
import 'package:pub_stats/service/firebase_service.dart';
import 'package:pub_stats/view/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register logger
  GetIt.I.registerSingleton(Logger());

  // Register services
  await FirebaseService.create();

  // Register repos
  GetIt.I.registerSingleton(DatabaseRepo());

  // Register controllers
  GetIt.I.registerSingleton(await DataController.create());

  runApp(const PubStatsApp());
}
