import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsRepo {
  final _analytics = FirebaseAnalytics.instance;

  void logSearch(String searchTerm) {
    _analytics.logSearch(searchTerm: searchTerm);
  }
}
