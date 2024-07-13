import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:pub_stats/firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final _logger = GetIt.I<Logger>();

  FirebaseService._();

  static Future<FirebaseService> create() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize services
    final analytics = FirebaseAnalytics.instance;
    final performance = FirebasePerformance.instance;

    final database = FirebaseDatabase.instance;
    final auth = FirebaseAuth.instance;

    if (kDebugMode) {
      database.useDatabaseEmulator('localhost', 9000);
      await auth.useAuthEmulator('localhost', 9099);
    } else {
      await _activateAppCheck();
      try {
        // Log the app open event on startup
        await analytics.logAppOpen();
        final enabled = await performance.isPerformanceCollectionEnabled();
        _logger
            .d('Performance collection is ${enabled ? 'enabled' : 'disabled'}');
      } catch (e) {
        // These might throw if ad blocking is enabled
        _logger.e(e);
      }
    }

    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }

    return FirebaseService._();
  }

  static Future<void> _activateAppCheck() async {
    try {
      await FirebaseAppCheck.instance.activate(
        webProvider:
            ReCaptchaV3Provider('6LeVDcodAAAAAFLXdyTIcFjcEGN-Gjl2nWrU08q5'),
      );
    } catch (e) {
      // This will throw after a hot reload
      _logger.e(e);
    }
  }
}
