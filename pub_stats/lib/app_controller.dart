import 'dart:async';
import 'dart:js_interop';
import 'dart:math';

import 'package:web/web.dart' as web;

import 'database.dart';
import 'firebase.dart';
import 'models.dart';
import 'pub_client.dart';

final _discordWebhook = RegExp(r'https:\/\/discord\.com\/api\/webhooks\/(.+)\/(.+)');

bool isDiscordWebhook(String value) => _discordWebhook.hasMatch(value.trim());

bool isTelegramChatId(String value) => int.tryParse(value.trim()) != null;

final _publisherId = RegExp(r'^([a-z0-9-]{1,63}\.)+[a-z0-9-]{1,63}$');

bool isPublisherId(String value) {
  final name = value.trim().toLowerCase();
  return name.length <= 64 && _publisherId.hasMatch(name);
}

class AppController {
  AppController({StatsDatabase? database, PubClient? pub})
    : _database = database ?? StatsDatabase(),
      _pub = pub ?? PubClient();

  final StatsDatabase _database;
  final PubClient _pub;
  final _listeners = <void Function()>[];
  final _random = Random();
  final _namesByPrefix = <String, List<String>>{};

  var revision = 0;
  var ready = false;
  var loading = false;
  var namesReady = false;
  String? startupError;
  ThemePreference theme = ThemePreference.system;
  TimeSpan timeSpan = TimeSpan.month;
  GlobalStats? globalStats;
  List<PackageCount> packageCounts = [];
  List<PackageStats> loadedStats = [];
  List<String> settledPackages = [];
  Account? account;
  List<AlertConfig> alerts = [];
  var alertsLoaded = false;
  var alertsFailed = false;
  SnackMessage? snackbar;
  var popularityInfo = false;
  var licensesOpen = false;
  List<String>? packageDialog;
  String? packageDialogTitle;

  var _request = 0;
  var _alertsRequest = 0;
  var _loadingAlerts = false;
  List<String>? _pendingPackages;
  var _refreshPending = false;
  Timer? _snackTimer;
  StreamSubscription<web.Event>? _themeMedia;

  void addListener(void Function() listener) => _listeners.add(listener);

  void removeListener(void Function() listener) => _listeners.remove(listener);

  void notify() {
    revision++;
    for (final listener in List.of(_listeners)) {
      listener();
    }
  }

  Future<void> start() async {
    _restoreTheme();
    try {
      await initializeFirebase();
      firebase.auth().onAuthStateChanged(
        (JSAny? user) {
          unawaited(_onAuth(user));
        }.toJS,
      );
      globalStats = await _database.globalStats();
      packageCounts = await _database.packageCounts(timeSpan);
      ready = true;
      startupError = null;
    } catch (error) {
      startupError = '$error';
      ready = true;
    }
    notify();
    unawaited(_loadNames());
    final pending = _pendingPackages;
    if (pending != null && startupError == null) {
      _pendingPackages = null;
      await loadPackages(pending, refresh: _refreshPending);
      _refreshPending = false;
    }
  }

  void dispose() {
    _snackTimer?.cancel();
    unawaited(_themeMedia?.cancel());
  }

  bool settled(List<String> packages) => _samePackages(settledPackages, packages);

  bool _samePackages(List<String> left, List<String> right) {
    if (left.length != right.length) return false;
    for (var i = 0; i < left.length; i++) {
      if (left[i] != right[i]) return false;
    }
    return true;
  }

  Iterable<String> complete(String pattern) {
    final query = pattern.trim();
    if (query.isEmpty) return const [];
    final source = _namesByPrefix[query[0].toLowerCase()];
    if (source == null) return const [];
    final lower = query.toLowerCase();
    return source.where((name) => name.startsWith(lower)).take(5);
  }

  Future<void> loadPackages(List<String> packages, {bool refresh = false}) async {
    if (!ready || startupError != null) {
      _pendingPackages = packages;
      _refreshPending = refresh;
      return;
    }
    final request = ++_request;
    if (!refresh && settled(packages)) {
      if (loading) {
        loading = false;
        notify();
      }
      return;
    }
    if (packages.isEmpty) {
      loading = false;
      final changed = loadedStats.isNotEmpty || settledPackages.isNotEmpty;
      loadedStats = [];
      settledPackages = [];
      if (changed) notify();
      return;
    }
    if (packages.length > chartColors.length) {
      loading = false;
      snack('Cannot add more packages to compare');
      return;
    }

    loading = true;
    notify();

    final results = <PackageStats>[];
    for (final package in packages) {
      final stats = await _fetch(package, allowEmpty: refresh);
      if (request != _request) return;
      if (stats != null) {
        results.add(stats);
        if (!refresh) logSearch(package);
      }
    }

    if (request != _request) return;
    loading = false;
    if (results.isNotEmpty || !refresh) loadedStats = results;
    settledPackages = List.of(packages);
    notify();
  }

