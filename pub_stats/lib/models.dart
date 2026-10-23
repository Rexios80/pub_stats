import 'package:equatable/equatable.dart';

import 'format.dart';

const chartColors = [
  '#5AB3F0',
  '#8884d8',
  '#82ca9d',
  '#ffc658',
  '#d0ed57',
  '#ffa726',
  '#ec407a',
  '#ab47bc',
  '#26a69a',
  '#8d6e63',
  '#bdbdbd',
];

const packageFields = [
  'publisher',
  'version',
  'likeCount',
  'popularityScore',
  'downloadCount',
  'isDiscontinued',
  'isUnlisted',
  'isFlutterFavorite',
  'dependents',
  'pubPoints',
];

enum TimeSpan {
  week(7, 'Week'),
  month(30, 'Month'),
  quarter(90, 'Quarter'),
  year(365, 'Year'),
  all(null, 'All');

  const TimeSpan(this.days, this.label);

  final int? days;
  final String label;

  bool contains(DateTime date) {
    final days = this.days;
    if (days == null) return true;
    return DateTime.timestamp().difference(date).inDays <= days;
  }

  DateTime get start {
    final days = this.days;
    if (days == null) return DateTime.fromMillisecondsSinceEpoch(0);
    final now = DateTime.timestamp();
    return DateTime(now.year, now.month, now.day).subtract(Duration(days: days));
  }

  String get hoursStart => (start.millisecondsSinceEpoch ~/ 3600000).toString();

  String get secondsStart => (start.millisecondsSinceEpoch / 1000).round().toString();
}

enum ThemePreference { system, dark, light }

enum BadgeKind { popularity, rank, dependents }

class GlobalStats {
  const GlobalStats({
    required this.packageCount,
    required this.topPackage,
    required this.mostLikedPackage,
    required this.mostDownloadedPackage,
    required this.mostDependedPackage,
    required this.lastUpdated,
  });

  final int packageCount;
  final String topPackage;
  final String mostLikedPackage;
  final String mostDownloadedPackage;
  final String mostDependedPackage;
  final DateTime lastUpdated;

  factory GlobalStats.fromJson(Map<String, dynamic> json) {
    return GlobalStats(
      packageCount: (json['packageCount'] as num?)?.toInt() ?? 0,
      topPackage: json['topPackage'] as String? ?? 'N/A',
      mostLikedPackage: json['mostLikedPackage'] as String? ?? 'N/A',
      mostDownloadedPackage: json['mostDownloadedPackage'] as String? ?? 'N/A',
      mostDependedPackage: json['mostDependedPackage'] as String? ?? 'N/A',
      lastUpdated: json['lastUpdated'] == null ? DateTime.timestamp() : DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'packageCount': packageCount,
    'topPackage': topPackage,
    'mostLikedPackage': mostLikedPackage,
    'mostDownloadedPackage': mostDownloadedPackage,
    'mostDependedPackage': mostDependedPackage,
    'lastUpdated': lastUpdated.toIso8601String(),
  };
}

class ScoreSnapshot {
  const ScoreSnapshot({
    required this.timestamp,
    required this.likeCount,
    required this.legacyPopularityScore,
    required this.popularityScore,
    required this.downloadCount,
  });

  final DateTime timestamp;
  final int likeCount;
  final int? legacyPopularityScore;
  final int? popularityScore;
  final int? downloadCount;

  factory ScoreSnapshot.fromEntry(String key, Object? value) {
    final timestamp = timeFromStatKey(key);
    if (value is Map && value.keys.any((item) => int.tryParse(item.toString()) == null)) {
      final json = asStringMap(value);
      return ScoreSnapshot(
        timestamp: timestamp,
        likeCount: (json['l'] as num?)?.toInt() ?? 0,
        legacyPopularityScore: (json['p'] as num?)?.toInt(),
        popularityScore: (json['p2'] as num?)?.toInt(),
        downloadCount: (json['d'] as num?)?.toInt(),
      );
    }

    final json = asList(value);
    int? decode(Object? item) {
      if (item == null) return null;
      final decoded = (item as num).toInt();
      return decoded == -1 ? null : decoded;
    }

    return ScoreSnapshot(
      timestamp: timestamp,
      likeCount: (json[0] as num).toInt(),
      legacyPopularityScore: decode(_at(json, 1)),
      popularityScore: decode(_at(json, 2)),
      downloadCount: decode(_at(json, 3)),
    );
  }

