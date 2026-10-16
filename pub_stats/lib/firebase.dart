import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

const firebaseApiKey = 'AIzaSyD5P5WcinsZrqMMKw4F-GQcjfqvSZbkuf4';
const firebaseAppId = '1:602612349235:web:bc801073a0f4599a252646';
const firebaseMessagingSenderId = '602612349235';
const firebaseProjectId = 'pub-stats-collector';
const firebaseDatabaseUrl = 'https://pub-stats-collector-default-rtdb.firebaseio.com';
const firebaseStorageBucket = 'pub-stats-collector.appspot.com';
const firebaseMeasurementId = 'G-SVB0V0S48E';
const recaptchaSiteKey = '6LeVDcodAAAAAFLXdyTIcFjcEGN-Gjl2nWrU08q5';

@JS('firebase')
external Firebase get firebase;

extension type Firebase._(JSObject _) implements JSObject {
  external JSAny? initializeApp(JSAny? options);
  external FirebaseAuth auth();
  external FirebaseDatabase database();
  external FirebaseAppCheck appCheck();
  external FirebaseAnalytics analytics();
}

extension type FirebaseAuth._(JSObject _) implements JSObject {
  external FirebaseUser? get currentUser;
  external void useEmulator(String url);
  external JSPromise signInAnonymously();
  external JSPromise signInWithPopup(JSAny provider);
  external JSPromise signOut();
  external void onAuthStateChanged(JSFunction callback);
}

extension type FirebaseUser(JSObject _) implements JSObject {
  external String get uid;
  external String? get displayName;
  external String? get photoURL;
  external bool get isAnonymous;
}

@JS('firebase.auth.GoogleAuthProvider')
extension type GoogleAuthProvider._(JSObject _) implements JSObject {
  external GoogleAuthProvider();
}

extension type FirebaseDatabase._(JSObject _) implements JSObject {
  external void useEmulator(String host, int port);
  external DatabaseReference ref(String path);
}

extension type DatabaseReference._(JSObject _) implements JSObject {
  external DatabaseQuery orderByKey();
  external JSPromise once(String eventType);
  external JSPromise set(JSAny? value);
}

extension type DatabaseQuery._(JSObject _) implements JSObject {
  external DatabaseQuery startAt(String value);
  external DatabaseQuery endAt(String value);
  external DatabaseQuery limitToFirst(int limit);
  external DatabaseQuery limitToLast(int limit);
  external JSPromise once(String eventType);
}

extension type DataSnapshot._(JSObject _) implements JSObject {
  external bool exists();
  external JSAny? val();
}

extension type FirebaseAppCheck._(JSObject _) implements JSObject {
  external void activate(JSAny provider, bool isTokenAutoRefreshEnabled);
}

@JS('firebase.appCheck.ReCaptchaV3Provider')
extension type ReCaptchaV3Provider._(JSObject _) implements JSObject {
  external ReCaptchaV3Provider(String siteKey);
}

extension type FirebaseAnalytics._(JSObject _) implements JSObject {
  external void logEvent(String name, JSAny? params);
}

Future<void> initializeFirebase() async {
  final options = {
    'apiKey': firebaseApiKey,
    'authDomain': web.window.location.hostname,
    'databaseURL': firebaseDatabaseUrl,
    'projectId': firebaseProjectId,
    'storageBucket': firebaseStorageBucket,
    'messagingSenderId': firebaseMessagingSenderId,
    'appId': firebaseAppId,
    'measurementId': firebaseMeasurementId,
  }.jsify();

  try {
    firebase.initializeApp(options);
  } catch (_) {}

  final host = web.window.location.hostname;
  if (host == 'localhost' || host == '127.0.0.1') {
    firebase.auth().useEmulator('http://127.0.0.1:9099');
    firebase.database().useEmulator('127.0.0.1', 9000);
  } else {
    try {
      firebase.appCheck().activate(ReCaptchaV3Provider(recaptchaSiteKey), true);
    } catch (_) {}
    try {
      // First call starts automatic page and session collection.
      firebase.analytics().logEvent('app_open', {}.jsify());
    } catch (_) {}
  }

  final auth = firebase.auth();
  if (auth.currentUser != null) return;

  final firstUser = Completer<JSAny?>();
  auth.onAuthStateChanged(
    (JSAny? user) {
      if (!firstUser.isCompleted) firstUser.complete(user);
    }.toJS,
  );
  final user = await firstUser.future.timeout(const Duration(seconds: 10), onTimeout: () => null);
  if (user == null && auth.currentUser == null) {
    await auth.signInAnonymously().toDart;
  }
}

void logSearch(String term) {
  try {
    firebase.analytics().logEvent('search', {'search_term': term}.jsify());
  } catch (_) {}
}

Object? normalizeJson(Object? value) {
  return switch (value) {
    Map() => {for (final entry in value.entries) entry.key.toString(): normalizeJson(entry.value)},
    List() => [for (final item in value) normalizeJson(item)],
    _ => value,
  };
}

Future<Object?> readValue(JSPromise promise) async {
  final result = await promise.toDart;
  final snapshot = DataSnapshot._(result as JSObject);
  if (!snapshot.exists()) return null;
  return normalizeJson(snapshot.val()?.dartify());
}