  Future<void> setTimeSpan(TimeSpan span) async {
    if (span == timeSpan) return;
    timeSpan = span;
    loading = true;
    notify();
    try {
      packageCounts = await _database.packageCounts(span);
    } catch (error) {
      snack('Unable to update package counts');
    }
    final packages = loadedStats.map((stats) => stats.package).toList();
    final requested = packages.isNotEmpty ? packages : settledPackages;
    if (requested.isNotEmpty) {
      await loadPackages(requested, refresh: true);
      return;
    }
    loading = false;
    notify();
  }

  String? randomPackage() {
    final names = _namesByPrefix.values.expand((names) => names).toList();
    if (names.isEmpty) {
      snack(namesReady ? 'No packages are available' : 'Package list is still loading');
      return null;
    }
    return names[_random.nextInt(names.length)];
  }

  Future<List<HistoryEntry>> history(String package, {String? endBefore}) {
    return _database.history(package, endBefore: endBefore);
  }

  Future<PackageStats?> _fetch(String package, {required bool allowEmpty}) async {
    try {
      final snapshots = await _database.scores(package, timeSpan);
      if (snapshots.isEmpty && !allowEmpty) {
        snack('No stats for $package in the selected time span');
        return null;
      }
      final scan = await _database.firstScan(package);
      final data = await _database.packageData(package);
      return PackageStats(package: package, stats: snapshots, firstScan: scan, data: data);
    } catch (error, stackTrace) {
      snack(
        'Unable to get stats for $package',
        actionLabel: 'COPY ERROR',
        action: () {
          unawaited(copy('Unable to get stats for $package\n$error\n$stackTrace'));
        },
      );
      return null;
    }
  }

  Future<void> _loadNames() async {
    try {
      final names = await _pub.packageNames();
      _namesByPrefix.clear();
      for (final name in names) {
        if (name.isEmpty) continue;
        (_namesByPrefix[name[0]] ??= []).add(name);
      }
      namesReady = true;
    } catch (_) {
      namesReady = true;
    }
  }

  Future<void> _onAuth(JSAny? user) async {
    if (user == null) {
      _resetAccount();
      return;
    }
    final current = FirebaseUser(user as JSObject);
    if (current.isAnonymous) {
      _resetAccount();
      return;
    }
    await _adopt(Account(uid: current.uid, name: current.displayName, photoUrl: current.photoURL));
  }

  void _resetAccount() {
    _alertsRequest++;
    _loadingAlerts = false;
    account = null;
    alerts = [];
    alertsLoaded = false;
    alertsFailed = false;
    notify();
  }

  Future<void> _adopt(Account next) async {
    final sameUser = account?.uid == next.uid;
    account = next;
    if (sameUser && (alertsLoaded || _loadingAlerts)) {
      notify();
      return;
    }
    final request = ++_alertsRequest;
    _loadingAlerts = true;
    alerts = [];
    alertsLoaded = false;
    notify();
    try {
      final loaded = await _database.alerts(next.uid);
      if (request != _alertsRequest) return;
      alerts = loaded;
      alertsLoaded = true;
      alertsFailed = false;
    } catch (error) {
      if (request != _alertsRequest) return;
      alertsLoaded = true;
      alertsFailed = true;
      snack('Unable to load alerts');
      return;
    } finally {
      if (request == _alertsRequest) _loadingAlerts = false;
    }
    notify();
  }

  void _commitAlerts(List<AlertConfig> next) {
    _alertsRequest++;
    _loadingAlerts = false;
    alerts = next;
    alertsLoaded = true;
    alertsFailed = false;
    notify();
  }

  Future<bool> signIn() async {
    try {
      await firebase.auth().signInWithPopup(GoogleAuthProvider()).toDart;
      final user = firebase.auth().currentUser;
      if (user == null || user.isAnonymous) return false;
      await _adopt(Account(uid: user.uid, name: user.displayName, photoUrl: user.photoURL));
      return account != null;
    } catch (error) {
      final message = error.toString();
      if (message.contains('popup-closed') || message.contains('cancelled')) return false;
      snack('Sign-in failed');
      return false;
    }
  }

  Future<void> signOut() async {
    await firebase.auth().signOut().toDart;
    await firebase.auth().signInAnonymously().toDart;
  }

