import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:pub_stats/service/firebase_service.dart';
import 'package:pub_stats/view/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  GetIt.I.registerSingleton(Logger());
  await FirebaseService.create();

  final score = 

  runApp(const PubStatsApp());
}
