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
    final packages = await _fetchClient.packageNames();
    print('Fetched ${packages.length} package names');

    var mostLikedPackage = ('', 0);
    var mostDownloadedPackage = ('', 0);

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

      final downloadCount = score.downloadCount30Days ?? 0;
      if (downloadCount > mostDownloadedPackage.$2) {
        print('Most downloaded package: $package');
        mostDownloadedPackage = (package, downloadCount);
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

    final maxLikeCount = mostLikedPackage.$2;
    final maxDownloadCount = mostDownloadedPackage.$2;

    final scoredWrappers = <PackageDataWrapper>[];

    // Apply normalization to each package
    for (final wrapper in wrappers) {
      final downloadCount = wrapper.score.downloadCount30Days ?? 0;
      final likeCount = wrapper.score.likeCount;

      final downloadScore = downloadCount / maxDownloadCount;
      final likeScore = likeCount / maxLikeCount;

      scoredWrappers.add(
        wrapper.copyWith(
          data: wrapper.data.copyWith(
            popularityScore: (downloadScore * 100).round(),
          ),
          downloadScore: downloadScore,
          likeScore: likeScore,
        ),
      );
    }

    // Sort by overall score
    scoredWrappers.sort((a, b) {
      final ao = a.overallScore;
      final bo = b.overallScore;
      return bo.compareTo(ao);
    });

    final topPackage = scoredWrappers.first.package;

    // Add ranking information
    final rankedWrappers = <PackageDataWrapper>[];
    for (var i = 0; i < scoredWrappers.length; i++) {
      final wrapper = scoredWrappers[i];
      rankedWrappers.add(
        wrapper.copyWith(data: wrapper.data.copyWith(overallRank: i)),
      );
    }

    // Sort by package name for final output
    rankedWrappers.sort((a, b) => a.package.compareTo(b.package));

    for (final wrapper in rankedWrappers) {
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
}
