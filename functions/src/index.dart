import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_js_interop/admin.dart';
import 'package:firebase_js_interop/admin/app.dart';
import 'package:firebase_js_interop/express.dart' as express;
import 'package:firebase_js_interop/functions.dart';
import 'package:firebase_js_interop/functions/https.dart';
import 'package:firebase_js_interop/node.dart';

import 'badge_maker.dart';

final packageBadgeRegex = RegExp(r'^\/packages\/([^\/]+)\/([^\/]+)\.svg$');

enum BadgeType {
  popularity,
  rank,
  dependents,
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

      return response
          .send(badgeMaker.makeBadge(BadgeFormat(message: 'test')).toJS);
    }.toJS,
  );
}
