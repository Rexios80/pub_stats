import 'package:firebase_auth/firebase_auth.dart';

class AuthRepo {
  final _auth = FirebaseAuth.instance;

  Future<void> signInWithGoogle() async {
    await _auth.signInWithProvider(GoogleAuthProvider());
  }
}
