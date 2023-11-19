import 'package:fast_ui/fast_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final _auth = FirebaseAuth.instance;

  final user = RxValue<User?>(null);

  AuthController() {
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
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
