import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_js_interop/admin.dart';
import 'package:firebase_js_interop/admin/app.dart';
import 'package:firebase_js_interop/express.dart' as express;
import 'package:firebase_js_interop/extensions.dart';
import 'package:firebase_js_interop/functions.dart';
import 'package:firebase_js_interop/functions/https.dart';
import 'package:firebase_js_interop/js.dart';
import 'package:firebase_js_interop/node.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

import 'badge_maker.dart';

final packageBadgeRegex = RegExp(r'^\/packages\/([^\/]+)\/([^\/]+)\.svg$');

enum BadgeType {
  popularity,
  rank,
  dependents;

  String get databaseKey => switch (this) {
        popularity => 'ps2',
        rank => 'n',
        dependents => 'nd',
      };
}

void main() {
  FirebaseAdmin.app.initializeApp();

  final database = FirebaseAdmin.database.getDatabase();

  exports['badges'] = FirebaseFunctions.https.onRequest(
    (Request request, express.Response response) {
      final match = packageBadgeRegex.firstMatch(request.path);
      final packageName = match?[1];
      final badgeType = BadgeType.values.asNameMap()[match?[2]];
      if (packageName == null || badgeType == null) {
        return response.status(404).send(null);
      }

      final key = badgeType.databaseKey;
      return promise(() async {
        final snap =
            await database.ref('data/$packageName/$key'.toJS).get().toDart;

        final data = snap.val();
        if (data == null) return response.status(404).send(null);

        return response.send(
          badgeMaker
              .makeBadge(
                BadgeFormat(
                  label: badgeType.name,
                  message: data.toString(),
                  color: '#007ec6',
                  links: [
                    'https://pubstats.dev/packages/$packageName'.toJS,
                  ].toJS,
                ),
              )
              .toJS,
        );
      });
    }.toJS,
  );
}
