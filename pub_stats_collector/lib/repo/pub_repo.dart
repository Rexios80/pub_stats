import 'dart:async';

import 'package:flutter_tools_task_queue/flutter_tools_task_queue.dart';
import 'package:pub_api_client/pub_api_client.dart' hide Credentials;
import 'package:pub_stats_collector/credential/credentials.dart';
import 'package:pub_stats_core/pub_stats_core.dart';

typedef PubPackageScore = ({String name, PackageScore score});

class PubRepo {
  final PubClient _client;

  PubRepo(Credentials credentials)
      : _client = PubClient(client: UserAgentClient(credentials.userAgent));

  Future<GlobalStats> fetchAllScores(
    Future<void> Function(String package, PackageScore score) handleScore,
  ) async {
    final packages = await _client.packageNames();
    print('Fetched ${packages.length} package names');

    PubPackageScore? mostLikedPackage;
    PubPackageScore? mostPopularPackage;

    var completed = 0;
    Future<void> fetchPackageData(String package) async {
      final score = await _client.packageScore(package);
      final packageScore = (name: package, score: score);

      if (score.likeCount > (mostLikedPackage?.score.likeCount ?? 0)) {
        print('Most liked package: $package');
        mostLikedPackage = packageScore;
      }
      if ((score.popularityScore ?? 0) >
          (mostPopularPackage?.score.popularityScore ?? 0)) {
        print('Most popular package: $package');
        mostPopularPackage = packageScore;
      }

      await handleScore(package, score).timeout(
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
      mostLikedPackage: mostLikedPackage?.name ?? '',
      mostPopularPackage: mostPopularPackage?.name ?? '',
      lastUpdated: DateTime.now().toUtc(),
    );
  }

  Future<String?> fetchPublisher(String package) async {
    final data = await _client.packagePublisher(package);
    return data.publisherId;
  }
}
