import 'package:discord_interactions/discord_interactions.dart';
import 'package:pub_stats_collector/credential/credentials.dart';
import 'package:pub_stats_core/pub_stats_core.dart';
import 'package:recase/recase.dart';

class DiscordRepo {
  static const _webhookUsername = 'Bartender';

  final _discord = DiscordApi(
    applicationId: '',
    userAgent: DiscordUserAgent(
      url: 'https://github.com/Rexios80/pub_stats_collector',
      versionNumber: '1.0.0',
    ),
    botToken: '',
  );

  DiscordRepo(Credentials credentials);

  Future<void> sendPackageAlert({
    required String package,
    required DiscordAlertConfig config,
    required Map<PackageDataField, Diff> changes,
    required List<String> warnings,
  }) async {
    final int color;
    if (warnings.isNotEmpty) {
      color = DiscordColor.red;
    } else {
      color = DiscordColor.purple;
    }

    return _executeWebhook(
      config.id,
      token: config.token,
      embeds: [
        Embed(
          title: package,
          color: color,
          url: 'https://pubstats.dev/packages/$package',
          fields: [
            ...changes.entries.map(
              (e) => EmbedField(
                name: e.key.name.titleCase,
                value: e.value.text,
              ),
            ),
            if (warnings.isNotEmpty)
              EmbedField(
                name: 'Warnings',
                value: warnings.join('\n'),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> sendSystemErrorAlert({
    required DiscordAlertConfig config,
    required Object error,
  }) {
    return _executeWebhook(
      config.id,
      token: config.token,
      embeds: [
        Embed(
          title: 'Error',
          color: DiscordColor.red,
          description: error.toString(),
        ),
      ],
    );
  }

  Future<void> sendGlobalStatsAlert({
    required DiscordAlertConfig config,
    required GlobalStats stats,
    required Duration duration,
  }) {
    return _executeWebhook(
      config.id,
      token: config.token,
      embeds: [
        Embed(
          title: 'Package Scan Completed',
          color: DiscordColor.dartBlue,
          url: 'https://pubstats.dev',
          fields: [
            EmbedField(
              name: 'Package Count',
              value: stats.packageCount.toString(),
            ),
            EmbedField(
              name: 'Most Liked Package',
              value: stats.mostLikedPackage,
            ),
            EmbedField(
              name: 'Most Depended Package',
              value: stats.mostDependedPackage,
            ),
            EmbedField(
              name: 'Most Downloaded Package',
              value: stats.mostDownloadedPackage,
            ),
            EmbedField(
              name: 'Execution Time',
              value: '${duration.inSeconds} seconds',
            ),
          ],
          footer: EmbedFooter(
            text: 'See historical package stats on pubstats.dev',
            iconUrl: 'https://pubstats.dev/splash/img/dark-2x.png',
          ),
        ),
      ],
    );
  }

  Future<void> _executeWebhook(
    String id, {
    required String token,
    required List<Embed> embeds,
  }) {
    return _discord.webhooks.executeWebhook(
      id,
      token: token,
      username: _webhookUsername,
      embeds: embeds,
    );
  }
}
