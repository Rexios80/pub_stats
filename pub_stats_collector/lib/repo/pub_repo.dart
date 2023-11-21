import 'dart:async';

import 'package:flutter_tools_task_queue/flutter_tools_task_queue.dart';
import 'package:pub_api_client/pub_api_client.dart' hide Credentials;
import 'package:pub_stats_collector/credential/credentials.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

class PubRepo {
  final PubClient _client;

  PubRepo(Credentials credentials)
      : _client = PubClient(client: UserAgentClient(credentials.userAgent));

  Future<GlobalStats> fetchAllScores(
    Future<void> Function(PackageMetrics metrics, PackageData data) handleScore,
  ) async {
    final packages = await _client.packageNames();
    print('Fetched ${packages.length} package names');

    var mostLikedPackage = ('', 0);
    var mostPopularPackage = ('', 0.0);
    var mostDependedPackage = ('', 0);

    var lowestPopularityWithDependents = ('', 100.0);

    var completed = 0;
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
      final packageOptions = await _client.packageOptions(package);

      final dependentsData =
          await _client.fetchAllPackages(PackageTag.dependency(package));
      final dependents = dependentsData.map((e) => e.package).toSet();

      if (dependents.length > mostDependedPackage.$2) {
        print('Most depended package: $package');
        mostDependedPackage = (package, dependents.length);
      }

      if (dependents.isNotEmpty &&
          popularityPercent < lowestPopularityWithDependents.$2) {
        lowestPopularityWithDependents = (package, popularityScore);
      }

      final data = PackageData(
        publisher: publisherData.publisherId,
        version: metrics.scorecard.packageVersion,
        likeCount: metrics.score.likeCount,
        popularityScore: popularityPercent,
        isDiscontinued: packageOptions.isDiscontinued,
        isUnlisted: packageOptions.isUnlisted,
        dependents: dependents,
      );

      await handleScore(metrics, data).timeout(
        Duration(seconds: 30),
        onTimeout: () =>
            throw TimeoutException('Timeout handling score for $package'),
      );

      completed++;
      if (completed % 100 == 0) {
        print('Processed $completed/${packages.length} packages');
      }
    }

    final queue = TaskQueue(maxJobs: 100);
    for (final package in packages) {
      unawaited(
        queue.add(() async {
          try {
            await fetchPackageData(package);
          } catch (e) {
            print('Error processing package $package: $e');
          }
        }),
      );
    }
    await queue.tasksComplete;
    print('Processed all scores');

    return GlobalStats(
      packageCount: packages.length,
      mostLikedPackage: mostLikedPackage.$1,
      mostPopularPackage: mostPopularPackage.$1,
      mostDependedPackage: mostDependedPackage.$1,
      lastUpdated: DateTime.now().toUtc(),
    );
  }
}
