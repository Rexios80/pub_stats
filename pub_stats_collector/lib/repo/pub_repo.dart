import 'dart:async';
import 'dart:convert';

import 'package:fetch_client/fetch_client.dart';
import 'package:flutter_tools_task_queue/flutter_tools_task_queue.dart';
import 'package:pub_api_client/pub_api_client.dart' hide Credentials;
import 'package:pub_stats_collector/credential/credentials.ops.dart';
import 'package:pub_stats_collector/model/package_data_wrapper.dart';
import 'package:pub_stats_collector/service/undici_client.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

int _byScoreThenName(
  PackageDataWrapper a,
  PackageDataWrapper b,
  num Function(PackageDataWrapper wrapper) score,
) {
  final byScore = score(b).compareTo(score(a));
  if (byScore != 0) return byScore;
  return a.package.compareTo(b.package);
}

class _LatestPackage({
  required final String version,
  required final Set<String> dependencies,
});

class PubRepo {
  static const _printInterval = 100;
  static final _http = UndiciClient();

  final _client = PubClient(client: _http, userAgent: Credentials.userAgent);
  final _fetchClient = PubClient(
    client: FetchClient(),
    userAgent: Credentials.userAgent,
  );

  Future<GlobalStats> fetchAllData(
    Future<void> Function(
      String package,
      PackageScore score,
      PackageData data,
      Set<String> failedPackages,
    )
    handleData,
  ) async {
    final packages = await _fetchClient.packageNames();
    print('Fetched ${packages.length} package names');

    var mostLikedPackage = ('', 0);
    var mostDownloadedPackage = ('', 0);

    var mostDependedPackage = ('', 0);

    final wrappers = <PackageDataWrapper>[];
    final dependentMap = <String, Set<String>>{};
    final failedPackages = <String>{};
    var fetched = 0;

    // Prevent too many concurrent calls to the pub API
    final pubQueue = TaskQueue(maxJobs: 100);
    Future<void> fetchPackageData(String package) async {
      final result = await Future.wait([
        pubQueue.add(() => _client.packageScore(package)),
        pubQueue.add(() => _fetchLatest(package)),
      ]);
      final score = result[0] as PackageScore;
      final latest = result[1] as _LatestPackage;

      final popularityScore = score.popularityScore;
      final int? popularityPercent;
      if (popularityScore != null) {
        popularityPercent = (popularityScore * 100).round();
      } else {
        popularityPercent = null;
      }

      final likeCount = score.likeCount;
      if (likeCount > mostLikedPackage.$2) {
        print('Most liked package: $package');
        mostLikedPackage = (package, likeCount);
      }

      final downloadCount = score.downloadCount30Days ?? 0;
      if (downloadCount > mostDownloadedPackage.$2) {
        print('Most downloaded package: $package');
        mostDownloadedPackage = (package, downloadCount);
      }

      final publisher = score.tags
          .where((tag) => tag.startsWith('publisher:'))
          .firstOrNull
          ?.substring('publisher:'.length);
      final isFlutterFavorite = score.tags.contains(
        PackageTag.isFlutterFavorite,
      );
      final isDiscontinued = score.tags.contains(
        PackageTag.isTag('discontinued'),
      );
      final isUnlisted = score.tags.contains(PackageTag.isTag('unlisted'));

      final dependencies = latest.dependencies;
      for (final dependency in dependencies) {
        dependentMap.update(
          dependency,
          (value) => value..add(package),
          ifAbsent: () => {package},
        );
      }

      wrappers.add(
        PackageDataWrapper(
          package,
          score,
          PackageData(
            publisher: publisher,
            version: latest.version,
            likeCount: likeCount,
            legacyPopularityScore: popularityPercent,
            downloadCount: score.downloadCount30Days,
            isDiscontinued: isDiscontinued,
            isFlutterFavorite: isFlutterFavorite,
            isUnlisted: isUnlisted,
          ),
        ),
      );

      fetched++;
      if (fetched % _printInterval == 0) {
        print('Fetched $fetched/${packages.length} packages');
      }
    }

    final workQueue = TaskQueue(maxJobs: 100);
    for (final package in packages) {
      unawaited(
        workQueue.add(() async {
          try {
            await fetchPackageData(package).timeout(
              Duration(seconds: 30),
              onTimeout: () =>
                  throw TimeoutException('Timeout fetching data for $package'),
            );
          } catch (e, s) {
            failedPackages.add(package);
            print('Error fetching data for $package: $e');
            print(s);
          }
        }),
      );
    }
    await workQueue.tasksComplete;
    print('Fetched all data');

    var handled = 0;
    Future<void> handleWrapper(PackageDataWrapper wrapper) async {
      final score = wrapper.score;
      final package = wrapper.package;

      final dependents = dependentMap[package] ?? {};
      final data = wrapper.data.copyWith(
        dependents: dependents,
        numDependents: dependents.length,
      );

      if (dependents.length > mostDependedPackage.$2) {
        print('Most depended package: $package');
        mostDependedPackage = (package, dependents.length);
      }

      await handleData(package, score, data, failedPackages).timeout(
        Duration(seconds: 30),
        onTimeout: () =>
            throw TimeoutException('Timeout handling wrapper for $package'),
      );

      handled++;
      if (handled % _printInterval == 0) {
        print('Handled $handled/${packages.length} packages');
      }
    }

    double calculateScore(int index) =>
        (wrappers.length - index) / wrappers.length;

    wrappers.sort(
      (a, b) => _byScoreThenName(
        a,
        b,
        (wrapper) => wrapper.score.downloadCount30Days ?? 0,
      ),
    );

    final downloadedWrappers = <PackageDataWrapper>[];
    for (var i = 0; i < wrappers.length; i++) {
      final wrapper = wrappers[i];
      final score = calculateScore(i);
      downloadedWrappers.add(
        wrapper.copyWith(
          data: wrapper.data.copyWith(popularityScore: (score * 100).round()),
          downloadScore: score,
        ),
      );
    }

    downloadedWrappers.sort(
      (a, b) => _byScoreThenName(a, b, (wrapper) => wrapper.score.likeCount),
    );

    final likedWrappers = <PackageDataWrapper>[];
    for (var i = 0; i < downloadedWrappers.length; i++) {
      final wrapper = downloadedWrappers[i];
      likedWrappers.add(wrapper.copyWith(likeScore: calculateScore(i)));
    }

    likedWrappers.sort(
      (a, b) => _byScoreThenName(a, b, (wrapper) => wrapper.overallScore),
    );

    final topPackage = likedWrappers.first.package;

    final overallWrappers = <PackageDataWrapper>[];
    for (var i = 0; i < likedWrappers.length; i++) {
      final wrapper = likedWrappers[i];
      overallWrappers.add(
        wrapper.copyWith(data: wrapper.data.copyWith(overallRank: i)),
      );
    }

    overallWrappers.sort((a, b) => a.package.compareTo(b.package));

    for (final wrapper in overallWrappers) {
      unawaited(
        workQueue.add(() async {
          final package = wrapper.package;
          try {
            await handleWrapper(wrapper);
          } catch (e, s) {
            print('Error handling wrapper $package: $e');
            print(s);
          }
        }),
      );
    }
    await workQueue.tasksComplete;
    print('Handled all wrappers');

    return GlobalStats(
      packageCount: packages.length,
      topPackage: topPackage,
      mostLikedPackage: mostLikedPackage.$1,
      mostDownloadedPackage: mostDownloadedPackage.$1,
      mostDependedPackage: mostDependedPackage.$1,
      lastUpdated: DateTime.timestamp(),
    );
  }

  Future<_LatestPackage> _fetchLatest(String package) async {
    final response = await _http.get(
      Uri.https('pub.dev', '/api/packages/$package'),
      headers: {'user-agent': Credentials.userAgent},
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Package info request failed for $package (${response.statusCode})',
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final latest = json['latest'] as Map<String, dynamic>;
    final pubspec = latest['pubspec'] as Map<String, dynamic>;
    return _LatestPackage(
      version: latest['version'] as String,
      dependencies: {
        for (final key in ['dependencies', 'dev_dependencies'])
          ...?(pubspec[key] as Map?)?.keys.cast<String>(),
      },
    );
  }
}