  factory ScoreSnapshot.fromJson(Map<String, dynamic> json) {
    return ScoreSnapshot(
      timestamp: DateTime.fromMillisecondsSinceEpoch((json['t'] as num).toInt()),
      likeCount: (json['l'] as num?)?.toInt() ?? 0,
      legacyPopularityScore: (json['p'] as num?)?.toInt(),
      popularityScore: (json['p2'] as num?)?.toInt(),
      downloadCount: (json['d'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    't': timestamp.millisecondsSinceEpoch,
    'l': likeCount,
    'p': legacyPopularityScore,
    'p2': popularityScore,
    'd': downloadCount,
  };
}

/// Score keys are hours since epoch, except older exports that used unix seconds.
DateTime timeFromStatKey(String key) {
  final value = int.parse(key);
  final millis = value >= 1000000000 ? value * 1000 : value * 3600 * 1000;
  return DateTime.fromMillisecondsSinceEpoch(millis);
}

bool statKeyIsSeconds(String key) => int.parse(key) >= 1000000000;

class PackageCount {
  const PackageCount({required this.timestamp, required this.count});

  final DateTime timestamp;
  final int count;
}

class PackageData {
  const PackageData({
    required this.publisher,
    required this.version,
    required this.likeCount,
    required this.legacyPopularityScore,
    required this.popularityScore,
    required this.downloadCount,
    required this.isDiscontinued,
    required this.isUnlisted,
    required this.isFlutterFavorite,
    required this.overallRank,
    required this.numDependents,
  });

  final String? publisher;
  final String version;
  final int likeCount;
  final int? legacyPopularityScore;
  final int? popularityScore;
  final int? downloadCount;
  final bool isDiscontinued;
  final bool isUnlisted;
  final bool isFlutterFavorite;
  final int? overallRank;
  final int? numDependents;

  factory PackageData.fromJson(Map<String, dynamic> json) {
    return PackageData(
      publisher: json['p'] as String?,
      version: json['v'] as String? ?? '',
      likeCount: (json['lc'] as num?)?.toInt() ?? 0,
      legacyPopularityScore: (json['ps'] as num?)?.toInt(),
      popularityScore: (json['ps2'] as num?)?.toInt(),
      downloadCount: (json['dc'] as num?)?.toInt(),
      isDiscontinued: json['id'] == true,
      isUnlisted: json['iu'] == true,
      isFlutterFavorite: json['iff'] == true,
      overallRank: (json['n'] as num?)?.toInt(),
      numDependents: (json['nd'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
    'p': publisher,
    'v': version,
    'lc': likeCount,
    'ps': legacyPopularityScore,
    'ps2': popularityScore,
    'dc': downloadCount,
    'id': isDiscontinued,
    'iu': isUnlisted,
    'iff': isFlutterFavorite,
    'n': overallRank,
    'nd': numDependents,
  };
}

class PackageStats {
  const PackageStats({required this.package, required this.stats, required this.data});

  final String package;
  final List<ScoreSnapshot> stats;
  final PackageData data;
}

class HistoryEntry {
  const HistoryEntry({required this.timestamp, required this.changes});

  final DateTime timestamp;
  final List<FieldChange> changes;
}

class FieldChange {
  const FieldChange({required this.field, required this.text, this.added = const {}, this.removed = const {}});

  final String field;
  final String text;
  final Set<String> added;
  final Set<String> removed;

  bool get isSet => field == 'dependents';

  factory FieldChange.fromJson(String field, Map<String, dynamic> json) {
    if (field == 'dependents') {
      final added = _stringSet(json['added']);
      final removed = _stringSet(json['removed']);
      return FieldChange(field: field, text: '', added: added, removed: removed);
    }
    if (field == 'downloadCount') {
      final before = json['before'] as num?;
      final after = json['after'] as num?;
      return FieldChange(field: field, text: '${formatLargeNum(before)} -> ${formatLargeNum(after)}');
    }
    return FieldChange(field: field, text: '${json['before']} -> ${json['after']}');
  }
}

class Account {
  const Account({required this.uid, required this.name, required this.photoUrl});

  final String uid;
  final String? name;
  final String? photoUrl;
}

sealed class AlertConfig extends Equatable {
  const AlertConfig({required this.slug, required this.ignore});

  final String slug;
  final Set<String> ignore;

  String get type;
  String get extra;

  Map<String, dynamic> toJson();

  @override
  List<Object?> get props => [slug, ignore];

  factory AlertConfig.fromJson(Map<String, dynamic> json) {
    final ignore = (json['ignore'] as List?)?.map((item) => item.toString()).toSet() ?? {};
    return switch (json['type']) {
      'telegram' => TelegramAlert(
        slug: json['slug'] as String? ?? '',
        ignore: ignore,
        chatId: json['chatId'] as String? ?? '',
      ),
      _ => DiscordAlert(
        slug: json['slug'] as String? ?? '',
        ignore: ignore,
        id: json['id'] as String? ?? '',
        token: json['token'] as String? ?? '',
      ),
    };
  }
}

class DiscordAlert extends AlertConfig {
  const DiscordAlert({required super.slug, required super.ignore, required this.id, required this.token});

  final String id;
  final String token;

  @override
  String get type => 'discord';

  @override
  String get extra => id;

  @override
  List<Object?> get props => [...super.props, id, token];

  @override
  Map<String, dynamic> toJson() => {
    'slug': slug,
    'ignore': ignore.toList(),
    'type': type,
    'id': id,
    'token': token,
  };
}

class TelegramAlert extends AlertConfig {
  const TelegramAlert({required super.slug, required super.ignore, required this.chatId});

  final String chatId;

  @override
  String get type => 'telegram';

  @override
  String get extra => chatId;

  @override
  List<Object?> get props => [...super.props, chatId];

  @override
  Map<String, dynamic> toJson() => {'slug': slug, 'ignore': ignore.toList(), 'type': type, 'chatId': chatId};
}

class SnackMessage {
  const SnackMessage({required this.text, this.actionLabel, this.action});

  final String text;
  final String? actionLabel;
  final void Function()? action;
}

Set<String> _stringSet(Object? value) {
  if (value is! List) return {};
  return value.map((item) => item.toString()).toSet();
}

Object? _at(List<dynamic> list, int index) => index < list.length ? list[index] : null;

List<dynamic> asList(Object? value) {
  if (value is List) return value;
  if (value is Map) {
    final entries = value.entries.toList()
      ..sort((a, b) => int.parse(a.key.toString()).compareTo(int.parse(b.key.toString())));
    return entries.map((entry) => entry.value).toList();
  }
  throw FormatException('Expected a list');
}

Map<String, dynamic> asStringMap(Object? value) {
  if (value is! Map) return {};
  return value.map((key, item) => MapEntry(key.toString(), item));
}
