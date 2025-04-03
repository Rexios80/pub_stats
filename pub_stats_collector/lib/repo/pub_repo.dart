import 'dart:async';

import 'package:fetch_client/fetch_client.dart';
import 'package:flutter_tools_task_queue/flutter_tools_task_queue.dart';
import 'package:pub_api_client/pub_api_client.dart' hide Credentials;
import 'package:pub_stats_collector/credential/credentials.dart';
import 'package:pub_stats_collector/model/package_data_wrapper.dart';
import 'package:pub_stats_collector/service/undici_client.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

class PubRepo {
  static const _printInterval = 100;

  final _client = PubClient(
    client: UndiciClient(),
    userAgent: Credentials.userAgent,
  );
  final _fetchClient = PubClient(
    client: FetchClient(),
    userAgent: Credentials.userAgent,
  );

  Future<GlobalStats> fetchAllData(
    Future<void> Function(String package, PackageScore score, PackageData data)
    handleData,
  ) async {
    final packages = (await _fetchClient.packageNames()).take(100).toList();
    print('Fetched ${packages.length} package names');

    var mostLikedPackage = ('', 0);
    var mostDependedPackage = ('', 0);

    final wrappers = <PackageDataWrapper>[];
    final dependentMap = <String, Set<String>>{};
    var fetched = 0;

    // Prevent too many concurrent calls to the pub API
    final pubQueue = TaskQueue(maxJobs: 100);
    Future<void> fetchPackageData(String package) async {
      final result = await Future.wait([
        pubQueue.add(() => _client.packageScore(package)),
        pubQueue.add(() => _client.packagePublisher(package)),
        pubQueue.add(() => _client.packageOptions(package)),
        pubQueue.add(() => _client.packageInfo(package)),
      ]);

      final score = result[0] as PackageScore;
      final publisherData = result[1] as PackagePublisher;
      final packageOptions = result[2] as PackageOptions;
      final info = result[3] as PubPackage;

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

      final publisher = publisherData.publisherId;
      final isFlutterFavorite = score.tags.contains(
        PackageTag.isFlutterFavorite,
      );

      final dependencies = {
        ...info.latestPubspec.dependencies.keys,
        ...info.latestPubspec.devDependencies.keys,
      };
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
            version: info.version,
            likeCount: likeCount,
            legacyPopularityScore: popularityPercent,
            downloadCount: score.downloadCount30Days,
            isDiscontinued: packageOptions.isDiscontinued,
            isFlutterFavorite: isFlutterFavorite,
            isUnlisted: packageOptions.isUnlisted,
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
              onTimeout:
                  () =>
                      throw TimeoutException(
                        'Timeout fetching data for $package',
                      ),
            );
          } catch (e, s) {
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

      await handleData(package, score, data).timeout(
        Duration(seconds: 30),
        onTimeout:
            () =>
                throw TimeoutException('Timeout handling wrapper for $package'),
      );

      handled++;
      if (handled % _printInterval == 0) {
        print('Handled $handled/${packages.length} packages');
      }
    }

    double calculateScore(int index) =>
        (wrappers.length - index) / wrappers.length;

    wrappers.sort((a, b) {
      final adc = a.score.downloadCount30Days ?? 0;
      final bdc = b.score.downloadCount30Days ?? 0;
      return bdc.compareTo(adc);
    });

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

    downloadedWrappers.sort((a, b) {
      final alc = a.score.likeCount;
      final blc = b.score.likeCount;
      return blc.compareTo(alc);
    });

    final likedWrappers = <PackageDataWrapper>[];
    for (var i = 0; i < downloadedWrappers.length; i++) {
      final wrapper = downloadedWrappers[i];
      likedWrappers.add(wrapper.copyWith(likeScore: calculateScore(i)));
    }

    likedWrappers.sort((a, b) {
      final ao = a.overallScore;
      final bo = b.overallScore;
      return bo.compareTo(ao);
    });

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

    overallWrappers.sort((a, b) => b.overallScore.compareTo(a.overallScore));

    return GlobalStats(
      packageCount: packages.length,
      topPackage: overallWrappers.first.package,
      mostLikedPackage: mostLikedPackage.$1,
      mostDownloadedPackage: wrappers.first.package,
      mostDependedPackage: mostDependedPackage.$1,
      lastUpdated: DateTime.timestamp(),
    );
  }
}
