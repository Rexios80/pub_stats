import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

class Credentials {
  static const _userAgent = 'Rexios80/pub_stats_collector';

  static final prod = Credentials._(
    userAgent: _userAgent,
    serviceAccount: jsonDecode(Platform.environment['SERVICE_ACCOUNT_KEY']!),
    databaseUrl: 'https://pub-stats-collector-default-rtdb.firebaseio.com/',
  );

  static final debug = Credentials._(
    userAgent: _userAgent,
    serviceAccount: jsonDecode(
      File(path.join('secret', 'service_account_key.json')).readAsStringSync(),
    ),
    databaseUrl: 'http://127.0.0.1:9000/?ns=pub-stats-collector-default-rtdb',
  );

  //! THIS WILL MODIFY THE PRODUCTION DATABASE
  static final tool = Credentials._(
    userAgent: _userAgent,
    serviceAccount: jsonDecode(
      File(path.join('secret', 'service_account_key.json')).readAsStringSync(),
    ),
    databaseUrl: 'https://pub-stats-collector-default-rtdb.firebaseio.com/',
  );

  final String userAgent;
  final Map<String, dynamic> serviceAccount;
  final String databaseUrl;

  const Credentials._({
    required this.userAgent,
    required this.serviceAccount,
    required this.databaseUrl,
  });
}