  Future<bool> addAlert({
    required String slug,
    required String type,
    required String extra,
    required Set<String> ignore,
  }) async {
    final uid = account?.uid;
    if (uid == null || !alertsLoaded || alertsFailed) return false;
    final trimmed = slug.trim().toLowerCase();
    if (trimmed != '.system' && ignore.length >= packageFields.length) {
      snack('Choose at least one change');
      return false;
    }
    if (!await _validSlug(trimmed)) return false;

    final AlertConfig config;
    if (type == 'telegram') {
      final chatId = extra.trim();
      if (!isTelegramChatId(chatId)) {
        snack('Enter a numeric Telegram chat ID');
        return false;
      }
      config = TelegramAlert(slug: trimmed, ignore: ignore, chatId: chatId);
    } else {
      final match = _discordWebhook.firstMatch(extra.trim());
      if (match == null) {
        snack('Paste a discord.com/api/webhooks URL');
        return false;
      }
      config = DiscordAlert(slug: trimmed, ignore: ignore, id: match.group(1)!, token: match.group(2)!);
    }

    if (alerts.contains(config)) {
      snack('That alert already exists');
      return false;
    }

    final next = [...alerts, config];
    try {
      await _database.writeAlerts(uid, next);
    } catch (error) {
      snack('Unable to save alert');
      return false;
    }
    _commitAlerts(next);
    return true;
  }

  Future<void> removeAlert(int index) async {
    final uid = account?.uid;
    if (uid == null || index < 0 || index >= alerts.length) return;
    final removed = alerts[index];
    final next = [...alerts]..removeAt(index);
    try {
      await _database.writeAlerts(uid, next);
    } catch (error) {
      snack('Unable to delete alert');
      return;
    }
    _commitAlerts(next);
    snack(
      'Alert removed',
      actionLabel: 'Undo',
      action: () {
        dismissSnack();
        unawaited(_restoreAlert(removed, index));
      },
    );
  }

  Future<void> _restoreAlert(AlertConfig config, int index) async {
    final uid = account?.uid;
    if (uid == null) return;
    final next = [...alerts];
    next.insert(index.clamp(0, next.length), config);
    try {
      await _database.writeAlerts(uid, next);
    } catch (error) {
      snack('Unable to restore alert');
      return;
    }
    _commitAlerts(next);
  }

  Future<bool> _validSlug(String slug) async {
    if (slug.isEmpty) {
      snack('Enter a package or publisher');
      return false;
    }
    if (slug == '.system') return true;
    final parts = slug.split(':');
    if (parts.length == 1) {
      final exists = await _pub.packageExists(parts[0]);
      if (!exists) snack('Package does not exist');
      return exists;
    }
    if (parts.length == 2 && parts[1].isNotEmpty) {
      // pub.dev's publisher lookup sends no CORS headers, so the browser cannot read it.
      if (isPublisherId(parts[1])) return true;
      snack('Enter a publisher, like dart.dev');
      return false;
    }
    snack('Enter a package or publisher');
    return false;
  }

  void snack(String text, {String? actionLabel, void Function()? action}) {
    snackbar = SnackMessage(text: text, actionLabel: actionLabel, action: action);
    notify();
    _snackTimer?.cancel();
    _snackTimer = Timer(const Duration(seconds: 4), () {
      snackbar = null;
      notify();
    });
  }

  void dismissSnack() {
    _snackTimer?.cancel();
    snackbar = null;
    notify();
  }

  Future<void> copy(String text) async {
    await web.window.navigator.clipboard.writeText(text).toDart;
  }

  void showPopularityInfo() {
    popularityInfo = true;
    notify();
  }

  void showLicenses() {
    licensesOpen = true;
    notify();
  }

  void showPackages(String title, List<String> packages) {
    packageDialogTitle = title;
    packageDialog = packages;
    notify();
  }

  void closeDialog() {
    popularityInfo = false;
    licensesOpen = false;
    packageDialog = null;
    packageDialogTitle = null;
    notify();
  }

  void cycleTheme() {
    theme = switch (theme) {
      ThemePreference.system => ThemePreference.dark,
      ThemePreference.dark => ThemePreference.light,
      ThemePreference.light => ThemePreference.system,
    };
    web.window.localStorage.setItem('themeMode', theme.name);
    _applyTheme();
    notify();
  }

  void _restoreTheme() {
    final stored = web.window.localStorage.getItem('themeMode');
    theme = ThemePreference.values.asNameMap()[stored] ?? ThemePreference.system;
    _applyTheme();
    final media = web.window.matchMedia('(prefers-color-scheme: dark)');
    _themeMedia = web.EventStreamProviders.changeEvent.forTarget(media).listen((_) => _applyTheme());
  }

  void _applyTheme() {
    final dark = switch (theme) {
      ThemePreference.dark => true,
      ThemePreference.light => false,
      ThemePreference.system => web.window.matchMedia('(prefers-color-scheme: dark)').matches,
    };
    web.document.documentElement?.setAttribute('data-theme', dark ? 'dark' : 'light');
  }
}
