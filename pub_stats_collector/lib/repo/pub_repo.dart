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
    var mostDependedPackage = ('', 0);

    final wrappers = <PackageDataWrapper>[];
    final dependentMap = <String, Set<String>>{};
    var fetched = 0;
    Future<void> fetchPackageData(String package) async {
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
            legacyPopularityScore: popularityPercent,
            downloadCount: score.downloadCount30Days,
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
            await fetchPackageData(package).timeout(
              Duration(seconds: 30),
              onTimeout: () =>
                  throw TimeoutException('Timeout fetching data for $package'),
            );
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
      final adc = a.score.downloadCount30Days;
      final bdc = b.score.downloadCount30Days;
      return bdc.compareTo(adc);
    });

    final rankedWrappers = <PackageDataWrapper>[];
    for (var i = 0; i < wrappers.length; i++) {
      final wrapper = wrappers[i];
      final rankedWrapper = wrapper.copyWith(
        data: wrapper.data.copyWith(
          popularityScore:
              ((wrappers.length - i) / wrappers.length * 100).round(),
          overallRank: i,
        ),
      );
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
      mostDownloadedPackage: wrappers.first.package,
      mostDependedPackage: mostDependedPackage.$1,
      lastUpdated: DateTime.timestamp(),
    );
  }
}
