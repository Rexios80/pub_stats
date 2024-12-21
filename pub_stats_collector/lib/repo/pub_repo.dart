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
    Future<void> Function(
      String package,
      PackageScore score,
      PackageData data,
    ) handleData,
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
      final score = await _client.packageScore(package);

      final popularityScore = score.popularityScore;
      final int popularityPercent;
      if (popularityScore != null) {
        popularityPercent = (popularityScore * 100).round();
      } else {
        print('No popularity score for $package');
        return;
      }

      final likeCount = score.likeCount;
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
          score.tags.contains(PackageTag.isFlutterFavorite);

      final info = await _client.packageInfo(package);
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
      final score = wrapper.score;
      final package = wrapper.package;

      final dependents = dependentMap[package] ?? {};
      final data = wrapper.data.copyWith(dependents: dependents);

      if (dependents.length > mostDependedPackage.$2) {
        print('Most depended package: $package');
        mostDependedPackage = (package, dependents.length);
      }

      await handleData(package, score, data).timeout(
        Duration(seconds: 30),
        onTimeout: () =>
            throw TimeoutException('Timeout handling wrapper for $package'),
      );

      handled++;
      if (handled % 100 == 0) {
        print('Handled $handled/${packages.length} packages');
      }
    }

    wrappers.sort((a, b) {
      final aScore = a.score.popularityScore ?? double.infinity;
      final bScore = b.score.popularityScore ?? double.infinity;
      return bScore.compareTo(aScore);
    });

    final rankedWrappers = <PackageDataWrapper>[];
    for (var i = 0; i < wrappers.length; i++) {
      final wrapper = wrappers[i];
      final rankedWrapper =
          wrapper.copyWith(data: wrapper.data.copyWith(overallRank: i));
      rankedWrappers.add(rankedWrapper);
    }
    rankedWrappers.sort((a, b) => a.package.compareTo(b.package));

    for (final wrapper in rankedWrappers) {
      unawaited(
        queue.add(() async {
          final package = wrapper.package;
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
