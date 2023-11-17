import 'package:fast_ui/fast_ui.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:pub_stats/constant/app_theme.dart';
import 'package:pub_stats/controller/data_controller.dart';
import 'package:pub_stats/view/screen/home.dart';

class PubStatsApp extends StatelessWidget {
  static final dataController = GetIt.I<DataController>();

  const PubStatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: FastNav.init(FastOverlays.init()),
      title: 'pubstats.dev',
      themeMode: ThemeMode.dark,
      darkTheme: AppTheme.theme,
      // Must use this instead of home for an initial route to work
      onGenerateInitialRoutes: (initialRoute) {
        dataController.parseRoute(initialRoute);
        return [MaterialPageRoute(builder: (context) => const Home())];
      },
      // This must be set but we don't actually need to do anything
      onGenerateRoute: (settings) {
        dataController.parseRoute(settings.name!);
        return MaterialPageRoute(builder: (context) => const Home());
      },
    );
  }
}
