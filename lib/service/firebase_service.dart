import 'package:firebase_core/firebase_core.dart';
import 'package:pub_stats/firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_performance/firebase_performance.dart';

class FirebaseService {
  FirebaseService._();

  static Future<FirebaseService> create() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await _activateAppCheck();

    // Initialize services
    FirebaseAnalytics.instance;
    FirebasePerformance.instance;

    return FirebaseService._();
  }

  static Future<void> _activateAppCheck() async {
    await FirebaseAppCheck.instance.activate(
      webRecaptchaSiteKey: '6LeVDcodAAAAAFLXdyTIcFjcEGN-Gjl2nWrU08q5',
    );
  }
}
