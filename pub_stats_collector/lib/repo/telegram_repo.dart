import 'dart:convert';

import 'package:pub_stats_collector/credential/credentials.ops.dart';
import 'package:pub_stats_collector/repo/alert_handler.dart';
import 'package:pub_stats_collector/service/undici_client.dart';
import 'package:pub_stats_core/pub_stats_core.dart';
import 'package:recase/recase.dart';

class TelegramRepo implements AlertHandler {
  final _client = UndiciClient();

  String _escapeUnderscores(String text) => text.replaceAll('_', '\\_');

  @override
  Future<void> sendPackageAlert({
    required String package,
    required TelegramAlertConfig config,
    required Map<PackageDataField, Diff> changes,
    required List<String> warnings,
  }) {
    var text =
        '*[${_escapeUnderscores(package)}](https://pubstats.dev/packages/$package)*';

    if (changes.isNotEmpty) {
      text += '\n';
      for (final MapEntry(key: field, value: diff) in changes.entries) {
        text += '\n*${field.name.titleCase}*\n${_escapeUnderscores(diff.text)}';
      }
    }

    if (warnings.isNotEmpty) {
      text += '\n\n*Warnings*';
      for (final warning in warnings) {
        text += '\n$warning';
      }
    }

    return _sendMessage(chatId: config.chatId, text: text);
  }

  @override
  Future<void> sendSystemErrorAlert({
    required TelegramAlertConfig config,
    required Object error,
  }) {
    return _sendMessage(chatId: config.chatId, text: '## Error\n$error');
  }

  @override
  Future<void> sendGlobalStatsAlert({
    required TelegramAlertConfig config,
    required GlobalStats stats,
    required Duration duration,
  }) {
    return _sendMessage(
      chatId: config.chatId,
      text:
          '''
*Package Scan Completed*

*Package Count*
${stats.packageCount}

*Most Downloaded Package*
${_escapeUnderscores(stats.mostDownloadedPackage)}

*Most Liked Package*
${_escapeUnderscores(stats.mostLikedPackage)}

*Most Depended Package*
${_escapeUnderscores(stats.mostDependedPackage)}

*Execution Time*
${duration.inSeconds} seconds''',
    );
  }

  Future<void> _sendMessage({required String chatId, required String text}) {
    return _client.post(
      Uri.parse(
        'https://api.telegram.org/bot${Credentials.telegramBotToken}/sendMessage',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'chat_id': chatId,
        'text': text,
        'parse_mode': 'MarkdownV2',
        'disable_web_page_preview': true,
      }),
    );
  }
}
