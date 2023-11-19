import 'package:fast_ui/fast_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pub_stats/repo/database_repo.dart';
import 'package:pub_stats/repo/pub_repo.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

class UserController {
  final _auth = FirebaseAuth.instance;
  final _database = DatabaseRepo();
  final _pub = PubRepo();

  final user = RxValue<User?>(null);
  final configs = <AlertConfig>[].rx;

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

  Future<bool> validateSlug(String slug) async {
    if (slug == '.system') return true;

    final parts = slug.split(':');
    if (parts.length == 1) {
      final package = parts[0];
      final packageExists = await _pub.packageExists(package);
      if (!packageExists) {
        FastOverlays.showSnackBar(
          const SnackBar(content: Text('Package does not exist')),
        );
      }
      return packageExists;
    } else if (parts.length == 2) {
      final publisher = parts[1];
      final publisherExits = await _pub.publisherExists(publisher);
      if (!publisherExits) {
        FastOverlays.showSnackBar(
          const SnackBar(content: Text('Publisher does not exist')),
        );
      }
      return publisherExits;
    }

    return false;
  }

  Future<void> addConfig(AlertConfig config) async {
    configs.add(config);
    // TODO
    // _database.addAlertConfig(_auth.currentUser!.uid, config);
  }
}
