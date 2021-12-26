import 'package:flutter/material.dart';
import 'package:pub_stats/service/firebase_service.dart';
import 'package:pub_stats/view/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseService.create();

  runApp(const PubStatsApp());
}
