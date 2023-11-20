import 'package:firebase_admin/firebase_admin.dart' hide Credentials;
import 'package:pub_stats_collector/credential/credentials.dart';

class FirebaseService {
  final Database database;

  FirebaseService._({
    required this.database,
  });

  static Future<FirebaseService> create(Credentials credentials) async {
    App app;
    try {
      app = FirebaseAdmin.instance.initializeApp(
        AppOptions(
          credential:
              ServiceAccountCredential.fromJson(credentials.serviceAccount),
          databaseUrl: credentials.databaseUrl,
        ),
      );
    } catch (e) {
      // This will throw if Firebase has already been initialized
      print(e);
      app = FirebaseAdmin.instance.app()!;
    }

    return FirebaseService._(database: app.database());
  }
}
