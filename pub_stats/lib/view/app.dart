import 'package:fast_ui/fast_ui.dart';
import 'package:flutter/material.dart';
import 'package:pub_stats/constant/app_theme.dart';
import 'package:pub_stats/view/screen/home.dart';

class PubStatsApp extends StatelessWidget {
  const PubStatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: FastNav.init(FastOverlays.init()),
      title: 'pubstats',
      theme: AppTheme.theme(Brightness.light),
      darkTheme: AppTheme.theme(Brightness.dark),
      // Must use this instead of home for an initial route to work
      onGenerateInitialRoutes: (initialRoute) => [
        MaterialPageRoute(
          builder: (context) => const Home(),
        ),
      ],
      // This must be set but we don't actually need to do anything
      onGenerateRoute: (settings) => null,
    );
  }
}
