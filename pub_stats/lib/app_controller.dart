import 'dart:async';
import 'dart:convert';
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
const _sessionKey = 'pubstats.cache';

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
  var homeFailed = false;
  var countsLoaded = false;
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
  var _countsRequest = 0;
  var _alertsRequest = 0;
  var _loadingAlerts = false;
  List<String>? _pendingPackages;
  var _refreshPending = false;
  Timer? _snackTimer;
  StreamSubscription<web.Event>? _themeMedia;
  Future<void>? _namesTask;
  TimeSpan? _countsCoverage;
  TimeSpan? _statsCoverage;
  List<String> _inflightPackages = [];
  final _cachedPackages = <String, PackageStats>{};

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
    _restoreSession();
    try {
      await initializeFirebase();
      firebase.auth().onAuthStateChanged(
        (JSAny? user) {
          unawaited(_onAuth(user));
        }.toJS,
      );
      startupError = null;
    } catch (error) {
      startupError = '$error';
      ready = true;
      notify();
      return;
    }
    ready = true;
    notify();

    final pending = _pendingPackages;
    _pendingPackages = null;
    final refresh = _refreshPending;
    _refreshPending = false;
    final packages = pending == null ? null : loadPackages(pending, refresh: refresh);
    await Future.wait([_loadHome(), ?packages]);
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

  void ensureNames() {
    _namesTask ??= _loadNames();
  }

  List<PackageStats>? statsFor(List<String> packages) {
    if (settled(packages)) return loadedStats;
    return _cachedStats(packages);
  }

  List<PackageStats>? _cachedStats(List<String> packages) {
    if (packages.isEmpty || !_covers(_statsCoverage, timeSpan)) return null;
    final stats = <PackageStats>[];
    for (final package in packages) {
      final cached = _cachedPackages[package];
      if (cached == null) return null;
      stats.add(cached);
    }
    return stats;
  }

  Future<void> loadPackages(List<String> packages, {bool refresh = false}) async {
    if (!ready || startupError != null) {
      _pendingPackages = packages;
      _refreshPending = refresh;
      return;
    }
    if (!refresh && settled(packages)) return;
    if (packages.length > chartColors.length) {
      snack('Cannot add more packages to compare');
      return;
    }
    if (packages.isEmpty) {
      _finishEarly();
      loadedStats = [];
      settledPackages = [];
      notify();
      return;
    }

    final cached = !refresh ? _cachedStats(packages) : null;
    if (cached != null) {
      _finishEarly();
      loadedStats = cached;
      settledPackages = List.of(packages);
      for (final stats in cached) {
        logSearch(stats.package);
      }
      notify();
      return;
    }
    if (!refresh && _samePackages(_inflightPackages, packages)) return;

    final request = ++_request;
    final span = timeSpan;
    loading = true;
    _inflightPackages = List.of(packages);
    notify();
    try {
      final fetched = await Future.wait([
        for (final package in packages) _fetch(package, allowEmpty: refresh, span: span),
      ]);
      if (request != _request) return;
      final results = <PackageStats>[];
      for (final stats in fetched) {
        if (stats == null) continue;
        results.add(stats);
        if (!refresh) logSearch(stats.package);
      }
      if (results.isNotEmpty) {
        _statsCoverage = span;
        _cachedPackages
          ..clear()
          ..addEntries([for (final stats in results) MapEntry(stats.package, stats)]);
        _persistSession();
        loadedStats = results;
        settledPackages = List.of(packages);
      } else if (!refresh) {
        loadedStats = [];
        settledPackages = List.of(packages);
      }
    } finally {
      if (request == _request) {
        _inflightPackages = [];
        loading = false;
        notify();
      }
    }
  }

  void _finishEarly() {
    ++_request;
    _inflightPackages = [];
    loading = false;
  }

  Future<void> setTimeSpan(TimeSpan span) async {
    if (span == timeSpan) return;
    timeSpan = span;
    final packages = _packageNames();
    final needCounts = !_covers(_countsCoverage, span);
    final needStats = packages.isNotEmpty && !_covers(_statsCoverage, span);
    if (!needCounts && !needStats) {
      notify();
      return;
    }
    if (needCounts) countsLoaded = false;
    notify();
    await Future.wait([
      if (needCounts) _fetchCounts(span),
      if (needStats) loadPackages(packages, refresh: true),
    ]);
  }

  Future<String?> randomPackage() async {
    ensureNames();
    await _namesTask;
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

  Future<DateTime> firstScan(String package) => _database.firstScan(package);

  Future<void> _loadHome() {
    return Future.wait([
      if (globalStats == null) _loadGlobal(),
      if (!_covers(_countsCoverage, timeSpan)) _fetchCounts(timeSpan),
    ]);
  }

  Future<void> _loadGlobal() async {
    try {
      globalStats = await _database.globalStats();
      homeFailed = false;
      _persistSession();
      notify();
    } catch (_) {
      if (globalStats == null) {
        homeFailed = true;
        notify();
      }
    }
  }

  Future<void> _fetchCounts(TimeSpan span) async {
    final request = ++_countsRequest;
    try {
      final counts = await _database.packageCounts(span);
      if (request != _countsRequest) return;
      packageCounts = counts;
      _countsCoverage = span;
      countsLoaded = true;
      _persistSession();
    } catch (_) {
      if (request != _countsRequest) return;
      countsLoaded = true;
      snack('Unable to load package counts');
    }
    notify();
  }

  List<String> _packageNames() {
    if (loadedStats.isNotEmpty) return [for (final stats in loadedStats) stats.package];
    if (settledPackages.isNotEmpty) return List.of(settledPackages);
    return List.of(_inflightPackages);
  }

  bool _covers(TimeSpan? loaded, TimeSpan requested) {
    final loadedDays = loaded?.days;
    if (loaded == null) return false;
    if (loadedDays == null) return true;
    final requestedDays = requested.days;
    return requestedDays != null && loadedDays >= requestedDays;
  }

  Future<PackageStats?> _fetch(String package, {required bool allowEmpty, required TimeSpan span}) async {
    try {
      final results = await Future.wait<Object>([
        _database.scores(package, span),
        _database.packageData(package),
      ]);
      final snapshots = results[0] as List<ScoreSnapshot>;
      if (snapshots.isEmpty && !allowEmpty) {
        snack('No stats for $package in the selected time span');
        return null;
      }
      return PackageStats(package: package, stats: snapshots, data: results[1] as PackageData);
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
    notify();
  }

  void _restoreSession() {
    try {
      final raw = web.window.sessionStorage.getItem(_sessionKey);
      if (raw == null || raw.isEmpty) return;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return;
      final json = asStringMap(decoded);
      final global = json['global'];
      if (global is Map) globalStats = GlobalStats.fromJson(asStringMap(global));

      final counts = json['counts'];
      if (counts is Map) {
        final body = asStringMap(counts);
        final span = TimeSpan.values.asNameMap()[body['span']];
        final points = body['points'];
        if (span != null && points is List) {
          packageCounts = [
            for (final point in points)
              if (point is Map)
                PackageCount(
                  timestamp: DateTime.fromMillisecondsSinceEpoch((asStringMap(point)['t'] as num).toInt()),
                  count: (asStringMap(point)['c'] as num).toInt(),
                ),
          ]..sort((a, b) => a.timestamp.compareTo(b.timestamp));
          _countsCoverage = span;
          countsLoaded = _covers(span, timeSpan);
        }
      }

      final stats = json['stats'];
      if (stats is Map) {
        final body = asStringMap(stats);
        final span = TimeSpan.values.asNameMap()[body['span']];
        final packages = body['packages'];
        if (span != null && packages is Map) {
          for (final entry in packages.entries) {
            if (entry.value is! Map) continue;
            final item = asStringMap(entry.value);
            final data = item['data'];
            final points = item['points'];
            if (data is! Map || points is! List) continue;
            _cachedPackages[entry.key.toString()] = PackageStats(
              package: entry.key.toString(),
              data: PackageData.fromJson(asStringMap(data)),
              stats: [
                for (final point in points)
                  if (point is Map) ScoreSnapshot.fromJson(asStringMap(point)),
              ]..sort((a, b) => a.timestamp.compareTo(b.timestamp)),
            );
          }
          if (_cachedPackages.isNotEmpty) _statsCoverage = span;
        }
      }
    } catch (_) {}
  }

  void _persistSession() {
    try {
      final payload = <String, Object?>{
        if (globalStats case final stats?) 'global': stats.toJson(),
        if (_countsCoverage case final span?)
          'counts': {
            'span': span.name,
            'points': [
              for (final count in packageCounts) {'t': count.timestamp.millisecondsSinceEpoch, 'c': count.count},
            ],
          },
        if (_statsCoverage != null && _cachedPackages.isNotEmpty)
          'stats': {
            'span': _statsCoverage!.name,
            'packages': {
              for (final entry in _cachedPackages.entries)
                entry.key: {
                  'data': entry.value.data.toJson(),
                  'points': [for (final point in entry.value.stats) point.toJson()],
                },
            },
          },
      };
      web.window.sessionStorage.setItem(_sessionKey, jsonEncode(payload));
    } catch (_) {}
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
