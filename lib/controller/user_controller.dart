import 'package:fast_ui/fast_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pub_stats/repo/database_repo.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

class UserController {
  final _auth = FirebaseAuth.instance;
  final _database = DatabaseRepo();

  final user = RxValue<User?>(null);
  final configs = <String, List<AlertConfig>>{}.rx;

  UserController() {
    _auth.userChanges().listen((user) {
      if (user == null || user.isAnonymous) {
        this.user.value = null;
      } else {
        this.user.value = user;
      }
    });
  }

  Future<void> signInWithGoogle() async {
    await _auth.signInWithPopup(GoogleAuthProvider());
    await _fetchData();
  }

  Future<void> _fetchData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    configs.replaceAll(await _database.getAlertConfigs(user.uid));
  }

  Future<void> signOut() async {
    await _auth.signOut();
    configs.clear();
  }
}
