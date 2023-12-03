import 'dart:async';

import 'package:flutter_tools_task_queue/flutter_tools_task_queue.dart';
import 'package:pub_api_client/pub_api_client.dart' hide Credentials;
import 'package:pub_stats_collector/credential/credentials.dart';
import 'package:pub_stats_collector/model/package_data_wrapper.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

class PubRepo {
  final PubClient _client;

  PubRepo(Credentials credentials)
      : _client = PubClient(client: UserAgentClient(credentials.userAgent));

  Future<GlobalStats> fetchAllData(
    Future<void> Function(PackageMetrics metrics, PackageData data) handleData,
  ) async {
    final packages = await _client.packageNames();
    print('Fetched ${packages.length} package names');

    var mostLikedPackage = ('', 0);
    var mostPopularPackage = ('', 0.0);
    var mostDependedPackage = ('', 0);

    final wrappers = <PackageDataWrapper>[];
    final dependentMap = <String, Set<String>>{};
    var fetched = 0;
    Future<void> fetchPackageData(String package) async {
      final metrics = await _client.packageMetrics(package);
      if (metrics == null) {
        print('No metrics for $package');
        return;
      }

      final popularityScore = metrics.score.popularityScore;
      final int popularityPercent;
      if (popularityScore != null) {
        popularityPercent = (popularityScore * 100).round();
      } else {
        print('No popularity score for $package');
        return;
      }

      final likeCount = metrics.score.likeCount;
      if (likeCount > mostLikedPackage.$2) {
        print('Most liked package: $package');
        mostLikedPackage = (package, likeCount);
      }
      if (popularityScore > mostPopularPackage.$2) {
        print('Most popular package: $package');
        mostPopularPackage = (package, popularityScore);
      }

      final publisherData = await _client.packagePublisher(package);
      final publisher = publisherData.publisherId;
      final packageOptions = await _client.packageOptions(package);

      final isFlutterFavorite =
          metrics.score.tags.contains(PackageTag.isFlutterFavorite);

      final info = await _client.packageInfo(package);
      final dependencies = info.latestPubspec.allDependencies.keys;
      for (final dependency in dependencies) {
        dependentMap.update(
          dependency,
          (value) => value..add(package),
          ifAbsent: () => {package},
        );
      }

      wrappers.add(
        PackageDataWrapper(
          metrics,
          PackageData(
            publisher: publisher,
            version: metrics.scorecard.packageVersion,
            likeCount: metrics.score.likeCount,
            popularityScore: popularityPercent,
            isDiscontinued: packageOptions.isDiscontinued,
            isFlutterFavorite: isFlutterFavorite,
            isUnlisted: packageOptions.isUnlisted,
          ),
        ),
      );

      fetched++;
      if (fetched % 100 == 0) {
        print('Fetched $fetched/${packages.length} packages');
      }
    }

    final queue = TaskQueue(maxJobs: 100);
    for (final package in packages) {
      unawaited(
        queue.add(() async {
          try {
            await fetchPackageData(package);
          } catch (e) {
            print('Error fetching data for $package: $e');
          }
        }),
      );
    }
    await queue.tasksComplete;
    print('Fetched all data');

    var handled = 0;
    Future<void> handleWrapper(PackageDataWrapper wrapper) async {
      final metrics = wrapper.metrics;
      final package = metrics.scorecard.packageName;

      final dependents = dependentMap[package] ?? {};
      final data = wrapper.data.copyWith(dependents: dependents);

      if (dependents.length > mostDependedPackage.$2) {
        print('Most depended package: $package');
        mostDependedPackage = (package, dependents.length);
      }

      await handleData(metrics, data).timeout(
        Duration(seconds: 30),
        onTimeout: () =>
            throw TimeoutException('Timeout handling wrapper for $package'),
      );

      handled++;
      if (handled % 100 == 0) {
        print('Handled $handled/${packages.length} packages');
      }
    }

    for (final wrapper in wrappers) {
      unawaited(
        queue.add(() async {
          final package = wrapper.metrics.scorecard.packageName;
          try {
            await handleWrapper(wrapper);
          } catch (e) {
            print('Error handling wrapper $package: $e');
          }
        }),
      );
    }
    await queue.tasksComplete;
    print('Handled all wrappers');

    return GlobalStats(
      packageCount: packages.length,
      mostLikedPackage: mostLikedPackage.$1,
      mostPopularPackage: mostPopularPackage.$1,
      mostDependedPackage: mostDependedPackage.$1,
      lastUpdated: DateTime.timestamp(),
    );
  }
}
