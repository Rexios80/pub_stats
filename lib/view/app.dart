import 'package:fast_ui/fast_ui.dart';
import 'package:flutter/material.dart';
import 'package:pub_stats/constant/app_theme.dart';
import 'package:pub_stats/view/screen/home.dart';

class PubStatsApp extends StatelessWidget {
  const PubStatsApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey:
          FastNav.init(FastOverlays.init(GlobalKey<NavigatorState>())),
      title: 'pubstats.dev',
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.theme,
      // Must use this instead of home for an inital route to work
      onGenerateInitialRoutes: (initialRoute) => [
        MaterialPageRoute(
          builder: (context) => const Home(),
        ),
      ],
      // This must be set but we don't actually need to do anything
      onGenerateRoute: (settings) {},
    );
  }
}
