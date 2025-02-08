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
        _onSignedOut();
      } else {
        this.user.value = user;
        _onSignedIn();
      }
    });
  }

  Future<UserCredential> signInWithGoogle() =>
      _auth.signInWithPopup(GoogleAuthProvider());

  void _onSignedIn() async {
    final user = _auth.currentUser;
    if (user == null) return;

    configs.replaceAll(await _database.getAlertConfigs(user.uid));
  }

  void _onSignedOut() {
    configs.clear();
  }

  Future<void> signOut() async {
    await _auth.signInAnonymously();
  }

  Future<bool> _validateSlug(String slug) async {
    if (slug.isEmpty) return false;
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

  /// Return true on success
  Future<bool> addConfig({
    required String slug,
    required AlertConfigType type,
    required String extra,
    required Set<PackageDataField> ignore,
  }) async {
    if (enabledFields(ignore).isEmpty || !await _validateSlug(slug)) {
      return false;
    }

    final AlertConfig config;
    if (type == AlertConfigType.discord) {
      final match = RegExp(r'https:\/\/discord\.com\/api\/webhooks\/(.+)\/(.+)')
          .firstMatch(extra);

      if (match == null) {
        FastOverlays.showSnackBar(
          const SnackBar(content: Text('Invalid Discord webhook URL')),
        );
        return false;
      }
      config = DiscordAlertConfig(
        slug: slug,
        ignore: ignore,
        id: match[1]!,
        token: match[2]!,
      );
    } else {
      return false;
    }

    await _database.writeAlertConfigs(
      _auth.currentUser!.uid,
      [...configs, config],
    );
    configs.add(config);
    return true;
  }

  Future<void> removeConfig(AlertConfig config) async {
    await _database.writeAlertConfigs(
      _auth.currentUser!.uid,
      configs.where((e) => e != config).toList(),
    );
    configs.remove(config);
  }
}

Set<PackageDataField> enabledFields(Set<PackageDataField> ignoredFields) =>
    PackageDataField.values.toSet().difference(ignoredFields);
