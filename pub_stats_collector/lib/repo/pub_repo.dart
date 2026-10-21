import 'dart:async';
import 'dart:convert';

import 'package:fetch_client/fetch_client.dart';
import 'package:flutter_tools_task_queue/flutter_tools_task_queue.dart';
import 'package:pub_api_client/pub_api_client.dart' hide Credentials;
import 'package:pub_stats_collector/credential/credentials.ops.dart';
import 'package:pub_stats_collector/model/package_data_wrapper.dart';
import 'package:pub_stats_collector/model/pub_catalog.dart';
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

class PubRepo {
  static const _printInterval = 100;
  static const _catalogPageSize = 100;
  static final _http = UndiciClient();

  final _client = PubClient(client: _http, userAgent: Credentials.userAgent);
  final _fetchClient = PubClient(
    client: FetchClient(),
    userAgent: Credentials.userAgent,
  );

  // Prevent too many concurrent calls to the pub API
  final _queue = TaskQueue(maxJobs: 100);

  Future<GlobalStats> fetchAllData(
    Future<void> Function(
      String package,
      PackageScore score,
      PackageData data,
      Set<String> failedPackages,
    )
    handleData,
  ) async {
    var mostLikedPackage = ('', 0);
    var mostDownloadedPackage = ('', 0);

    var mostDependedPackage = ('', 0);

    // The paged package list skips packages, so package-names decides what to
    // fetch and the paged list only saves fetching each package's info.
    // Its length is also the catalog page count, so the catalog fetch starts
    // after the name list and requests exactly those pages.
    final packages = await _fetchClient.packageNames();
    print('Fetched ${packages.length} package names');
    final catalog = await _fetchCatalog(packages.length);
    print(
      '${packages.where((e) => !catalog.containsKey(e)).length} packages are '
      'missing from the package catalog',
    );

    final wrappers = <PackageDataWrapper>[];
    final dependentMap = <String, Set<String>>{};
    final failedPackages = <String>{};
    var fetched = 0;

    Future<void> fetchPackageData(String package) async {
      final latest = catalog[package] ?? await _fetchLatest(package);
      final score = await _client.packageScore(package);

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

      for (final dependency in latest.dependencies) {
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

    for (final package in packages) {
      unawaited(
        _queue.add(() async {
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
    await _queue.tasksComplete;
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
        _queue.add(() async {
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
    await _queue.tasksComplete;
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

  /// Map of package name to its latest version info
  Future<Map<String, LatestPackage>> _fetchCatalog(int packageCount) async {
    final catalog = <String, LatestPackage>{};
    final lastPage = (packageCount / _catalogPageSize).ceil();

    Future<void> fetchPage(int page) async {
      try {
        final response = await _http.get(
          Uri.https('pub.dev', '/api/packages', {'page': '$page'}),
          headers: {'user-agent': Credentials.userAgent},
        );
        // The name list can be a page ahead of the catalog
        if (response.statusCode == 400) return;
        if (response.statusCode != 200) {
          throw Exception(
            'Package list request failed for page $page (${response.statusCode})',
          );
        }

        final catalogPage = PubCatalogPage.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
        for (final package in catalogPage.packages) {
          catalog[package.name] = package.latest;
        }
      } catch (e) {
        // Packages on a failed page are fetched individually
        print('Error fetching package list page $page: $e');
      }
    }

    for (var page = 1; page <= lastPage; page++) {
      unawaited(_queue.add(() => fetchPage(page)));
    }
    await _queue.tasksComplete;
    return catalog;
  }

  Future<LatestPackage> _fetchLatest(String package) async {
    final response = await _http.get(
      Uri.https('pub.dev', '/api/packages/$package'),
      headers: {'user-agent': Credentials.userAgent},
    );
    if (response.statusCode != 200) {
      throw Exception(
        'Package info request failed for $package (${response.statusCode})',
      );
    }

    return PubCatalogPackage.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    ).latest;
  }
}
