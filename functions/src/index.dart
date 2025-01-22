import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:firebase_js_interop/admin.dart';
import 'package:firebase_js_interop/admin/app.dart';
import 'package:firebase_js_interop/express.dart' as express;
import 'package:firebase_js_interop/functions.dart';
import 'package:firebase_js_interop/functions/https.dart';
import 'package:firebase_js_interop/node.dart';

void main() {
  FirebaseAdmin.app.initializeApp();

  final database = FirebaseAdmin.database.getDatabase();

  exports['badges'] = FirebaseFunctions.https.onRequest(
    (Request request, express.Response response) {
      return response.send('Hello from Firebase!'.toJS);
    }.toJS,
  );
}
